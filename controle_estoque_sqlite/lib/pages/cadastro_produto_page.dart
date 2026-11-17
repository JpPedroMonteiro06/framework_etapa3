import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/produto_provider.dart';

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final categoria = _categoriaController.text.trim();
    final quantidade = int.tryParse(_quantidadeController.text.trim());
    final preco =
        double.tryParse(_precoController.text.trim().replaceAll(',', '.'));

    if (nome.isEmpty || categoria.isEmpty) {
      setState(() => _erro = 'Preencha nome e categoria.');
      return;
    }
    if (quantidade == null || quantidade < 0) {
      setState(() => _erro = 'Quantidade inválida.');
      return;
    }
    if (preco == null || preco < 0) {
      setState(() => _erro = 'Preço inválido.');
      return;
    }

    await context
        .read<ProdutoProvider>()
        .cadastrar(nome, categoria, quantidade, preco);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto "$nome" cadastrado!')),
    );
    setState(() => _erro = null);
    _nomeController.clear();
    _categoriaController.clear();
    _quantidadeController.clear();
    _precoController.clear();
  }

  Widget _campo(TextEditingController controller, String label,
      {TextInputType? teclado}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              _campo(_nomeController, 'Nome'),
              _campo(_categoriaController, 'Categoria'),
              _campo(_quantidadeController, 'Quantidade',
                  teclado: TextInputType.number),
              _campo(_precoController, 'Preço',
                  teclado: const TextInputType.numberWithOptions(decimal: true)),
              if (_erro != null) ...[
                Text(_erro!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _cadastrar,
                child: const Text('CADASTRAR PRODUTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
