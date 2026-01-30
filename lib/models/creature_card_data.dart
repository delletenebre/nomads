import 'game_card_data.dart';

/// типы разыгрываемых карт
enum CreatureCardType {
  /// барашек
  sheep,

  /// корова
  cow,

  /// верблюд
  camel,

  /// лошадь
  horse,
}

class CreatureCard extends GameCardData {
  final CreatureCardType creatureType;

  CreatureCard({
    required super.id,
    required super.playerId,
    required super.name,
    super.type = GameCardType.creature,
    required super.weight,

    required this.creatureType,
  });
}
