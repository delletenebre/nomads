import '../../models/animal.dart';

class PastureCell {
  final List<Animal> animals;
  final int grassLevel; // 0-5

  PastureCell({required this.animals, this.grassLevel = 5});

  // Метод для копирования состояния
  PastureCell copyWith({List<Animal>? animals, int? grassLevel}) {
    return PastureCell(
      animals: animals ?? this.animals,
      grassLevel: grassLevel ?? this.grassLevel,
    );
  }
}
