import 'package:controledeestoque/models/produto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('estoque baixo quando quantidade <= 3', () {
    final p = Produto(nome: 'Mouse', categoria: 'Informática', quantidade: 3, preco: 120);
    expect(p.estoqueBaixo, isTrue);
    p.quantidade = 4;
    expect(p.estoqueBaixo, isFalse);
  });
}
