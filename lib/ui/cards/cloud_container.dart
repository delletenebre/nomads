import 'dart:math';

import 'package:flutter/material.dart';

class CloudContainer extends StatefulWidget {
  final Widget child;
  final Color color;
  final double blurAmount;
  final double spread;

  const CloudContainer({
    super.key,
    required this.child,
    required this.color,
    this.blurAmount = 25.0, // High blur for smoothness
    this.spread = 35.0, // Thick border
  });

  @override
  State<CloudContainer> createState() => _CloudContainerState();
}

class _CloudContainerState extends State<CloudContainer> {
  late List<_EdgePuff> puffs;
  Color _solidColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    puffs = _generateSmoothPuffs();
    if ((widget.color.a * 255.0).round().clamp(0, 255) != 0) {
      _solidColor = widget.color;
    }
  }

  @override
  void didUpdateWidget(covariant CloudContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Capture the new solid color when it's provided.
    if ((widget.color.a * 255.0).round().clamp(0, 255) != 0) {
      _solidColor = widget.color;
    }
  }

  List<_EdgePuff> _generateSmoothPuffs() {
    final random = Random();
    final List<_EdgePuff> generated = [];

    // LOW number = MORE dense.
    // 0.05 means we place a circle every 5% of the edge length.
    // This high density is key to making it look like a solid smooth block.
    const double density = 0.5;

    void populateEdge(_EdgeSide side) {
      double position = 0.0;
      while (position < 1.0) {
        // Very small steps for a continuous look
        position += density;

        // Add some jitter to position so it doesn't look like a straight line
        double jitter = (random.nextDouble() - 0.5) * 0.05;
        double finalPos = (position + jitter).clamp(0.0, 1.0);

        // Randomize the outward spread slightly, but keep it close to max
        // to maintain a thick, solid feel.
        double shift = 0.8 + random.nextDouble() * 0.2;

        // Randomize size slightly
        double sizeNorm = 0.7 + random.nextDouble() * 0.3;

        generated.add(_EdgePuff(side, finalPos, shift, sizeNorm));
      }
    }

    populateEdge(_EdgeSide.top);
    populateEdge(_EdgeSide.right);
    populateEdge(_EdgeSide.bottom);
    populateEdge(_EdgeSide.left);

    return generated;
  }

  @override
  Widget build(BuildContext context) {
    final targetOpacity = (widget.color.a * 255.0).round().clamp(0, 255) == 0
        ? 0.0
        : 1.0;

    // Use the last known solid color for the fade-out animation.
    final baseColor = _solidColor;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetOpacity),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, opacity, child) {
        return CustomPaint(
          painter: _CloudPainter(
            puffs: puffs,
            color: baseColor.withValues(alpha: opacity),
            blurAmount: widget.blurAmount,
            spread: widget.spread,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// -----------------------------------------------------------
// PAINTING LOGIC (Same core logic, tuned for smoothness)
// -----------------------------------------------------------

enum _EdgeSide { top, right, bottom, left }

class _EdgePuff {
  final _EdgeSide side;
  final double positionAlongEdge;
  final double outwardShift;
  final double normalizedSize;
  _EdgePuff(
    this.side,
    this.positionAlongEdge,
    this.outwardShift,
    this.normalizedSize,
  );
}

class _CloudPainter extends CustomPainter {
  final List<_EdgePuff> puffs;
  final Color color;
  final double blurAmount;
  final double spread;

  _CloudPainter({
    required this.puffs,
    required this.color,
    required this.blurAmount,
    required this.spread,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Setup the paint with the blur effect
    final Paint paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);

    final Rect rect = Offset.zero & size;

    // 2. Create a Path that will hold the entire shape (Center + Edges)
    final Path cloudPath = Path();

    // A. Add the solid center
    // We shrink it slightly (by 1 pixel) to ensure it merges perfectly with the puffs
    cloudPath.addRect(rect);

    // B. Add all the edge puffs to the same path
    for (var puff in puffs) {
      Offset center;
      double radius = (spread * 0.8) * puff.normalizedSize;
      double shift = puff.outwardShift * (spread * 0.4);

      switch (puff.side) {
        case _EdgeSide.top:
          center = Offset(
            rect.left + (rect.width * puff.positionAlongEdge),
            rect.top - shift,
          );
          break;
        case _EdgeSide.right:
          center = Offset(
            rect.right + shift,
            rect.top + (rect.height * puff.positionAlongEdge),
          );
          break;
        case _EdgeSide.bottom:
          center = Offset(
            rect.left + (rect.width * puff.positionAlongEdge),
            rect.bottom + shift,
          );
          break;
        case _EdgeSide.left:
          center = Offset(
            rect.left - shift,
            rect.top + (rect.height * puff.positionAlongEdge),
          );
          break;
      }

      // Add the puff circle to the path
      cloudPath.addOval(Rect.fromCircle(center: center, radius: radius));
    }

    // 3. Draw the combined shape
    // using saveLayer ensures the blur blends correctly with the background
    canvas.saveLayer(rect.inflate(spread + blurAmount * 2), Paint());
    canvas.drawPath(cloudPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CloudPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.blurAmount != blurAmount ||
        oldDelegate.spread != spread ||
        oldDelegate.puffs != puffs;
  }
}
