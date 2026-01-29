import 'package:flutter/material.dart';

import '../../models/game_card_data.dart';

class GameCardView extends StatelessWidget {
  final GameCardData cardData;

  const GameCardView({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    final size = 1.0;

    return Material(
      child: Container(
        width: 63.0 * size,
        height: 88.0 * size,
        color: switch (cardData.type) {
          GameCardType.creature => Colors.red,
          GameCardType.spell => Colors.blue,
          GameCardType.event => Colors.yellow,
          GameCardType.hero => Colors.green,
        },
        child: Text('${cardData.name}'),
      ),
    );
  }
}
