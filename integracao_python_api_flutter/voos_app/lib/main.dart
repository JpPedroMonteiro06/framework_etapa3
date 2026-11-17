// Aula 19 - Integração Python API + Flutter
//
// FLIGHTAWARE -> WEB SCRAPING -> PYTHON/FLASK -> API JSON
//   -> FLUTTER -> SERVICE -> PROVIDER -> PAGES -> USUÁRIO
//
// O main só monta o app: registra o Provider e abre a HomePage.

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/voo_provider.dart';

void main() {
  runApp(
    DevicePreview(
      // Em release o app roda normalmente, sem a moldura de simulação.
      enabled: !kReleaseMode,
      builder: (context) => const VoosApp(),
    ),
  );
}

class VoosApp extends StatelessWidget {
  const VoosApp({super.key});

  static const Color _semente = Color(0xFF0B5FFF);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VooProvider(),
      child: MaterialApp(
        title: 'Painel de Voos',
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        themeMode: ThemeMode.system,
        theme: tema(Brightness.light),
        darkTheme: tema(Brightness.dark),
        home: const HomePage(),
      ),
    );
  }

  ThemeData tema(Brightness brilho) {
    final cores = ColorScheme.fromSeed(
      seedColor: _semente,
      brightness: brilho,
    );

    return ThemeData(
      colorScheme: cores,
      useMaterial3: true,
      // A AppBar usa a mesma cor do bloco de busca da HomePage,
      // para os dois formarem um cabeçalho único.
      appBarTheme: AppBarTheme(
        backgroundColor: cores.primaryContainer,
        foregroundColor: cores.onPrimaryContainer,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cores.outlineVariant),
        ),
      ),
    );
  }
}
