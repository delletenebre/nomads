import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

import '../../models/game_card_data.dart';
import 'cell_drop_zone.dart';

// class AnimatedAnimalToken extends StatelessWidget {
//   final Animal animal;
//   final Key? key; // Важно для AnimatedSwitcher

//   const AnimatedAnimalToken({required this.animal, this.key}) : super(key: key);

//   String _getAnimalEmoji(AnimalType type) {
//     switch (type) {
//       case AnimalType.koy:
//         return "🐑";
//       case AnimalType.uy:
//         return "🐄";
//       case AnimalType.jylky:
//         return "🐎";
//       case AnimalType.too:
//         return "🐪";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 30,
//       height: 30,
//       decoration: BoxDecoration(
//         color: animal.playerId == "me" ? Colors.blue[100] : Colors.red[100],
//         shape: BoxShape.circle,
//         border: Border.all(color: Colors.black26),
//       ),
//       child: Center(
//         child: Text(
//           _getAnimalEmoji(animal.type),
//           style: const TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
// }

class HexTile extends StatelessWidget {
  final double size;

  const HexTile({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CellDropZone(
      willAcceptCard: (details) => true,
      onCardDropped: (details) {},
      onStatusChanged: (isAccepted, details) {},
      builder: (context, isHovered, isAccepted) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // --- СЛОЙ 1: ОСНОВА (Картинка + Черная обводка + Тень) ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: size,
              width: size,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                // Используем твою картинку
                image: DecorationImage(
                  image: AssetImage('assets/images/grass.png'),
                  fit: BoxFit.cover,
                ),
                shape: StarBorder(
                  // Тонкая черная граница по самому краю
                  side: const BorderSide(color: Colors.black, width: 1.0),
                  points: 3,
                  innerRadiusRatio: 1.0,
                  pointRounding: 0.05,
                  valleyRounding: 0.05,
                  rotation: 0.0,
                  squash: 1.0,
                ),
                shadows: [
                  // Тень под кнопкой
                  BoxShadow(
                    color: const Color(0xff405924),
                    offset: Offset(0.0, size * 0.06),
                    blurRadius: 0.0,
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: size,
                width: size,
                decoration: BoxDecoration(
                  color: isHovered ? Colors.green.withAlpha(100) : null,
                ),
                child: // --- СЛОЙ 3: ТЕКСТ ---
                const Center(
                  child: Text(
                    'Star',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // --- СЛОЙ 2: ОБЪЕМНЫЙ БЛИК (ИСПРАВЛЕННЫЙ) ---
            Positioned.fill(
              child: Padding(
                // Чуть отступаем внутрь, чтобы не закрывать черную рамку слоя 1
                padding: const EdgeInsets.all(1.0),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withAlpha(255), // Яркий блик сверху
                        Colors.black.withAlpha(255), // Тень снизу
                      ],
                      // Где начинаются и заканчиваются цвета (0.0 - верх, 1.0 - низ)
                      stops: const [0.0, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: StarBorder(
                        // Эта обводка служит "холстом" для полупрозрачного градиента
                        side: BorderSide(
                          color: Colors.white.withAlpha(
                            100,
                          ), // Цвет не важен, его заменит маска
                          width: size * 0.05, // Толщина блика (можно менять)
                        ),
                        points: 3,
                        innerRadiusRatio: 1.0,
                        pointRounding: 0.05,
                        valleyRounding: 0.05,
                        rotation: 0.0,
                        squash: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Вспомогательный виджет для прогресс-бара
  Widget _buildProgressBar(double value, {double width = 50}) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black45, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC5E1A5)),
        ),
      ),
    );
  }
}
