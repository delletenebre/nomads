import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

import 'models/creature_card_data.dart';
import 'models/game_card_data.dart';
import 'ui/game_cards/game_card.dart';
import 'ui/game_hand/game_hand.dart';
import 'ui/pasture/pasture.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GameHand(
              cards: [
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '1',
                  name: 'Sheep',
                  creatureType: CreatureCardType.sheep,
                  weight: 1.0,
                ),
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '1',
                  name: 'Cow',
                  creatureType: CreatureCardType.cow,
                  weight: 2.0,
                ),
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '1',
                  name: 'Camel',
                  creatureType: CreatureCardType.camel,
                  weight: 4.0,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  playerId: '1',
                  name: 'Fog',
                  // target: GameCardTarget.opponentTable,
                  // type: GameCardType.debuff,
                  type: GameCardType.event,
                  weight: 0.0,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  playerId: '1',
                  name: 'Sun',
                  // target: GameCardTarget.myUnit,
                  type: GameCardType.spell,
                  weight: 1.0,
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
          Expanded(flex: 3, child: Pasture()),
          Expanded(
            child: GameHand(
              cards: [
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '2',
                  name: 'Sheep',
                  creatureType: CreatureCardType.sheep,
                  weight: 1.0,
                ),
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '2',
                  name: 'Cow',
                  creatureType: CreatureCardType.cow,
                  weight: 2.0,
                ),
                CreatureCard(
                  id: Ulid().toString(),
                  playerId: '2',
                  name: 'Camel',
                  creatureType: CreatureCardType.camel,
                  weight: 4.0,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  playerId: '2',
                  name: 'Fog',
                  // target: GameCardTarget.opponentTable,
                  // type: GameCardType.debuff,
                  type: GameCardType.event,
                  weight: 0.0,
                ),
                GameCardData(
                  id: Ulid().toString(),
                  playerId: '2',
                  name: 'Sun',
                  // target: GameCardTarget.myUnit,
                  type: GameCardType.spell,
                  weight: 1.0,
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
