import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'controllers/shaders/shader_manager.dart';
import 'game.dart';

Future<void> main() async {
  /// ожидаем инициализации модуля взаимодействия с нативным кодом
  WidgetsFlutterBinding.ensureInitialized();

  /// инициализация шейдеров
  final shadersManager = await ShadersManager.getInstance();

  /// инициализируем локальное хранилище
  final sharedStorage = await SharedPreferences.getInstance();

  /// инициализируем защищённое хранилище
  const secureStorage = FlutterSecureStorage();

  runApp(
    ProviderScope(
      retry: null,
      overrides: [
        shadersProvider.overrideWithValue(shadersManager),

        // storageProvider.overrideWithValue(
        //   Storage(sharedStorage: sharedStorage, secureStorage: secureStorage),
        // ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(title: 'Nomads CCG', home: const Game());
      },
    );
  }
}
