import 'package:flutter/foundation.dart';

import '../models/missao.dart';
import '../services/missao_service.dart';

class MissaoProvider extends ChangeNotifier {
  final _service = MissaoService();

  static const pontosPorDificuldade = {
    'Fácil': 10,
    'Médio': 20,
    'Difícil': 30,
  };

  List<Missao> _missoes = [];
  List<Missao> get missoes => _missoes;

  bool _carregando = false;
  bool get carregando => _carregando;

  // so conta as concluidas
  int get pontosConquistados {
    int total = 0;
    for (final m in _missoes) {
      if (m.concluida) total += m.pontos;
    }
    return total;
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _missoes = await _service.buscarTodas();

    _carregando = false;
    notifyListeners();
  }

  Future<void> cadastrar(String titulo, String dificuldade) async {
    final hoje = DateTime.now();
    final dia = hoje.day.toString().padLeft(2, '0');
    final mes = hoje.month.toString().padLeft(2, '0');

    final missao = Missao(
      titulo: titulo,
      dificuldade: dificuldade,
      pontos: pontosPorDificuldade[dificuldade] ?? 10,
      data: '$dia/$mes/${hoje.year}',
    );

    missao.id = await _service.adicionar(missao);
    _missoes.add(missao);
    notifyListeners();
  }

  Future<int> concluir(Missao missao) async {
    missao.concluida = true;
    await _service.atualizar(missao);
    notifyListeners();
    return missao.pontos;
  }

  Future<void> excluir(Missao missao) async {
    await _service.excluir(missao.id!);
    _missoes.remove(missao);
    notifyListeners();
  }
}
