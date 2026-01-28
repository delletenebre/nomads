import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

import 'models/game_card_data.dart';
import 'ui/game_cards/game_card.dart';
import 'ui/game_hand/game_hand.dart';
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
                      id: Ulid().toString(),
                      name: 'Sheep',
                      target: GameCardTarget.myTable,
                      type: GameCardType.creature,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      id: Ulid().toString(),
                      name: 'Fog',
                      target: GameCardTarget.opponentTable,
                      type: GameCardType.spell,
                    ),
                  ),
                  GameCard(
                    cardData: GameCardData(
                      id: Ulid().toString(),
                      name: 'Sun',
                      target: GameCardTarget.myUnit,
                      type: GameCardType.debuff,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GameTable(),
          Expanded(
            child: GameHand(
              cards: [
                GameCardData(
                  id: Ulid().toString(),
                  name: 'Sheep',
                  target: GameCardTarget.myTable,
                  type: GameCardType.creature,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  name: 'Fog',
                  target: GameCardTarget.opponentTable,
                  type: GameCardType.debuff,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  name: 'Sun',
                  target: GameCardTarget.myUnit,
                  type: GameCardType.spell,
                ),
              ],
              cardWidth: 100,
              cardHeight: 100,
              spacingFactor: 1.0,
              focusedCardId: '',
              hoveredCardId: '',
              onCardTap: (String id) {},
              onCardHover: (String id, bool isHover) {},
            ),
          ),
        ],
      ),
    );
  }
}
