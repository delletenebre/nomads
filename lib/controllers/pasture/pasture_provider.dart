import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/animal.dart';
import 'pasture_cell.dart';

final pastureProvider = NotifierProvider<PastureNotifier, List<PastureCell>>(
  PastureNotifier.new,
);

class PastureNotifier extends Notifier<List<PastureCell>> {
  @override
  List<PastureCell> build() =>
      List.generate(9, (_) => PastureCell(animals: []));

  // Добавление животного в ячейку (index от 0 до 8)
  void addAnimal(int index, Animal newAnimal) {
    final cell = state[index];
    final updatedAnimals = List<Animal>.from(cell.animals);

    if (updatedAnimals.length >= 3) {
      // Логика вытеснения: находим животное с наименьшим весом
      // В реальности тут можно добавить проверку суммарного веса игрока
      updatedAnimals.sort((a, b) => a.weight.compareTo(b.weight));

      if (newAnimal.weight >= updatedAnimals.first.weight) {
        updatedAnimals.removeAt(0); // Вытесняем самого слабого
        updatedAnimals.add(newAnimal);
      } else {
        // Если новое животное слабее всех, оно не может зайти (или возвращается в руку)
        return;
      }
    } else {
      updatedAnimals.add(newAnimal);
    }

    state = [
      for (int i = 0; i < 9; i++)
        if (i == index) cell.copyWith(animals: updatedAnimals) else state[i],
    ];
  }

  // Проверка формации "Аркан" (3 в ряд) для конкретного игрока
  bool checkArkan(String playerId) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Горизонтали
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Вертикали
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
    final animals = state[index].animals;
    return animals.isNotEmpty && animals.every((a) => a.playerId == playerId);
  }

  void updateCell(int index, PastureCell newCell) {
    // Создаем новый список на основе старого состояния
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newCell else state[i],
    ];
  }
}
