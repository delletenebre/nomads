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
    final offset = useRef(Offset.zero);

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
          offset.value += details.delta;
        },
        onDragEnd: (details) {
          debugPrint(
            '[GameCard] onDragEnd at ${details.offset} with accepted: ${details.wasAccepted}',
          );

          if (!details.wasAccepted) {
            print('lastoffset: ${offset.value}');

            /// если карта не была разыграна правильно
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   offset.value = Offset.zero;
            //   // tiltNotifier.value = 0.0;
            // });
          }

          tiltNotifier.value = 0.0;
        },
        onDragStarted: () {
          debugPrint('[GameCard] onDragStarted');

          onDragStarted?.call();
        },
        onDragCompleted: () {
          debugPrint('[GameCard] onDragCompleted');

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
        childWhenDragging: const SizedBox(),
        child: TweenAnimationBuilder<Offset>(
          onEnd: () => offset.value = Offset.zero,
          tween: Tween(begin: offset.value, end: Offset.zero),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.ease,
          builder: (context, offset, child) {
            return Transform.translate(offset: offset, child: child);
          },
          child: GameCardView(cardData: cardData),
        ),
      ),
    );

    // return AnimatedCard(
    //   rotationAngle: rotationAngle,
    //   isActive: isActive,
    //   child

    // AnimatedContainer(
    //       key: ValueKey(cardData.id),
    //       duration: const Duration(milliseconds: 200),
    //       transform: Matrix4.translationValues(
    //         offset.value.dx,
    //         offset.value.dy,
    //         0.0,
    //       ),
    //       child: GameCardView(cardData: cardData),
    //     ),
    //   ),
    // );
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
