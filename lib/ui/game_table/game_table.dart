import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GameTable extends HookWidget {
  const GameTable({super.key});

  @override
  Widget build(BuildContext context) {
    final isAccepted = useState(false);

    return DragTarget(
      onWillAcceptWithDetails: (details) {
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        return isAccepted.value
            ? Container(color: Colors.green.shade300)
            : Container();
      },
    );
  }
}
