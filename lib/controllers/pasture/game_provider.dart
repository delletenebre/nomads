import 'package:riverpod/riverpod.dart';

// Define the state for the game
class GameState {
  final String currentPlayerId;
  // Add other game state here as needed, e.g., player scores, phase, etc.

  GameState({required this.currentPlayerId});

  GameState copyWith({String? currentPlayerId}) {
    return GameState(currentPlayerId: currentPlayerId ?? this.currentPlayerId);
  }
}

// Define the Notifier for the game state
final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => GameState(currentPlayerId: '1'); // Player 1 starts

  void endTurn() => state = state.copyWith(
    currentPlayerId: state.currentPlayerId == '1' ? '2' : '1',
  );
}
