import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final _service = UsuarioService();

  Usuario? _usuarioLogado;
  Usuario? get usuarioLogado => _usuarioLogado;

  Future<bool> cadastrar(String nome, String email, String senha) {
    return _service.cadastrar(
      Usuario(nome: nome, email: email, senha: senha),
    );
  }

  Future<bool> login(String email, String senha) async {
    _usuarioLogado = await _service.login(email, senha);
    notifyListeners();
    return _usuarioLogado != null;
  }

  void sair() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
