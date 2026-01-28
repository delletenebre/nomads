import 'package:flutter/material.dart';

import '../../models/game_card_data.dart';

class GameCardView extends StatelessWidget {
  final GameCardData cardData;

  const GameCardView({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    final size = 3.0;

    return Material(
      child: Container(
        width: 30.0 * size,
        height: 50.0 * size,
        color: switch (cardData.type) {
          GameCardType.creature => Colors.red,
          GameCardType.spell => Colors.blue,
          GameCardType.debuff => Colors.yellow,
        },
        child: Text('${cardData.name}'),
      ),
    );
  }
}
