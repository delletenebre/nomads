import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GameCardPlaceholder extends HookWidget {
  final double width;
  final double spacing;

  const GameCardPlaceholder({
    super.key,
    required this.width,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    // Use an AnimationController with `useAnimationController` hook
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final Animation<double> animation = useMemoized(() {
      return Tween<double>(begin: 0.0, end: 100.0).animate(controller);
    }, [controller]); // Re-run if controller changes

    useEffect(() {
      controller.forward();
      return null;
    }, const []); // Empty keys array means it only runs once

    final animatedWidth = useAnimation(animation);

    // Это просто стилизованный контейнер, который показывает,
    // куда можно поместить карту.
    return Container(
      width: animatedWidth,
      height: 150, // Высота должна совпадать с высотой карты (150.0)
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
