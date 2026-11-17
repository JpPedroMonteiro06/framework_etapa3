import 'package:flutter/material.dart';

import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  List<dynamic> pokemons = [];

  Map<String, dynamic>? pokemonSelecionado;

  bool carregando = false;

  // pesquisa pelo nome
  Map<String, dynamic>? pokemonPesquisado;

  bool pesquisando = false;

  String? erroPesquisa;

  Future<void> carregarPokemons() async {
    carregando = true;

    notifyListeners();

    pokemons = await PokemonService.buscarPokemons();

    carregando = false;

    notifyListeners();
  }

  Future<void> carregarDetalhes(
    int id,
  ) async {
    carregando = true;

    pokemonSelecionado = null;

    notifyListeners();

    pokemonSelecionado = await PokemonService.buscarDetalhes(
      id,
    );

    carregando = false;

    notifyListeners();
  }

  Future<void> pesquisarPorNome(
    String nome,
  ) async {
    if (nome.trim().isEmpty) {
      erroPesquisa = 'Digite o nome de um Pokémon';
      notifyListeners();
      return;
    }

    pesquisando = true;

    erroPesquisa = null;

    pokemonPesquisado = null;

    notifyListeners();

    try {
      pokemonPesquisado = await PokemonService.buscarPorNome(
        nome.trim().toLowerCase(),
      );

      if (pokemonPesquisado == null) {
        erroPesquisa = 'Pokémon "${nome.trim()}" não encontrado';
      }
    } catch (e) {
      erroPesquisa = 'Erro ao pesquisar. O servidor Flask está rodando?';
    }

    pesquisando = false;

    notifyListeners();
  }

  // devolve o id do pokemon sorteado pra tela abrir os detalhes
  Future<int?> sortearPokemon() async {
    try {
      final pokemon = await PokemonService.buscarAleatorio();

      return pokemon['id'];
    } catch (e) {
      return null;
    }
  }
}
