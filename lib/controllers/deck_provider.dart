import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ulid/ulid.dart';

import '../models/creature_card_data.dart';
import '../models/game_card_data.dart';

class DeckState {
  final List<GameCardData> gameDeck;
  final List<GameCardData> player1Hand;
  final List<GameCardData> player2Hand;

  DeckState({
    this.gameDeck = const [],
    this.player1Hand = const [],
    this.player2Hand = const [],
  });

  DeckState copyWith({
    List<GameCardData>? gameDeck,
    List<GameCardData>? player1Hand,
    List<GameCardData>? player2Hand,
  }) {
    return DeckState(
      gameDeck: gameDeck ?? this.gameDeck,
      player1Hand: player1Hand ?? this.player1Hand,
      player2Hand: player2Hand ?? this.player2Hand,
    );
  }
}

class DeckNotifier extends Notifier<DeckState> {
  static const int maxHandSize = 5;

  @override
  DeckState build() {
    return DeckState(gameDeck: _createInitialDeck());
  }

  List<GameCardData> _createInitialDeck() {
    final deck = <GameCardData>[
      ...List.generate(20, (index) {
        // Double the cards for a shared deck
        final type =
            CreatureCardType.values[index % CreatureCardType.values.length];
        return CreatureCard(
          id: Ulid().toString(),
          playerId: '', // Player ID will be assigned on draw
          name: type.name,
          creatureType: type,
          weight: 1.0 + (index % 4),
        );
      }),
      ...List.generate(
        2,
        (_) => GameCardData(
          id: Ulid().toString(),
          playerId: '',
          name: 'Fog',
          type: GameCardType.event,
          weight: 0.0,
        ),
      ),
      ...List.generate(
        2,
        (_) => GameCardData(
          id: Ulid().toString(),
          playerId: '',
          name: 'Sun',
          type: GameCardType.spell,
          weight: 1.0,
        ),
      ),
    ];
    deck.shuffle();
    return deck;
  }

  GameCardData? prepareCardDraw(String playerId) {
    if (state.gameDeck.isEmpty) return null;

    // Проверяем, не заполнена ли рука, ПЕРЕД тем как брать карту
    if (playerId == '1') {
      if (state.player1Hand.length >= maxHandSize) {
        print("Player 1 hand is full. Can't draw.");
        return null; // Рука заполнена, карта не берется
      }
    } else {
      if (state.player2Hand.length >= maxHandSize) {
        print("Player 2 hand is full. Can't draw.");
        return null; // Рука заполнена, карта не берется
      }
    }

    final deck = List<GameCardData>.from(state.gameDeck);
    final card = deck.removeLast();
    card.playerId = playerId; // Assign ownership to the drawing player

    state = state.copyWith(gameDeck: deck);
    return card;
  }

  void finalizeCardDraw(GameCardData card) {
    if (card.playerId == '1') {
      final hand = List<GameCardData>.from(state.player1Hand)..add(card);
      state = state.copyWith(player1Hand: hand);
    } else {
      final hand = List<GameCardData>.from(state.player2Hand)..add(card);
      state = state.copyWith(player2Hand: hand);
    }
  }

  void removeCardFromHand(GameCardData card) {
    final hand = (card.playerId == '1' ? state.player1Hand : state.player2Hand);
    final newHand = List<GameCardData>.from(hand)
      ..removeWhere((c) => c.id == card.id);
    state = card.playerId == '1'
        ? state.copyWith(player1Hand: newHand)
        : state.copyWith(player2Hand: newHand);
  }
}

final deckProvider = NotifierProvider<DeckNotifier, DeckState>(
  DeckNotifier.new,
);
