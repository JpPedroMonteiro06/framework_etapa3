import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/missao.dart';

class MissaoService {
  final _colecao = FirebaseFirestore.instance.collection('missoes_jujutsu');

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> cadastrar(String titulo, int grau) async {
    final missao = Missao(titulo: titulo, grau: grau, usuarioId: _uid);
    await _colecao.add(missao.toMap());
  }

  // so traz as missoes do usuario que esta logado
  Stream<List<Missao>> minhasMissoes() {
    return _colecao
        .where('usuarioId', isEqualTo: _uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Missao.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> alterarConcluida(Missao missao, bool concluida) async {
    await _colecao.doc(missao.id).update({'concluida': concluida});
  }

  Future<void> excluir(Missao missao) async {
    await _colecao.doc(missao.id).delete();
  }
}
