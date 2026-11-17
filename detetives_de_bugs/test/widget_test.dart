import 'package:flutter_test/flutter_test.dart';

import 'package:central_achados/models/ocorrencia.dart';

void main() {
  test('lê o autorId do campo certo', () {
    final o = Ocorrencia.fromMap('abc', {
      'titulo': 'Garrafa azul',
      'local': 'Quadra',
      'autorId': 'uid123',
      'autorNome': 'Aluno Teste',
      'resolvido': false,
    });

    expect(o.autorId, 'uid123');
    expect(o.autorNome, 'Aluno Teste');
  });

  test('status resolvido não vem invertido', () {
    final aberto = Ocorrencia.fromMap('1', {'resolvido': false});
    final resolvido = Ocorrencia.fromMap('2', {'resolvido': true});
    final semCampo = Ocorrencia.fromMap('3', {});

    expect(aberto.resolvido, isFalse);
    expect(resolvido.resolvido, isTrue);
    expect(semCampo.resolvido, isFalse);
  });
}
