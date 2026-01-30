import 'dart:math';

import '../pasture_provider.dart';
import 'pasture_event.dart';

class BoronEvent extends PastureEvent {
  BoronEvent()
    : super(
        name: "Борон (Буран)",
        description:
            "Случайная клетка замерзает. Весь скот возвращается в руку владельцам.",
      );

  @override
  void apply(PastureNotifier notifier) {
    // Выбираем случайную клетку
    final randomIndex = Random().nextInt(9);

    // Получаем текущее состояние ячейки
    final cell = notifier.state[randomIndex];

    // В реальности здесь нужно вызвать метод возврата карт в руку игрокам
    // А на поле — очистить список животных
    notifier.updateCell(randomIndex, cell.copyWith(cards: []));

    // Можно также временно снизить уровень травы (заморозки)
    print("Буран ударил по клетке $randomIndex!");
  }
}
