import 'package:flutter/foundation.dart';

import '../models/filme.dart';
import '../services/filme_service.dart';

class FilmeViewModel extends ChangeNotifier {
  final FilmeService _service = FilmeService();

  List<Filme> _filmes = [];
  List<Filme> get filmes => _filmes;

  bool _carregando = false;
  bool get carregando => _carregando;

  Future<void> carregarFilmes() async {
    _carregando = true;
    notifyListeners();

    _filmes = await _service.listar();

    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionarFilme(String titulo) async {
    if (titulo.trim().isEmpty) return;

    await _service.inserir(Filme(titulo: titulo.trim()));
    // busca de novo no banco pra lista ficar igual ao sqlite
    await carregarFilmes();
  }

  Future<void> alterarAssistido(Filme filme, bool valor) async {
    filme.assistido = valor;
    await _service.atualizarAssistido(filme);
    notifyListeners();
  }
}
