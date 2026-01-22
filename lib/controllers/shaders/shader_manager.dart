import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'shader_type.dart';

final shadersProvider = Provider<ShadersManager>((ref) {
  throw UnimplementedError('ShaderManager must be initialized');
});

class ShadersManager {
  // 1. Приватное хранилище
  final Map<ShaderType, FragmentProgram> _programs = {};

  ShadersManager._();

  /// инициализация
  static Future<ShadersManager> getInstance() async {
    final manager = ShadersManager._(); // Создаем экземпляр
    await manager._loadShaders(); // Загружаем всё
    return manager; // Возвращаем готовый объект
  }

  // внутренняя логика загрузки
  Future<void> _loadShaders() async {
    for (final type in ShaderType.values) {
      try {
        final program = await FragmentProgram.fromAsset(type.path);
        _programs[type] = program;
      } catch (e) {
        debugPrint("Shader error [${type.name}]: $e");
      }
    }
  }

  FragmentProgram getProgram(ShaderType type) => _programs[type]!;
}
