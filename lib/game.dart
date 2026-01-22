import 'package:flutter/material.dart';

import 'models/game_card_data.dart';
import 'ui/game_cards/game_card.dart';
import 'ui/game_table/game_table.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: 200.0,
              color: Colors.amber,
              child: Row(
                children: [
                  GameCard(
                    cardData: GameCardData(
                      name: 'Sheep',
                      target: GameCardTarget.myTable,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      name: 'Fog',
                      target: GameCardTarget.opTable,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      name: 'Sun',
                      target: GameCardTarget.myUnit,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GameTable(),
          Expanded(
            child: Container(
              height: 200.0,
              color: Colors.amber,
              child: Row(
                children: [
                  GameCard(
                    cardData: GameCardData(
                      name: 'Sheep',
                      target: GameCardTarget.myTable,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      name: 'Fog',
                      target: GameCardTarget.opTable,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      name: 'Sun',
                      target: GameCardTarget.myUnit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
