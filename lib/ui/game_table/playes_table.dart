import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/game_card_data.dart';
import '../cards/cloud_container.dart';
import '../game_cards/game_card_placeholder.dart';
import '../game_cards/game_card_view.dart';

class PlayerTable extends HookWidget {
  final void Function(bool isAccepted) onStatusChanged;

  const PlayerTable({super.key, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    // Состояние для хранения карт на столе. Используем useState для перерисовки.
    final cardsOnTable = useState<List<GameCardData>>([]);
    // Состояние для индекса, куда будет вставлена карта. null, если не над зоной.
    final insertionIndex = useState<int?>(null);
    // Состояние для подсветки, когда карта над столом.
    final isHovered = useState(false);

    // ВАЖНО: Размеры вашей карты и отступ между ними.
    // Из GameCardView: width = 30 * 3 = 90.
    const cardWidth = 90.0;
    const cardSpacing = 12.0;

    void updateInsertionIndex(Offset globalOffset) {
      final box = context.findRenderObject() as RenderBox;
      final localOffset = box.globalToLocal(globalOffset);

      final currentCardsCount = cardsOnTable.value.length;
      final itemWidth = cardWidth + cardSpacing;
      final totalRowWidth = currentCardsCount * itemWidth;
      final tableWidth = box.size.width;

      // Начало ряда карт (учитывая центрирование)
      final rowStartX = (tableWidth > totalRowWidth)
          ? (tableWidth - totalRowWidth) / 2
          : 0.0;

      // Позиция курсора относительно начала ряда (с учетом прокрутки)
      final relativeDx = localOffset.dx + scrollController.offset - rowStartX;

      // Вычисляем индекс, округляя до ближайшего слота
      final index = (relativeDx / itemWidth).round();

      // Ограничиваем индекс в допустимых пределах
      insertionIndex.value = index.clamp(0, currentCardsCount);
    }

    return DragTarget<GameCardData>(
      onWillAcceptWithDetails: (details) {
        if (!isHovered.value) {
          isHovered.value = true;
          onStatusChanged(true);
        }
        updateInsertionIndex(details.offset);
        return true;
      },
      onMove: (details) {
        updateInsertionIndex(details.offset);
      },
      onLeave: (data) {
        isHovered.value = false;
        insertionIndex.value = null; // Убираем плейсхолдер
        onStatusChanged(false);
      },
      onAcceptWithDetails: (details) {
        // Добавляем карту в список в вычисленной позиции
        final index = insertionIndex.value ?? cardsOnTable.value.length;
        final newCards = List<GameCardData>.from(cardsOnTable.value);
        newCards.insert(index, details.data);
        cardsOnTable.value = newCards;

        // Сбрасываем состояния
        isHovered.value = false;
        insertionIndex.value = null;
        onStatusChanged(false);
      },
      builder: (context, candidateData, rejectedData) {
        // Динамически создаем список виджетов карт
        final cardWidgets = cardsOnTable.value.map<Widget>((cardData) {
          return Padding(
            padding: const .symmetric(horizontal: cardSpacing / 2),
            child: GameCardView(cardData: cardData),
          );
        }).toList();

        /// вставляем плейсхолдер в вычисленную позицию, что позволяет
        /// раздвигать карты, выложенные на столе
        if (insertionIndex.value != null) {
          cardWidgets.insert(
            insertionIndex.value!,
            GameCardPlaceholder(width: cardWidth, spacing: cardSpacing),
          );
        }

        return CloudContainer(
          blurAmount: 12.0,
          spread: 8.0,
          color: isHovered.value ? Colors.green.shade300 : Colors.transparent,
          child: Container(
            width: .infinity,
            alignment: .center,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: .horizontal,
              child: Row(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: cardWidgets,
              ),
            ),
          ),
        );
      },
    );
  }
}
