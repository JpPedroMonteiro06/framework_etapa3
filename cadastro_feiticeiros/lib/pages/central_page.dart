import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/missao.dart';
import '../services/auth_service.dart';
import '../services/missao_service.dart';

class CentralPage extends StatefulWidget {
  const CentralPage({super.key});

  @override
  State<CentralPage> createState() => _CentralPageState();
}

class _CentralPageState extends State<CentralPage> {
  final _tituloController = TextEditingController();
  final _service = MissaoService();
  late final Stream<List<Missao>> _missoes = _service.minhasMissoes();
  int _grau = 4;

  Future<void> _cadastrar() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o título da missão')),
      );
      return;
    }

    await _service.cadastrar(titulo, _grau);
    _tituloController.clear();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central Jujutsu'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().sair(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: usuario.photoURL != null
                      ? NetworkImage(usuario.photoURL!)
                      : null,
                  child: usuario.photoURL == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bem-vindo,'),
                      Text(
                        usuario.displayName ?? 'Feiticeiro',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        usuario.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título da missão',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Grau: '),
                DropdownButton<int>(
                  value: _grau,
                  items: [1, 2, 3, 4]
                      .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                      .toList(),
                  onChanged: (valor) => setState(() => _grau = valor!),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _cadastrar,
                  child: const Text('CADASTRAR'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Missao>>(
                stream: _missoes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final missoes = snapshot.data!;
                  if (missoes.isEmpty) {
                    return const Center(child: Text('Nenhuma missão cadastrada.'));
                  }

                  return ListView.builder(
                    itemCount: missoes.length,
                    itemBuilder: (context, index) {
                      final missao = missoes[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: missao.concluida,
                            onChanged: (valor) =>
                                _service.alterarConcluida(missao, valor ?? false),
                          ),
                          title: Text(
                            missao.titulo,
                            style: TextStyle(
                              decoration: missao.concluida
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            'Grau ${missao.grau} - ${missao.concluida ? 'Concluída' : 'Pendente'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _service.excluir(missao),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
