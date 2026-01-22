import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../models/game_card_data.dart';

class GameTable extends HookWidget {
  const GameTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isTableAccepted = useState(false);
    final isAcceptedMyTable = useState(false);
    final isAcceptedOpponentTable = useState(false);

    // Helper to update the main table status based on sub-zones
    void checkTableStatus() {
      isTableAccepted.value =
          isAcceptedMyTable.value || isAcceptedOpponentTable.value;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      height: 40.0.h,
      color: isTableAccepted.value
          ? Colors.orange.withAlpha(32)
          : Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: DragTarget<GameCardData>(
              // 2. Add Type Generics for safety
              onWillAcceptWithDetails: (details) {
                isAcceptedOpponentTable.value = true;
                checkTableStatus(); // Update Parent
                return true;
              },
              onLeave: (data) {
                isAcceptedOpponentTable.value = false;
                checkTableStatus(); // Update Parent
              },
              onAcceptWithDetails: (details) {
                // Handle drop
                isAcceptedOpponentTable.value = false;
                checkTableStatus();
              },
              builder: (context, candidateData, rejectedData) {
                return CloudContainer(
                  blurAmount: 12.0,
                  spread: 8.0,
                  color: isAcceptedOpponentTable.value
                      ? Colors.green.shade300
                      : Colors.red,
                  child: SizedBox.expand(child: Text('test')),
                );
              },
            ),
          ),
          Expanded(
            child: DragTarget<GameCardData>(
              onWillAcceptWithDetails: (details) {
                isAcceptedMyTable.value = true;
                checkTableStatus(); // Update Parent
                return true;
              },
              onLeave: (data) {
                isAcceptedMyTable.value = false;
                checkTableStatus(); // Update Parent
              },
              onAcceptWithDetails: (details) {
                // Handle drop
                isAcceptedMyTable.value = false;
                checkTableStatus();
              },
              builder: (context, candidateData, rejectedData) {
                return CloudContainer(
                  blurAmount: 12.0,
                  spread: 8.0,
                  color: isAcceptedMyTable.value
                      ? Colors.green.shade300
                      : Colors.red,
                  child: SizedBox.expand(child: Text('test')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CloudContainer extends StatefulWidget {
  final Widget child;
  final Color color;
  final double blurAmount;
  final double spread;

  const CloudContainer({
    super.key,
    required this.child,
    this.color = const Color(0xFFE57373), // Reddish color from your image
    this.blurAmount = 25.0, // High blur for smoothness
    this.spread = 35.0, // Thick border
  });

  @override
  State<CloudContainer> createState() => _CloudContainerState();
}

class _CloudContainerState extends State<CloudContainer> {
  late List<_EdgePuff> puffs;

  @override
  void initState() {
    super.initState();
    puffs = _generateSmoothPuffs();
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
    return CustomPaint(
      painter: _CloudPainter(
        puffs: puffs,
        color: widget.color,
        blurAmount: widget.blurAmount,
        spread: widget.spread,
      ),
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
