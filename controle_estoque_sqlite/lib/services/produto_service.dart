import '../models/produto.dart';
import 'database_service.dart';

class ProdutoService {
  Future<void> cadastrar(Produto produto) async {
    final db = await DatabaseService.banco;
    await db.insert('produtos', produto.toMap());
    print('INSERT → Produto cadastrado: ${produto.nome}');
    await mostrarProdutosNoTerminal();
  }

  Future<List<Produto>> listar() async {
    final db = await DatabaseService.banco;
    final resultado = await db.query('produtos', orderBy: 'nome');
    final produtos = resultado.map(Produto.fromMap).toList();

    print('SELECT → Produtos encontrados:');
    for (final p in produtos) {
      print('{id: ${p.id}, nome: ${p.nome}, quantidade: ${p.quantidade}}');
    }
    return produtos;
  }

  Future<void> alterarQuantidade(Produto produto, int novaQuantidade) async {
    final db = await DatabaseService.banco;
    await db.update(
      'produtos',
      {'quantidade': novaQuantidade},
      where: 'id = ?',
      whereArgs: [produto.id],
    );
    print('UPDATE → ${produto.nome}');
    print('Quantidade anterior: ${produto.quantidade}');
    print('Nova quantidade: $novaQuantidade');
  }

  Future<void> excluir(Produto produto) async {
    final db = await DatabaseService.banco;
    await db.delete('produtos', where: 'id = ?', whereArgs: [produto.id]);
    print('DELETE → Produto excluído: ${produto.nome}');
  }

  Future<void> mostrarProdutosNoTerminal() async {
    final db = await DatabaseService.banco;
    final produtos = await db.query('produtos');

    print('===== PRODUTOS NO BANCO =====');
    for (final produto in produtos) {
      print(produto);
    }
  }
}
