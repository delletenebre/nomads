import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import 'playes_table.dart';

class GameTable extends HookWidget {
  const GameTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isTableAccepted = useState(false);
    final isAcceptedPlayerTable = useState(false);
    final isAcceptedOpponentTable = useState(false);

    // Helper to update the main table status based on sub-zones
    void checkTableStatus() {
      isTableAccepted.value =
          isAcceptedPlayerTable.value || isAcceptedOpponentTable.value;
    }

    return Container(
      padding: const .all(24.0),
      height: 40.0.h,
      color: isTableAccepted.value
          ? Colors.orange.withAlpha(32)
          : Colors.transparent,
      child: Column(
        children: [
          /// стол противника
          Expanded(
            child: PlayerTable(
              onStatusChanged: (isAccepted) {
                isAcceptedOpponentTable.value = isAccepted;
                checkTableStatus();
              },
            ),
          ),

          /// стол игрока
          Expanded(
            child: PlayerTable(
              onStatusChanged: (isAccepted) {
                isAcceptedPlayerTable.value = isAccepted;
                checkTableStatus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
