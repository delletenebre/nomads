import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
          clipBehavior: Clip.antiAlias,
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
              String asset = 'assets/images/sheep.png';

              if (card is CreatureCard) {
                imageSize = creatureSizes[card.creatureType]!;
                child = Image.asset(
                  'assets/images/${card.creatureType.name}.png',
                  width: imageSize,
                );
                asset = 'assets/images/${card.creatureType.name}.png';
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
                // child: child,
                child: SharpToSoftGlow(
                  glowColor: card.playerId == '2'
                      ? Colors.cyanAccent
                      : Colors.red, // Яркий голубой
                  softSpread: 8.0, // Широкое мягкое свечение
                  sharpThickness: 1.5, // Тонкий четкий контур у тела
                  child: Image.asset(
                    asset, // Замените на ваш путь
                    width: imageSize,
                  ),
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

class GlowingAnimal extends StatelessWidget {
  final String assetPath;
  final Color glowColor;
  final double size;

  const GlowingAnimal({
    Key? key,
    required this.assetPath,
    this.glowColor = Colors.red, // Цвет свечения
    this.size = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      alignment: .center,
      children: [
        // --- Слой Свечения (Задний план) ---
        Positioned(
          // Сдвигаем свечение чуть вниз или оставляем по центру
          top: 0,
          child: ImageFiltered(
            // Размытие краев
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ColorFiltered(
              // srcIn перекрашивает только сам объект, игнорируя прозрачный фон
              colorFilter: ColorFilter.mode(glowColor, BlendMode.srcIn),
              child: Image.asset(
                assetPath,
                width: size * 1, // Укажите ваши размеры
                height: size * 1,
              ),
            ),
          ),
        ),

        // --- Слой Оригинала (Передний план) ---
        Image.asset(assetPath, width: size, height: size),
      ],
    );
  }
}

class SharpToSoftGlow extends StatelessWidget {
  /// Виджет, который нужно подсветить (обычно Image.asset)
  final Widget child;

  /// Цвет свечения
  final Color glowColor;

  /// Насколько далеко распространяется мягкое свечение (радиус размытия дальнего слоя)
  final double softSpread;

  /// Толщина "четкого" контура (радиус размытия ближнего слоя)
  final double sharpThickness;

  const SharpToSoftGlow({
    Key? key,
    required this.child,
    required this.glowColor,
    this.softSpread = 12.0, // Значение по умолчанию для мягкого свечения
    this.sharpThickness = 2.0, // Значение по умолчанию для четкого контура
  }) : super(key: key);

  // Вспомогательная функция для создания закрашенной копии
  Widget _buildColoredCopy(Color color) {
    return ColorFiltered(
      // Режим srcIn закрашивает только непрозрачные пиксели изображения
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior:
          Clip.none, // Важно, чтобы свечение не обрезалось контейнером
      children: [
        // --- СЛОЙ 1: Дальнее Мягкое Свечение (Задний план) ---
        Positioned(
          // Небольшие смещения, чтобы компенсировать визуальное уменьшение при сильном блюре
          top: softSpread / 4,
          left: softSpread / 4,
          right: -softSpread / 4,
          bottom: -softSpread / 4,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: softSpread,
              sigmaY: softSpread,
            ),
            // Делаем дальний свет полупрозрачным (например, 50% opacity)
            child: _buildColoredCopy(glowColor.withOpacity(0.5)),
          ),
        ),

        // --- СЛОЙ 2: Четкий Контур (Средний план) ---
        // Очень маленький блюр создает эффект четкой обводки
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: sharpThickness,
            sigmaY: sharpThickness,
          ),
          // Этот слой должен быть ярким и непрозрачным
          child: _buildColoredCopy(glowColor),
        ),

        // --- СЛОЙ 3: Оригинал (Передний план) ---
        child,
      ],
    );
  }
}
