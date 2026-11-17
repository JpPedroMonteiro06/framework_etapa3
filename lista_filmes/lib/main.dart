import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/pagina_inicial.dart';
import 'viewmodels/filme_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FilmeViewModel()..carregarFilmes(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Lista de Filmes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const PaginaInicial(),
    );
  }
}
