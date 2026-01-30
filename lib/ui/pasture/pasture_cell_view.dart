import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../models/game_card_data.dart';
import 'cell_drop_zone.dart';

class HexTile<T extends Object> extends StatelessWidget {
  final void Function(T) onCardDropped;
  final List<GameCardData> cards;
  final double size;

  const HexTile({
    super.key,
    required this.size,
    this.cards = const [],
    required this.onCardDropped,
  });

  @override
  Widget build(BuildContext context) {
    final sheepSize = size * 0.42;
    return CellDropZone<T>(
      willAcceptCard: (details) => true,
      onCardDropped: (details) {
        onCardDropped.call(details.data);
      },
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
                child: Stack(children: [
                    
                  ],
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

            ...cards.mapIndexed((index, card) {
              double leftMult, topMult;

              // ЛОГИКА РАССТАНОВКИ ТРЕУГОЛЬНИКОМ (ПИРАМИДОЙ)
              if (index == 0) {
                // --- Элемент 1: Верхний левый ---
                leftMult = 0.1;
                topMult = 0.1;
              } else if (index == 1) {
                // --- Элемент 2: Верхний правый ---
                // Отступ слева + 1 полная ширина
                leftMult = 1.1;
                topMult = 0.1;
              } else {
                // --- Элемент 3: Нижний центральный ---
                // По горизонтали: ровно между 0.1 и 1.1 -> (0.1 + 1.1) / 2 = 0.6
                leftMult = 0.6;
                // По вертикали: отступ сверху + шаг вниз (0.8) -> 0.1 + 0.8 = 0.9
                topMult = 0.9;
              }

              return Positioned(
                top: sheepSize * topMult,
                left: sheepSize * leftMult,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    card.playerId == '2'
                        ? Colors.transparent
                        : Colors.red.withAlpha(100),
                    BlendMode.srcATop,
                  ),
                  child: Image.asset(
                    'assets/images/sheep.png',
                    width: sheepSize,
                  ),
                ),
              );
            }),

            // Positioned(
            //   left: sheepSize * 1.1,
            //   top: sheepSize * 0.1,
            //   child: Image.asset('assets/images/sheep.png', width: sheepSize),
            // ),

            // Positioned(
            //   left: sheepSize * 0.62,
            //   top: sheepSize * 0.72,
            //   child: Image.asset('assets/images/sheep.png', width: sheepSize),
            // ),
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
