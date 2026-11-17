import '../models/usuario.dart';
import 'database_service.dart';

class UsuarioService {
  /// Retorna false se o e-mail já estiver cadastrado.
  Future<bool> cadastrar(Usuario usuario) async {
    final db = await DatabaseService.banco;

    final existente = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [usuario.email],
    );
    if (existente.isNotEmpty) {
      print('SELECT → E-mail já cadastrado: ${usuario.email}');
      return false;
    }

    await db.insert('usuarios', usuario.toMap());
    print('INSERT → Usuário cadastrado: ${usuario.nome}');
    return true;
  }

  Future<Usuario?> login(String email, String senha) async {
    final db = await DatabaseService.banco;

    print('SELECT → Procurando usuário: $email');
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    if (resultado.isEmpty) {
      print('SELECT → Usuário não encontrado');
      return null;
    }

    final usuario = Usuario.fromMap(resultado.first);
    print('SELECT → Usuário encontrado: ${usuario.nome}');
    return usuario;
  }
}
