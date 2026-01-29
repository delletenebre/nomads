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
    // Настройка формы шестиугольника
    final hexagonShape = PolygonShapeBorder(
      sides: 6,
      cornerRadius: 10.toPercentLength,
      cornerStyle: CornerStyle.rounded,
    );

    return Center(
      child: Container(
        width: size,
        height: size,
        // Используем Stack для размещения элементов внутри
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Нижний слой - Тень для объема
            Container(
              decoration: ShapeDecoration(
                shape: hexagonShape,
                color: const Color(0xFF3B5B28), // Темно-зеленый для глубины
              ),
              margin: const EdgeInsets.only(top: 10), // Смещение тени вниз
            ),

            // 2. Основное тело плитки
            Container(
              decoration: ShapeDecoration(
                shape: hexagonShape,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFAED581), // Светло-зеленый верх
                    Color(0xFF8BC34A), // Темнее низ
                  ],
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),

            // 3. Содержимое (Индикаторы и декорации)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Верхний прогресс-бар
                  _buildProgressBar(0.7, width: 80),

                  // Здесь могут быть ваши камни/цветы (картинки или иконки)
                  const Spacer(),

                  // Нижний блок с индикаторами
                  Column(
                    children: [
                      _buildProgressBar(0.4, width: 60),
                      const SizedBox(height: 5),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle_outlined, size: 12),
                          SizedBox(width: 4),
                          Icon(
                            Icons.circle_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.circle_outlined, size: 12),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
