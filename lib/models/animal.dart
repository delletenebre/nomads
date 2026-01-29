enum AnimalType { koy, uy, jylky, too }

class Animal {
  final AnimalType type;
  final String playerId; // ID владельца

  Animal({required this.type, required this.playerId});

  // Вес для механики вытеснения
  int get weight {
    switch (type) {
      case AnimalType.koy:
        return 1;
      case AnimalType.uy:
        return 2;
      case AnimalType.jylky:
        return 3;
      case AnimalType.too:
        return 5;
    }
  }

  // Очки процветания (ОП)
  int get points {
    switch (type) {
      case AnimalType.koy:
        return 1;
      case AnimalType.uy:
        return 3;
      case AnimalType.jylky:
        return 5;
      case AnimalType.too:
        return 10;
    }
  }
}
