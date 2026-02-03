import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/deck_provider.dart';
import '../../controllers/pasture/pasture_provider.dart';
import '../../controllers/pasture/game_provider.dart';
import '../../models/game_card_data.dart';
import '../effects/fog_overlay.dart';

import 'pasture_cell_view.dart';

class Pasture extends HookConsumerWidget {
  const Pasture({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;

    /// контроллер пастбища
    final pastureState = ref.watch(pastureProvider);

    return FogOverlay(
      isEnabled: false,
      child: Container(
        width: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pasture1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: LayoutBuilder(
              builder: (context, constrains) {
                final cellSize = constrains.maxWidth / 3;

                return Stack(
                  clipBehavior: Clip.none,
                  children: pastureState.mapIndexed((index, cell) {
                    int r, c;

                    // ЛОГИКА 3x2x3
                    if (index < 3) {
                      // Первые 3 элемента (0, 1, 2) -> Ряд 0
                      r = 0;
                      c = index;
                    } else if (index < 5) {
                      // Следующие 2 элемента (3, 4) -> Ряд 1
                      r = 1;
                      c =
                          index -
                          3; // сбрасываем счетчик колонки (3 превращаем в 0, 4 в 1)
                    } else {
                      // Остальные 3 элемента (5, 6, 7) -> Ряд 2
                      r = 2;
                      c = index - 5; // сбрасываем (5->0, 6->1, 7->2)
                    }

                    // Вертикаль: каждый ряд ниже на 0.85 высоты клетки
                    final top = r * cellSize * 0.85;

                    // Горизонталь:
                    // Базовая позиция (c * cellSize)
                    // + Смещение для нечетных рядов (если ряд 1, сдвигаем на половину клетки)
                    final rowShift = (r % 2 == 1) ? (cellSize * 0.5) : 0.0;

                    final left = (c * cellSize) + rowShift;

                    return Positioned(
                      top: top,
                      left: left,
                      child: HexTile<GameCardData>(
                        size: cellSize,
                        cards: pastureState[index].cards,
                        willAcceptCard: (details) =>
                            details.data.type == GameCardType.creature,
                        onCardDropped: (card) {
                          final success = ref
                              .read(pastureProvider.notifier)
                              .addCard(index, card);
                          if (success) {
                            ref
                                .read(deckProvider.notifier)
                                .removeCardFromHand(card);
                            ref.read(gameProvider.notifier).endTurn();
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
