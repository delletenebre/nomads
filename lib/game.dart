import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';

import 'controllers/deck_provider.dart';
import 'controllers/pasture/game_provider.dart';
import 'models/game_card_data.dart';
import 'ui/effects/card_draw_animation.dart';
// import 'ui/game_deck/game_deck.dart';
import 'ui/effects/game_deck.dart';
import 'ui/game_hand/game_hand.dart';
import 'ui/pasture/pasture.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Game extends HookConsumerWidget {
  const Game({super.key});

  // Ключи для получения позиций виджетов
  static final _gameDeckKey = GlobalKey();
  static final _player1HandKey = GlobalKey();
  static final _player2HandKey = GlobalKey();

  void _drawCardWithAnimation(
    BuildContext context,
    WidgetRef ref,
    String playerId,
  ) {
    final deckNotifier = ref.read(deckProvider.notifier);
    final cardToDraw = deckNotifier.prepareCardDraw(playerId);

    if (cardToDraw == null) return; // Колода пуста или рука полна

    final deckKey = _gameDeckKey;
    final handKey = playerId == '1' ? _player1HandKey : _player2HandKey;

    final deckRenderBox =
        deckKey.currentContext?.findRenderObject() as RenderBox?;
    final handRenderBox =
        handKey.currentContext?.findRenderObject() as RenderBox?;

    if (deckRenderBox == null || handRenderBox == null) {
      // Если ключи не готовы, просто добавляем карту в руку без анимации
      deckNotifier.finalizeCardDraw(cardToDraw);
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    // Вычисляем центр экрана для паузы, с поправкой на максимальный размер карты в полете
    final centerScreen = Offset(
      screenSize.width / 2 - (63.0 * 1.6 / 2),
      screenSize.height / 2 - (88.0 * 1.6 / 2),
    );

    final deckPosition = deckRenderBox.localToGlobal(Offset.zero);

    // --- NEW LOGIC for endPosition ---
    // Replicate GameHand logic to find the card's final destination
    final deckState = ref.read(deckProvider);
    final hand = playerId == '1'
        ? deckState.player1Hand
        : deckState.player2Hand;
    final cardsInHandCount = hand.length;

    // Card properties must match GameHand
    const cardWidth = 63.0;
    const cardHeight = 88.0;
    const spacingFactor = 0.8;

    // Calculate position for the new card which will be at the end of the list
    final newCardIndex = cardsInHandCount;
    final totalCardsAfterDraw = cardsInHandCount + 1;

    final centerIndex = (totalCardsAfterDraw - 1) / 2.0;
    final offsetFromCenter = newCardIndex - centerIndex;

    final spacingX = cardWidth * spacingFactor;
    final translateX = offsetFromCenter * spacingX;

    final containerWidth = handRenderBox.size.width;
    final leftPos = (containerWidth / 2) + translateX - (cardWidth / 2);

    // This is from GameHand.dart
    final bottomPos = cardHeight / 8;

    final localEndY = handRenderBox.size.height - bottomPos - cardHeight;
    final localEndPosition = Offset(leftPos, localEndY);

    final handPosition = handRenderBox.localToGlobal(localEndPosition);

    const maxAngle = 0.125;
    final finalRotation =
        Random(cardToDraw.hashCode).nextDouble() * (maxAngle * 2) - maxAngle;

    final bool shouldPauseForPlayer = playerId == '1';

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => CardDrawAnimation(
        card: cardToDraw,
        startPosition: deckPosition,
        pausePosition: centerScreen,
        endPosition: handPosition,
        finalRotation: finalRotation,
        shouldPause: shouldPauseForPlayer,
        onComplete: () {
          deckNotifier.finalizeCardDraw(cardToDraw);
          overlayEntry?.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckState = ref.watch(deckProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final gameState = ref.watch(gameProvider);

    ref.listen(gameProvider.select((s) => s.currentPlayerId), (previous, next) {
      // We only want to draw a card when the turn *changes* to a new player,
      // not on the initial build.
      if (previous != null && previous != next) {
        // Schedule the animation for after the current frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _drawCardWithAnimation(context, ref, next);
          }
        });
      }
    });

    useEffect(() {
      // Начальная раздача карт при первом рендере
      void dealInitialCards() async {
        // Задержка, чтобы UI успел отрисоваться и ключи стали доступны
        await Future.delayed(const Duration(milliseconds: 500));

        // 1. Раздаем карты противнику быстро, почти одновременно
        for (var i = 0; i < 3; i++) {
          if (context.mounted) _drawCardWithAnimation(context, ref, '2');
          await Future.delayed(const Duration(milliseconds: 200));
        }

        // Ждем, пока последняя карта противника долетит до руки
        await Future.delayed(const Duration(milliseconds: 1200));

        // 2. Раздаем карты игроку: все вместе летят в центр, а потом в руку
        if (!context.mounted) return;

        final deckNotifier = ref.read(deckProvider.notifier);
        final List<GameCardData> cardsToDeal = [];
        for (int i = 0; i < 3; i++) {
          final card = deckNotifier.prepareCardDraw('1');
          if (card != null) cardsToDeal.add(card);
        }

        if (cardsToDeal.isEmpty) return;

        final List<GlobalKey<CardDrawAnimationState>> keys = List.generate(
          cardsToDeal.length,
          (_) => GlobalKey(),
        );
        final List<OverlayEntry> overlays = [];

        // --- Настройка оверлеев для каждой карты ---
        for (int i = 0; i < cardsToDeal.length; i++) {
          final card = cardsToDeal[i];
          final key = keys[i];

          final deckRenderBox =
              _gameDeckKey.currentContext?.findRenderObject() as RenderBox?;
          final handRenderBox =
              _player1HandKey.currentContext?.findRenderObject() as RenderBox?;
          if (deckRenderBox == null || handRenderBox == null) continue;

          final screenSize = MediaQuery.of(context).size;
          final centerOffsetX =
              (i - 1) * 90.0; // Расстояние между картами в центре
          final centerScreen = Offset(
            (screenSize.width / 2 - (63.0 * 1.6 / 2)) + centerOffsetX,
            screenSize.height / 2 - (88.0 * 1.6 / 2),
          );

          final deckPosition = deckRenderBox.localToGlobal(Offset.zero);

          // Расчет финальной позиции в руке
          const cardWidth = 63.0;
          const cardHeight = 88.0;
          const spacingFactor = 0.8;
          final centerIndex = (cardsToDeal.length - 1) / 2.0;
          final offsetFromCenter = i - centerIndex;
          final translateX = offsetFromCenter * (cardWidth * spacingFactor);
          final containerWidth = handRenderBox.size.width;
          final leftPos = (containerWidth / 2) + translateX - (cardWidth / 2);
          const bottomPos = cardHeight / 8;
          final localEndY = handRenderBox.size.height - bottomPos - cardHeight;
          final handPosition = handRenderBox.localToGlobal(
            Offset(leftPos, localEndY),
          );
          const maxAngle = 0.125;
          final finalRotation =
              Random(card.hashCode).nextDouble() * (maxAngle * 2) - maxAngle;

          overlays.add(
            OverlayEntry(
              builder: (context) => CardDrawAnimation(
                key: key,
                card: card,
                startPosition: deckPosition,
                pausePosition: centerScreen,
                endPosition: handPosition,
                finalRotation: finalRotation,
                shouldPause: true,
                autoStart: false, // Отключаем авто-старт для ручного управления
                onComplete: () {},
              ),
            ),
          );
        }

        Overlay.of(context).insertAll(overlays);

        // Ждем конца кадра, чтобы виджеты в оверлее гарантированно создали свои состояния.
        await WidgetsBinding.instance.endOfFrame;

        // --- Фаза 1: Анимация в центр с задержкой ---
        final animationToCenterDurationMs = (1200 * 0.55).round();
        const delayMs = 250; // Задержка между картами

        for (int i = 0; i < keys.length; i++) {
          // Запускаем анимацию для каждой карты с нарастающей задержкой.
          // Не используем await, чтобы анимации запускались параллельно.
          Future.delayed(Duration(milliseconds: i * delayMs), () {
            keys[i].currentState?.animateToCenter();
          });
        }

        // Ждем, пока последняя карта завершит свой полет в центр.
        final totalWaitMs =
            (keys.length - 1) * delayMs + animationToCenterDurationMs;
        await Future.delayed(Duration(milliseconds: totalWaitMs));

        // --- Фаза 2: Пауза для прочтения ---
        await Future.delayed(const Duration(milliseconds: 1500));

        // --- Фаза 3: Анимация в руку ---
        final toHandFutures = keys
            .map((k) => k.currentState!.animateToHand())
            .toList();
        await Future.wait(toHandFutures);

        // --- Фаза 4: Завершение и очистка ---
        for (final card in cardsToDeal) {
          deckNotifier.finalizeCardDraw(card);
        }
        for (final overlay in overlays) {
          overlay.remove();
        }
      }

      dealInitialCards();
      return null;
    }, const []);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GameHand(
                  key: _player2HandKey, // Рука оппонента (сверху)
                  cards: deckState.player2Hand,
                  cardWidth: 63.0,
                  cardHeight: 88.0,
                  spacingFactor: 0.8,
                  focusedCardId: '',
                  hoveredCardId: '',
                  onCardTap: (String id) {},
                  onCardHover: (String id, bool isHover) {},
                  isInteractive: gameState.currentPlayerId == '2',
                ),
              ),
              Expanded(flex: 3, child: Pasture()),
              Expanded(
                child: GameHand(
                  key: _player1HandKey, // Рука игрока (снизу)
                  cards: deckState.player1Hand,
                  cardWidth: 63.0,
                  cardHeight: 88.0,
                  spacingFactor: 0.8,
                  focusedCardId: '',
                  hoveredCardId: '',
                  onCardTap: (String id) {},
                  onCardHover: (String id, bool isHover) {},
                  isInteractive: gameState.currentPlayerId == '1',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    gameNotifier.endTurn(); // The listener will handle the rest
                  },
                  child: Text(
                    'End Turn (Current: Player ${gameState.currentPlayerId})',
                  ),
                ),
              ),
            ],
          ),
          // --- Слой с колодами ---
          Positioned(
            top: 0,
            bottom: 0,
            right: 20,
            child: Center(
              // A single deck in the middle
              child: GameDeck(
                key: _gameDeckKey,
                cardCount: deckState.gameDeck.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
