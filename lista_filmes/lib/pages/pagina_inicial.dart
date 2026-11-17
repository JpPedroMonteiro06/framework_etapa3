import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/filme_viewmodel.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  final _tituloController = TextEditingController();

  void _adicionar() {
    final titulo = _tituloController.text;

    if (titulo.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do filme')),
      );
      return;
    }

    context.read<FilmeViewModel>().adicionarFilme(titulo);
    _tituloController.clear();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilmeViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Lista de Filmes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Digite o nome do filme',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _adicionar(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _adicionar,
              child: const Text('Adicionar'),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(child: _lista(vm)),
          ],
        ),
      ),
    );
  }

  Widget _lista(FilmeViewModel vm) {
    if (vm.carregando && vm.filmes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.filmes.isEmpty) {
      return const Center(child: Text('Nenhum filme cadastrado ainda.'));
    }

    return ListView.builder(
      itemCount: vm.filmes.length,
      itemBuilder: (context, index) {
        final filme = vm.filmes[index];

        return ListTile(
          leading: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 16),
          ),
          title: Text(
            filme.titulo,
            style: TextStyle(
              decoration: filme.assistido ? TextDecoration.lineThrough : null,
              color: filme.assistido ? Colors.grey : null,
            ),
          ),
          trailing: Checkbox(
            value: filme.assistido,
            onChanged: (valor) => vm.alterarAssistido(filme, valor ?? false),
          ),
        );
      },
    );
  }
}
