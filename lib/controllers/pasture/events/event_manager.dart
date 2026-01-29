import 'dart:math';

import '../pasture_provider.dart';
import 'boron_event.dart';
import 'pasture_event.dart';
import 'wolf_event.dart';

class EventManager {
  final List<PastureEvent> deck = [
    BoronEvent(),
    WolfEvent(),
    // Добавьте сюда "Той", "Жайлоо" и т.д.
  ];

  void triggerRandomEvent(PastureNotifier notifier) {
    final event = deck[Random().nextInt(deck.length)];
    // 1. Показать UI-анимацию события (например, экран трясется)
    // 2. Применить эффект
    event.apply(notifier);
  }
}
