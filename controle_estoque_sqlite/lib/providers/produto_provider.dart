import 'package:flutter/foundation.dart';

import '../models/produto.dart';
import '../services/produto_service.dart';

class ProdutoProvider extends ChangeNotifier {
  final _service = ProdutoService();

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  bool _carregando = false;
  bool get carregando => _carregando;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _produtos = await _service.listar();
    _carregando = false;
    notifyListeners();
  }

  Future<void> cadastrar(
      String nome, String categoria, int quantidade, double preco) async {
    await _service.cadastrar(Produto(
      nome: nome,
      categoria: categoria,
      quantidade: quantidade,
      preco: preco,
    ));
    await carregar();
  }

  Future<void> incrementar(Produto produto) =>
      _alterar(produto, produto.quantidade + 1);

  Future<void> decrementar(Produto produto) async {
    if (produto.quantidade == 0) return;
    await _alterar(produto, produto.quantidade - 1);
  }

  Future<void> _alterar(Produto produto, int novaQuantidade) async {
    await _service.alterarQuantidade(produto, novaQuantidade);
    produto.quantidade = novaQuantidade;
    notifyListeners();
  }

  Future<void> excluir(Produto produto) async {
    await _service.excluir(produto);
    _produtos.remove(produto);
    notifyListeners();
  }
}
