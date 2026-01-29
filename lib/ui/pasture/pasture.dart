import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../controllers/pasture/pasture_provider.dart';
import '../../models/animal.dart';
import '../game_cards/game_card_drop_zone.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/pasture/pasture_cell.dart';
import 'pasture_cell_view.dart';

class Pasture extends HookConsumerWidget {
  const Pasture({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;

    /// контроллер пастбища
    final pastureState = ref.watch(pastureProvider);

    return AspectRatio(
      aspectRatio: 1.0, // Чтобы поле всегда было квадратным
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.circular(24),
          // image: const DecorationImage(
          //   image: AssetImage(
          //     "assets/images/field_texture.png",
          //   ), // Фоновая текстура земли
          //   opacity: 0.2,
          //   fit: BoxFit.cover,
          // ),
        ),
        child: LayoutBuilder(
          builder: (context, constrains) {
            final cellSize = constrains.maxWidth / 3;

            return Stack(
              children: [
                Positioned(left: 0.0, top: 0.0, child: HexTile(size: cellSize)),
                Positioned(
                  left: cellSize,
                  top: 0.0,
                  child: HexTile(size: cellSize),
                ),
                Positioned(
                  left: cellSize * 2,
                  top: 0.0,
                  child: HexTile(size: cellSize),
                ),

                Positioned(
                  left: cellSize * 0.5,
                  top: cellSize * 0.8,
                  child: HexTile(size: cellSize),
                ),
                Positioned(
                  left: (cellSize * 0.5) * 3,
                  top: cellSize * 0.8,
                  child: HexTile(size: cellSize),
                ),

                Positioned(
                  left: 0.0,
                  top: cellSize * 2,
                  child: HexTile(size: cellSize),
                ),
                Positioned(
                  left: cellSize,
                  top: cellSize * 2,
                  child: HexTile(size: cellSize),
                ),
                Positioned(
                  left: cellSize * 2,
                  top: cellSize * 2,
                  child: HexTile(size: cellSize),
                ),
              ],
            );
          },
        ),
        // child: GridView.builder(
        //   physics:
        //       const NeverScrollableScrollPhysics(), // Поле не должно скроллиться
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 3,
        //     crossAxisSpacing: 10,
        //     mainAxisSpacing: 10,
        //   ),
        //   itemCount: 9,
        //   itemBuilder: (context, index) {
        //     return JaiilooCell(
        //       index: index,
        //       cell: pastureState[index],
        //       onAnimalDropped: (animal) {
        //         ref.read(pastureProvider.notifier).addAnimal(index, animal);
        //       },
        //     );
        //   },
        // ),
      ),
    );

    // return Container(
    //   width: screen.height * 0.4,
    //   height: screen.height * 0.4,
    //   child: GridView.count(
    //     crossAxisCount: 3,
    //     crossAxisSpacing: 4.0,
    //     mainAxisSpacing: 4.0,
    //     padding: const EdgeInsets.all(10.0),
    //     physics: const NeverScrollableScrollPhysics(),
    //     children: pastureState.map((cell) {
    //       return GameCardDropZone(
    //         willAcceptCard: (details) {
    //           return cell.animals.length < 3;
    //           // return acceptedTargets.contains(details.data.target);
    //         },
    //         onStatusChanged: (isAccepted, details) {
    //           // updateInsertionIndex(details?.offset);
    //         },
    //         onMove: (details) {
    //           // updateInsertionIndex(details.offset);
    //         },
    //         onLeave: (data) {},
    //         onCardDropped: (details) {
    //           /// можно разместить существо
    //           // if (details.data.type == GameCardType.creature) {
    //           //   // Добавляем карту в список в вычисленной позиции
    //           //   final index = insertionIndex.value ?? cardsOnTable.value.length;
    //           //   final newCards = List<GameCardData>.from(cardsOnTable.value);
    //           //   newCards.insert(index, details.data);
    //           //   cardsOnTable.value = newCards;
    //           // }
    //         },
    //         builder: (context, isHovered, isAccepted) {
    //           return AnimatedContainer(
    //             duration: const Duration(milliseconds: 200),
    //             curve: Curves.ease,
    //             decoration: BoxDecoration(
    //               color: isHovered
    //                   ? Colors.green.shade300
    //                   : Colors.blueGrey.shade100,
    //               borderRadius: BorderRadius.circular(8.0),
    //             ),
    //             alignment: Alignment.center,
    //             child: Text(
    //               '$item',
    //               style: const TextStyle(color: Colors.white, fontSize: 24),
    //             ),
    //           );
    //         },
    //       );
    //     }).toList(),
    //   ),
    // );
  }
}
