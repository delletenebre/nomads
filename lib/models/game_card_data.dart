// /// цель расположения карты
// enum GameCardTarget {
//   /// мой стол
//   myTable,

//   /// стол противника
//   opponentTable,

//   /// мой юнит
//   myUnit,

//   /// юнит противника
//   opponentUnit,
// }

/// типы карты
enum GameCardType {
  /// животное
  creature,

  /// баатыр
  hero,

  /// заклинание
  spell,

  /// событие
  event,
}

class GameCardData {
  final String id;
  String playerId;
  final String name;
  // final GameCardTarget target;
  final GameCardType type;
  final double weight;

  GameCardData({
    required this.id,
    required this.playerId,
    required this.name,
    // required this.target,
    required this.type,
    required this.weight,
  });
}
