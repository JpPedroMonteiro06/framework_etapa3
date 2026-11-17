import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/missao.dart';
import '../providers/missao_provider.dart';
import '../widgets/estrelas.dart';
import 'detalhes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tituloController = TextEditingController();
  String _dificuldade = 'Fácil';

  Future<void> _cadastrar() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o título da missão')),
      );
      return;
    }

    await context.read<MissaoProvider>().cadastrar(titulo, _dificuldade);
    _tituloController.clear();
  }

  Future<void> _concluir(Missao missao) async {
    final pontos = await context.read<MissaoProvider>().concluir(missao);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Missão concluída! Você conquistou $pontos pontos.')),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissaoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('CENTRAL DE MISSÕES')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título da missão',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Dificuldade: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _dificuldade,
                items: MissaoProvider.pontosPorDificuldade.keys
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (valor) {
                  setState(() => _dificuldade = valor!);
                },
              ),
              const SizedBox(width: 8),
              Text('(${MissaoProvider.pontosPorDificuldade[_dificuldade]} pontos)'),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _cadastrar,
            child: const Text('CADASTRAR MISSÃO'),
          ),
          const SizedBox(height: 20),
          Text(
            'PONTOS CONQUISTADOS: ${provider.pontosConquistados}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          if (provider.carregando)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.missoes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Nenhuma missão cadastrada.')),
            )
          else
            ...provider.missoes.map((missao) => _cardMissao(missao)),
        ],
      ),
    );
  }

  Widget _cardMissao(Missao missao) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetalhesPage(missao: missao)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                missao.titulo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Dificuldade: '),
                  Estrelas(quantidade: missao.estrelas),
                ],
              ),
              Text('Pontos: ${missao.pontos}'),
              Text('Status: ${missao.concluida ? 'Concluída' : 'Pendente'}'),
              if (missao.data.isNotEmpty) Text('Data: ${missao.data}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!missao.concluida) ...[
                    ElevatedButton(
                      onPressed: () => _concluir(missao),
                      child: const Text('CONCLUIR'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    onPressed: () => context.read<MissaoProvider>().excluir(missao),
                    child: const Text('EXCLUIR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
