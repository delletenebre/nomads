import '../../models/game_card_data.dart';

class PastureCell {
  final List<GameCardData> cards;
  final int grassLevel; // 0-5

  PastureCell({required this.cards, this.grassLevel = 5});

  // Метод для копирования состояния
  PastureCell copyWith({List<GameCardData>? cards, int? grassLevel}) {
    return PastureCell(
      cards: cards ?? this.cards,
      grassLevel: grassLevel ?? this.grassLevel,
    );
  }
}
