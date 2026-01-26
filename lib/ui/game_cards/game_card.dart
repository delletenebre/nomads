import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/game_card_data.dart';
import 'game_card_view.dart';

class GameCard extends HookWidget {
  final GameCardData cardData;
  final void Function()? onDragStarted;
  final void Function()? onDragCompleted;
  final double rotationAngle;
  final bool isActive;

  const GameCard({
    super.key,
    required this.cardData,
    this.onDragStarted,
    this.onDragCompleted,
    this.rotationAngle = 0.0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tiltNotifier = useValueNotifier(0.0);

    return AnimatedCard(
      rotationAngle: rotationAngle,
      isActive: isActive,
      child: Draggable<GameCardData>(
        data: cardData,
        hitTestBehavior: HitTestBehavior.opaque,
        onDragUpdate: (details) {
          double newTilt = details.delta.dx * 0.01;
          newTilt = newTilt.clamp(-0.4, 0.4);
          tiltNotifier.value = newTilt;
        },
        onDragEnd: (details) {
          tiltNotifier.value = 0.0;
          // Instant play logic is now handled by the DragTarget's onAccept.
        },
        onDragStarted: () {
          onDragStarted?.call();
        },
        onDragCompleted: () {
          onDragCompleted?.call();
        },
        feedback: ValueListenableBuilder(
          valueListenable: tiltNotifier,
          builder: (context, tilt, child) {
            return TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: tilt),
              duration: const Duration(milliseconds: 100),
              builder: (context, animatedTilt, _) {
                return Transform.rotate(
                  angle: animatedTilt,
                  child: Transform.scale(
                    scale: 1.2,
                    child: GameCardView(cardData: cardData),
                  ),
                );
              },
            );
          },
        ),
        childWhenDragging: Opacity(opacity: 0.0, child: SizedBox()),
        child: GameCardView(cardData: cardData),
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final double rotationAngle;
  final bool isActive;

  const AnimatedCard({
    super.key,
    required this.child,
    required this.rotationAngle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      scale: isActive ? 1.2 : 1.0,
      alignment: .bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.rotationZ(rotationAngle),
        transformAlignment: .center,
        child: child,
      ),
    );
  }
}
