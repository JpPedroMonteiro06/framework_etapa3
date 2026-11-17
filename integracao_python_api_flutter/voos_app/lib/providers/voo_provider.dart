// Estado da aplicação: guarda os voos, o carregamento e os erros.
//
//   Page -> Provider -> Service -> API Python
//   API Python -> Service -> Provider -> notifyListeners() -> Page
//
// O Provider não sabe fazer HTTP (isso é do Service) e não sabe desenhar
// widgets (isso é das Pages). Ele só sabe QUAIS dados o app tem agora.

import 'package:flutter/foundation.dart';

import '../models/resultado_voos.dart';
import '../models/voo.dart';
import '../services/voo_service.dart';

/// Opções aceitas pela API no parâmetro `tipo`.
enum TipoBusca {
  chegadas('chegadas', 'Chegadas'),
  partidas('partidas', 'Partidas'),
  todos('todos', 'Todos');

  const TipoBusca(this.valor, this.rotulo);

  /// Valor enviado na query string.
  final String valor;
  final String rotulo;
}

class VooProvider extends ChangeNotifier {
  VooProvider({VooService? service}) : _service = service ?? VooService();

  final VooService _service;

  ResultadoVoos? _resultado;
  bool _carregando = false;
  String? _erro;
  String _aeroporto = 'SBGR';
  TipoBusca _tipo = TipoBusca.todos;
  String _filtro = '';

  /// Última resposta recebida da API (null enquanto nada foi carregado).
  ResultadoVoos? get resultado => _resultado;

  bool get carregando => _carregando;

  /// Mensagem de erro da última tentativa, ou null se deu tudo certo.
  String? get erro => _erro;

  String get aeroporto => _aeroporto;

  TipoBusca get tipo => _tipo;

  /// Texto digitado no campo de filtro (aplicado só na memória do app).
  String get filtro => _filtro;

  /// True quando já houve uma busca bem-sucedida sem nenhum voo no painel.
  bool get vazio =>
      !_carregando && _erro == null && _resultado != null && _voos.isEmpty;

  bool get temFiltroAtivo => _filtro.trim().isNotEmpty;

  List<Voo> get _voos => _resultado?.voos ?? const <Voo>[];

  /// Todos os voos recebidos, já aplicando o filtro de texto local.
  List<Voo> get voos =>
      _voos.where((voo) => voo.combinaCom(_filtro)).toList(growable: false);

  /// Quantos voos a API devolveu, antes do filtro local.
  int get totalRecebido => _resultado?.total ?? _voos.length;

  /// Voos agrupados por categoria, na ordem em que devem aparecer na tela.
  /// Categorias sem nenhum voo (depois do filtro) ficam de fora.
  Map<CategoriaVoo, List<Voo>> get voosPorCategoria {
    const ordem = [
      CategoriaVoo.chegadas,
      CategoriaVoo.emRota,
      CategoriaVoo.partidas,
      CategoriaVoo.partidasProgramadas,
      CategoriaVoo.desconhecida,
    ];

    final agrupados = <CategoriaVoo, List<Voo>>{};
    for (final voo in voos) {
      agrupados.putIfAbsent(voo.categoria, () => <Voo>[]).add(voo);
    }

    return {
      for (final categoria in ordem)
        if (agrupados[categoria]?.isNotEmpty ?? false)
          categoria: agrupados[categoria]!,
    };
  }

  /// Busca os voos na API com o aeroporto e o tipo escolhidos.
  Future<void> carregarVoos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _resultado = await _service.buscarVoos(
        aeroporto: _aeroporto,
        tipo: _tipo.valor,
      );
    } on VooServiceException catch (erro) {
      _erro = erro.mensagem;
      _resultado = null;
    } catch (erro) {
      _erro = 'Erro inesperado ao carregar os voos: $erro';
      _resultado = null;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Troca o aeroporto (código ICAO) e recarrega.
  /// Devolve false quando o código não tem o formato aceito pela API.
  Future<bool> buscarPorAeroporto(String codigo) async {
    final novo = codigo.trim().toUpperCase();
    if (novo.length != 4 || !RegExp(r'^[A-Z]{4}$').hasMatch(novo)) {
      return false;
    }
    _aeroporto = novo;
    await carregarVoos();
    return true;
  }

  /// Troca entre chegadas / partidas / todos e recarrega.
  Future<void> alterarTipo(TipoBusca novoTipo) async {
    if (novoTipo == _tipo && _resultado != null) return;
    _tipo = novoTipo;
    await carregarVoos();
  }

  /// Filtro local: não chama a API de novo, só reduz a lista já carregada.
  void alterarFiltro(String texto) {
    if (texto == _filtro) return;
    _filtro = texto;
    notifyListeners();
  }

  void limparFiltro() => alterarFiltro('');

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
