import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/missao.dart';
import '../providers/missao_provider.dart';
import '../widgets/estrelas.dart';

const _rotulo = TextStyle(color: Colors.grey);
const _valor = TextStyle(fontSize: 18);

class DetalhesPage extends StatelessWidget {
  final Missao missao;

  const DetalhesPage({super.key, required this.missao});

  Future<void> _concluir(BuildContext context) async {
    final pontos = await context.read<MissaoProvider>().concluir(missao);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Missão concluída! Você conquistou $pontos pontos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // escuta o provider pra tela mudar quando concluir
    context.watch<MissaoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('DETALHES DA MISSÃO')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título:', style: _rotulo),
            Text(
              missao.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Dificuldade:', style: _rotulo),
            Row(
              children: [
                Estrelas(quantidade: missao.estrelas),
                const SizedBox(width: 8),
                Text(missao.dificuldade, style: _valor),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Pontos:', style: _rotulo),
            Text('${missao.pontos}', style: _valor),
            const SizedBox(height: 12),
            const Text('Status:', style: _rotulo),
            Text(missao.concluida ? 'Concluída' : 'Pendente', style: _valor),
            if (missao.data.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Data:', style: _rotulo),
              Text(missao.data, style: _valor),
            ],
            const SizedBox(height: 24),
            if (!missao.concluida)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _concluir(context),
                  child: const Text('CONCLUIR MISSÃO'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
