import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/missao.dart';

class MissaoService {
  final _colecao = FirebaseFirestore.instance.collection('missoes');

  Future<String> adicionar(Missao missao) async {
    final doc = await _colecao.add(missao.toMap());
    return doc.id;
  }

  Future<List<Missao>> buscarTodas() async {
    final resultado = await _colecao.get();
    return resultado.docs
        .map((doc) => Missao.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> atualizar(Missao missao) async {
    await _colecao.doc(missao.id).update(missao.toMap());
  }

  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}
