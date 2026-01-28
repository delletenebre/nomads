import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GameCardPlaceholder extends HookWidget {
  final double width;

  const GameCardPlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    /// стилизованный контейнер, который показывает, куда можно поместить карту
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 100),
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      builder: (context, width, child) {
        return Container(
          width: width,
          height: 150, // Высота должна совпадать с высотой карты (150.0)
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      },
    );
  }
}
