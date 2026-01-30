import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../models/creature_card_data.dart';
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
    final width = size * 1.1;
    final height = size * 0.9;
    final sheepSize = size * 0.42;
    final creatureSizes = {
      CreatureCardType.sheep: size * 0.32,
      CreatureCardType.cow: size * 0.5,
      CreatureCardType.camel: size * 0.5,
    };
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
              width: width,
              height: size,
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
                width: width,
                height: size * 0.9,
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
              Widget child = Image.asset(
                'assets/images/sheep.png',
                width: sheepSize,
              );
              double imageSize = sheepSize;

              if (card is CreatureCard) {
                imageSize = creatureSizes[card.creatureType]!;
                child = Image.asset(
                  'assets/images/${card.creatureType.name}.png',
                  width: imageSize,
                );
              }

              // 1. Grid Logic
              final col = index % 2;
              final row = index ~/ 2;

              final paddingX = (width * 0.1);
              final paddingY = (size * 0.2);
              final gridSizeX = width - paddingX * 2.0;
              final gridSizeY = size - paddingY * 2.0;
              final cellSizeX = gridSizeX * 0.5;
              final cellSizeY = gridSizeY * 0.5;

              final cellCenterX = (col * cellSizeX) + (cellSizeX / 2);
              final cellCenterY = (row * cellSizeX) + (cellSizeY / 2);

              // 4. Calculate final position
              // Start with Padding + Cell Center - Half the Item Size
              final left = paddingX + cellCenterX - (imageSize / 2);
              final top = paddingX + cellCenterY - (imageSize / 2);

              return Positioned(
                top: top,
                left: left,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    card.playerId == '2'
                        ? Colors.transparent
                        : Colors.red.withAlpha(100),
                    BlendMode.srcATop,
                  ),
                  child: child,
                ),
              );
            }),
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
