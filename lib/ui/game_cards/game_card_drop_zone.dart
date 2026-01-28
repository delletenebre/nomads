import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../models/game_card_data.dart';

class GameCardDropZone extends HookWidget {
  final bool Function(DragTargetDetails<GameCardData> details) willAcceptCard;
  final void Function(DragTargetDetails<GameCardData> details) onCardDropped;
  final void Function(GameCardData? card)? onLeave;
  final void Function(
    bool isAccepted,
    DragTargetDetails<GameCardData>? details,
  )?
  onStatusChanged;
  final void Function(DragTargetDetails<GameCardData> details)? onMove;
  final Widget Function(BuildContext context, bool isHovered, bool isAccepted)
  builder;

  const GameCardDropZone({
    super.key,
    this.onLeave,
    this.onStatusChanged,
    this.onMove,
    required this.builder,
    required this.willAcceptCard,
    required this.onCardDropped,
  });

  @override
  Widget build(BuildContext context) {
    /// карта над зоной или нет
    final isHovered = useState(false);

    /// можно или нельзя разместить карту
    final isAccepted = useState(false);

    return DragTarget<GameCardData>(
      onWillAcceptWithDetails: (details) {
        final isCardAccepted = willAcceptCard(details);

        isHovered.value = true;
        isAccepted.value = isCardAccepted;

        onStatusChanged?.call(isCardAccepted, details);

        return isCardAccepted;
      },
      onMove: onMove,
      onLeave: (data) {
        isHovered.value = false;
        isAccepted.value = false;
        onStatusChanged?.call(false, null);
      },
      onAcceptWithDetails: (details) {
        onCardDropped(details);

        isHovered.value = false;
        isAccepted.value = false;
        onStatusChanged?.call(false, null);
      },
      builder: (context, candidateData, rejectedData) {
        return builder(context, isHovered.value, isAccepted.value);
      },
    );
  }
}
