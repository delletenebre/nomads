import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_card_data.dart';
import '../game_cards/game_card_view.dart';

class CardDrawAnimation extends StatefulWidget {
  final GameCardData card;
  final Offset startPosition;
  final Offset pausePosition;
  final Offset endPosition;
  final VoidCallback onComplete;
  final bool shouldPause;
  final double finalRotation;
  final bool autoStart;

  const CardDrawAnimation({
    Key? key,
    required this.card,
    required this.startPosition,
    required this.pausePosition,
    required this.endPosition,
    required this.onComplete,
    this.shouldPause = false,
    this.finalRotation = 0.0,
    this.autoStart = true,
  }) : super(key: key);

  @override
  CardDrawAnimationState createState() => CardDrawAnimationState();
}

class CardDrawAnimationState extends State<CardDrawAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _zRotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // A bit longer to feel less rushed
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final midPoint = widget.pausePosition;

    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: widget.startPosition,
          end: midPoint,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: midPoint,
          end: widget.endPosition,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 45,
      ),
    ]).animate(_controller);

    if (widget.shouldPause) {
      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 1.6,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 55,
        ), // Align with position animation
        TweenSequenceItem(
          tween: Tween(
            begin: 1.6,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 45,
        ), // Align with position animation
      ]).animate(_controller);
    } else {
      // For opponent, no scaling
      _scaleAnimation = ConstantTween<double>(1.0).animate(_controller);
    }

    _rotationAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.55, curve: Curves.easeIn),
      ),
    );

    _zRotationAnimation = Tween<double>(begin: 0, end: widget.finalRotation)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
          ),
        );

    // Start animation after the first frame.
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runFullSequence());
    }
  }

  Future<void> animateToCenter() {
    const pausePoint = 0.55;
    final totalDuration = _controller.duration!.inMilliseconds;
    final firstPartDuration = (totalDuration * pausePoint).round();
    return _controller.animateTo(
      pausePoint,
      duration: Duration(milliseconds: firstPartDuration),
      curve: Curves.linear,
    );
  }

  Future<void> animateToHand() {
    const pausePoint = 0.55;
    final totalDuration = _controller.duration!.inMilliseconds;
    final secondPartDuration =
        totalDuration - (totalDuration * pausePoint).round();
    return _controller.animateTo(
      1.0,
      duration: Duration(milliseconds: secondPartDuration),
      curve: Curves.linear,
    );
  }

  void _runFullSequence() async {
    if (!mounted) return;

    if (widget.shouldPause) {
      // Animate to the midpoint (where the card is largest and fully revealed)
      // The rotation ends at 0.55. The scale peaks at 0.45.
      // We pause when the card is fully rotated (at t=0.55) to be readable.
      await animateToCenter();

      // Pause for 1.5 seconds so the player can read the card
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Animate from midpoint to the end
      await animateToHand();

      if (mounted) widget.onComplete();
    } else {
      // Original behavior
      _controller.forward().whenComplete(() {
        if (mounted) widget.onComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Если карту берет противник, показываем только рубашку без переворота.
        if (!widget.shouldPause) {
          return Positioned(
            left: _positionAnimation.value.dx,
            top: _positionAnimation.value.dy,
            child: Transform.rotate(
              angle: _zRotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value, // Will be 1.0 for opponent
                child: _buildCardBack(),
              ),
            ),
          );
        }

        // Для активного игрока показываем анимацию с переворотом.
        final isFlipped = _rotationAnimation.value > pi / 2;
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.rotate(
            angle: _zRotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationAnimation.value),
                child: isFlipped
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: GameCardView(cardData: widget.card),
                      )
                    : _buildCardBack(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 63.0,
      height: 88.0,
      decoration: BoxDecoration(
        color: const Color(0xff6d5f4c), // Нейтральный цвет общей колоды
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.shield_moon_outlined,
          color: Colors.white.withOpacity(0.5),
          size: 30,
        ),
      ),
    );
  }
}
