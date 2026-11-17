import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get usuarioLogado => _auth.authStateChanges();

  Future<void> entrarComGoogle() async {
    final provider = GoogleAuthProvider();
    await _auth.signInWithPopup(provider);
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}
