import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComentarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uidAtual => _auth.currentUser!.uid;

  // snapshots() fica escutando, entao comentario novo chega sozinho na tela
  // o where garante que so vem os comentarios dessa publicacao
  Stream<QuerySnapshot<Map<String, dynamic>>> acompanhar(String publicacaoId) {
    return _db
        .collection('comentarios')
        .where('publicacaoId', isEqualTo: publicacaoId)
        .snapshots();
  }

  Future<void> comentar(String publicacaoId, String texto) async {
    final usuario = _auth.currentUser!;
    final perfil = await _db.collection('usuarios').doc(usuario.uid).get();
    final nome = (perfil.data()?['nome'] as String?) ?? usuario.email ?? 'Usuário';

    await _db.collection('comentarios').add({
      'texto': texto.trim(),
      'autorNome': nome,
      'autorId': usuario.uid,
      'publicacaoId': publicacaoId,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluir(String id) =>
      _db.collection('comentarios').doc(id).delete();
}
