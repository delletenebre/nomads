import 'package:flutter/material.dart';

class GameDeck extends StatelessWidget {
  final int cardCount;
  final VoidCallback? onTap;
  final bool? isPlayerDeck;

  const GameDeck({
    Key? key,
    required this.cardCount,
    this.onTap,
    this.isPlayerDeck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 63.0 * 1.1,
        height: 88.0 * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (cardCount > 2)
              Positioned(
                top: 4,
                child: Transform.rotate(angle: 0.05, child: _buildCardBack()),
              ),
            if (cardCount > 1)
              Positioned(
                top: 2,
                child: Transform.rotate(angle: -0.03, child: _buildCardBack()),
              ),
            if (cardCount > 0) _buildCardBack(),
            if (cardCount > 0)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$cardCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDeckColor() {
    if (isPlayerDeck == null) {
      return const Color(0xff6d5f4c); // Нейтральный коричневый для общей колоды
    }
    return isPlayerDeck!
        ? const Color(0xff4a3d8b) // Колода игрока 1
        : const Color(0xff8b3d4a); // Колода игрока 2
  }

  Widget _buildCardBack() {
    return Container(
      width: 63.0,
      height: 88.0,
      decoration: BoxDecoration(
        color: _getDeckColor(),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
