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

abstract class GameCardData {
  final String id;
  final String name;
  // final GameCardTarget target;
  final GameCardType type;

  GameCardData({
    required this.id,
    required this.name,
    // required this.target,
    required this.type,
  });
}
