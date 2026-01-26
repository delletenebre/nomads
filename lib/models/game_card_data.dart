/// цель расположения карты
enum GameCardTarget {
  /// мой стол
  myTable,

  /// стол противника
  opTable,

  /// мой юнит
  myUnit,

  /// юнит противника
  opUnit,
}

/// типы карты
enum GameCardType {
  /// животное
  creature,

  /// заклинание
  spell,

  /// проклятье
  debuff,
}

class GameCardData {
  final String id;
  final String name;
  final GameCardTarget target;
  final GameCardType type;

  GameCardData({
    required this.id,
    required this.name,
    required this.target,
    required this.type,
  });
}
