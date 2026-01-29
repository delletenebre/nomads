import 'game_card_data.dart';

class PastureCardData extends GameCardData {
  PastureCardData({
    required super.id,
    required super.name,
    super.type = GameCardType.creature,
  });
}
