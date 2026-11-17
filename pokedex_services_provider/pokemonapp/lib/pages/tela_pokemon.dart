import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import 'tela_detalhes_pokemon.dart';

class TelaPokemon extends StatefulWidget {
  const TelaPokemon({
    super.key,
  });

  @override
  State<TelaPokemon> createState() {
    return _TelaPokemonState();
  }
}

class _TelaPokemonState extends State<TelaPokemon> {
  final nomeController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  void abrirDetalhes(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TelaDetalhesPokemon(
            idPokemon: id,
          );
        },
      ),
    );
  }

  void pesquisar() {
    context.read<PokemonProvider>().pesquisarPorNome(
          nomeController.text,
        );
  }

  Future<void> pokemonAleatorio() async {
    final id = await context.read<PokemonProvider>().sortearPokemon();

    if (!mounted) return;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível sortear um Pokémon',
          ),
        ),
      );
      return;
    }

    abrirDetalhes(id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PokemonProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =============================
            // PESQUISA PELO NOME
            // =============================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Pokémon',
                      hintText: 'ex: pikachu',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => pesquisar(),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: provider.pesquisando ? null : pesquisar,
                  child: const Text(
                    'Pesquisar',
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            if (provider.pesquisando) const LinearProgressIndicator(),

            if (provider.erroPesquisa != null)
              Text(
                provider.erroPesquisa!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            if (provider.pokemonPesquisado != null)
              Card(
                color: const Color.fromARGB(
                  255,
                  255,
                  235,
                  235,
                ),
                child: ListTile(
                  leading: Image.network(
                    provider.pokemonPesquisado!['imagem'],
                    width: 60,
                  ),
                  title: Text(
                    provider.pokemonPesquisado!['nome'].toString().toUpperCase(),
                  ),
                  subtitle: Text(
                    'Tipo: ${provider.pokemonPesquisado!['tipo']}  |  '
                    'Altura: ${provider.pokemonPesquisado!['altura']}  |  '
                    'Peso: ${provider.pokemonPesquisado!['peso']}',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onTap: () {
                    abrirDetalhes(
                      provider.pokemonPesquisado!['id'],
                    );
                  },
                ),
              ),

            const SizedBox(
              height: 10,
            ),

            // =============================
            // BOTÕES
            // =============================

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PokemonProvider>().carregarPokemons();
                    },
                    child: const Text(
                      'Buscar Pokémon',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pokemonAleatorio,
                    icon: const Icon(
                      Icons.shuffle,
                    ),
                    label: const Text(
                      'Pokémon Aleatório',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            if (provider.carregando) const CircularProgressIndicator(),

            if (!provider.carregando)
              Expanded(
                child: ListView.builder(
                  itemCount: provider.pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = provider.pokemons[index];

                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          pokemon['imagem'],
                          width: 60,
                        ),
                        title: Text(
                          pokemon['nome'].toString().toUpperCase(),
                        ),
                        subtitle: Text(
                          'Tipo: ${pokemon['tipo']}',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onTap: () {
                          abrirDetalhes(
                            pokemon['id'],
                          );
                        },
                      ),
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
