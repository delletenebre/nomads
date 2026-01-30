import '../../../models/game_card_data.dart';
import '../pasture_provider.dart';
import 'pasture_event.dart';

class WolfEvent extends PastureEvent {
  WolfEvent()
    : super(
        name: "Жырткыч (Волк)",
        description:
            "Волк съедает одну овцу в клетке с самым большим количеством животных.",
      );

  @override
  void apply(PastureNotifier notifier) {
    int targetIndex = -1;
    int maxAnimals = 0;

    // Ищем самую населенную клетку
    for (int i = 0; i < notifier.state.length; i++) {
      if (notifier.state[i].cards.length > maxAnimals) {
        maxAnimals = notifier.state[i].cards.length;
        targetIndex = i;
      }
    }

    if (targetIndex != -1) {
      var animals = List<GameCardData>.from(notifier.state[targetIndex].cards);
      // Волк съедает самое слабое животное (обычно овцу)
      animals.sort((a, b) => a.weight.compareTo(b.weight));
      animals.removeAt(0);

      notifier.updateCell(
        targetIndex,
        notifier.state[targetIndex].copyWith(cards: animals),
      );
    }
  }
}
