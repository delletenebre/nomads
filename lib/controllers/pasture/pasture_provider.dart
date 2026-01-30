import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/game_card_data.dart';
import 'pasture_cell.dart';

final pastureProvider = NotifierProvider<PastureNotifier, List<PastureCell>>(
  PastureNotifier.new,
);

class PastureNotifier extends Notifier<List<PastureCell>> {
  @override
  List<PastureCell> build() => List.generate(8, (_) => PastureCell(cards: []));

  // Добавление животного в ячейку
  void addCard(int index, GameCardData newCard) {
    final cell = state[index];
    final updatedAnimals = List<GameCardData>.from(cell.cards);

    if (updatedAnimals.length >= 3) {
      // Логика вытеснения: находим животное с наименьшим весом
      // В реальности тут можно добавить проверку суммарного веса игрока
      updatedAnimals.sort((a, b) => a.weight.compareTo(b.weight));

      if (newCard.weight >= updatedAnimals.first.weight) {
        /// вытесняем самого слабого
        updatedAnimals.removeAt(0);

        /// добавляем новую карту
        updatedAnimals.add(newCard);
      } else {
        // Если новое животное слабее всех, оно не может зайти (или возвращается в руку)
        return;
      }
    } else {
      updatedAnimals.add(newCard);
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) cell.copyWith(cards: updatedAnimals) else state[i],
    ];
  }

  // Проверка формации "Аркан" (3 в ряд) для конкретного игрока
  bool checkArkan(String playerId) {
    const lines = [
      /// горизонтали
      [0, 1, 2], [5, 6, 7],
      // диагонали
      [1, 3, 5], [2, 4, 6], [0, 3, 6], [1, 4, 7],
    ];

    for (var line in lines) {
      if (line.every((idx) => _isPlayerDominant(idx, playerId))) {
        return true;
      }
    }
    return false;
  }

  bool _isPlayerDominant(int index, String playerId) {
    // Игрок доминирует, если в клетке только его животные и их > 0
    final cards = state[index].cards;
    return cards.isNotEmpty && cards.every((a) => a.playerId == playerId);
  }

  void updateCell(int index, PastureCell newCell) {
    // Создаем новый список на основе старого состояния
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newCell else state[i],
    ];
  }
}
