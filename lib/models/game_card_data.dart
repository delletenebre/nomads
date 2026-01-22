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

class GameCardData {
  final String name;
  final GameCardTarget target;

  GameCardData({required this.name, required this.target});
}
