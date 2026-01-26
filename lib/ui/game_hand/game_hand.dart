import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/game_card_data.dart';
import '../game_cards/game_card.dart';

class GameHand extends HookWidget {
  final List<GameCardData> cards;
  final double cardWidth;
  final double cardHeight;
  final double spacingFactor;
  final String? focusedCardId;
  final String? hoveredCardId;
  final Function(String id) onCardTap;
  final Function(String id, bool isHover) onCardHover;

  const GameHand({
    super.key,
    required this.cards,
    required this.cardWidth,
    required this.cardHeight,
    required this.spacingFactor,
    required this.focusedCardId,
    required this.hoveredCardId,
    required this.onCardTap,
    required this.onCardHover,
  });

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;

    final hoveredCardId = useState<String?>(null);

    List<Widget> standardCards = [];
    Widget? activeCardWidget;

    for (int index = 0; index < cards.length; index++) {
      final card = cards[index];
      final bool isActive =
          (card.id == focusedCardId) || (card.id == hoveredCardId.value);

      final total = cards.length;
      final centerIndex = (total - 1) / 2;
      final offsetFromCenter = index - centerIndex;

      final double spacingX = cardWidth * spacingFactor;
      final double translateX = offsetFromCenter * spacingX;
      final double translateY = offsetFromCenter.abs() * (cardWidth * 0.12);

      final double leftPos =
          (containerWidth / 2) + translateX - (cardWidth / 2);
      final double bottomPos = -translateY + 20;

      final double rotationAngle = isActive ? 0.0 : offsetFromCenter * 0.1;

      final cardWidget = AnimatedPositioned(
        key: ValueKey(card.id),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        left: leftPos,
        bottom: bottomPos,
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (event) {
            hoveredCardId.value = card.id;
            onCardHover(card.id, true);
          },
          onExit: (event) {
            if (hoveredCardId.value == card.id) {
              hoveredCardId.value = null;
            }
            onCardHover(card.id, false);
          },
          child: GestureDetector(
            onTap: () => onCardTap(card.id),
            child: GameCard(
              cardData: card,
              rotationAngle: rotationAngle,
              isActive: isActive,
            ),
          ),
        ),
      );

      if (isActive) {
        activeCardWidget = cardWidget;
      } else {
        standardCards.add(cardWidget);
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...standardCards,
        if (activeCardWidget != null) activeCardWidget,
      ],
    );
  }
}
