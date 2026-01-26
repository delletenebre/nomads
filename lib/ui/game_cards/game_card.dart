import 'package:flutter/material.dart';

import '../../models/game_card_data.dart';
import 'game_card_view.dart';

class GameCard extends StatelessWidget {
  final GameCardData cardData;

  const GameCard({super.key, required this.cardData});

  @override
  Widget build(BuildContext context) {
    return Draggable<GameCardData>(
      data: cardData,
      feedback: GameCardView(cardData: cardData),
      childWhenDragging: const SizedBox(),
      child: GameCardView(cardData: cardData),
    );
  }
}
