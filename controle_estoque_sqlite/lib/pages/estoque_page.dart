import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../providers/produto_provider.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProdutoProvider>().carregar(),
    );
  }

  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<ProdutoProvider>().excluir(produto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProdutoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('ESTOQUE')),
      body: provider.carregando && provider.produtos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.produtos.isEmpty
              ? const Center(child: Text('Nenhum produto cadastrado.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.produtos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final produto = provider.produtos[i];
                    return _ProdutoItem(
                      produto: produto,
                      onMais: () => provider.incrementar(produto),
                      onMenos: () => provider.decrementar(produto),
                      onExcluir: () => _confirmarExclusao(produto),
                    );
                  },
                ),
    );
  }
}

class _ProdutoItem extends StatelessWidget {
  final Produto produto;
  final VoidCallback onMais;
  final VoidCallback onMenos;
  final VoidCallback onExcluir;

  const _ProdutoItem({
    required this.produto,
    required this.onMais,
    required this.onMenos,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  produto.nome,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: onExcluir,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('EXCLUIR',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          Text(produto.categoria),
          Row(
            children: [
              IconButton.outlined(
                onPressed: produto.quantidade > 0 ? onMenos : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Quantidade: ${produto.quantidade}'),
              ),
              IconButton.outlined(
                onPressed: onMais,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text(_moeda.format(produto.preco)),
          if (produto.estoqueBaixo)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'ESTOQUE BAIXO',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
