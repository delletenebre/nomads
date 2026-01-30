import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nomads/controllers/shaders/shader_type.dart';

import '../../controllers/shaders/shader_manager.dart';

class FogOverlay extends ConsumerStatefulWidget {
  final bool isEnabled;
  final Widget child;

  const FogOverlay({super.key, required this.isEnabled, required this.child});

  @override
  ConsumerState<FogOverlay> createState() => _FogOverlayState();
}

class _FogOverlayState extends ConsumerState<FogOverlay>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _timeInSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() {
        _timeInSeconds = (elapsed.inMilliseconds / 1000.0) * 3.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shaderManager = ref.watch(shadersProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: widget.isEnabled ? 1.0 : 0.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        if (opacity == 0) {
          return widget.child;
        }

        return CustomPaint(
          foregroundPainter: FogPainter(
            time: _timeInSeconds,
            opacity: opacity,
            shaderProgram: shaderManager.getProgram(ShaderType.fog),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class FogPainter extends CustomPainter {
  final double time;
  final double opacity;
  final ui.FragmentProgram shaderProgram;

  FogPainter({
    required this.time,
    required this.opacity,
    required this.shaderProgram,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final shader = shaderProgram.fragmentShader();
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, opacity);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(covariant FogPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.opacity != opacity;
  }
}
