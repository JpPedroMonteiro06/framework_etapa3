import 'dart:convert';

import 'package:http/http.dart' as http;

class PokemonService {
  static const String url = 'http://127.0.0.1:5001/pokemons';

  // BUSCAR TODOS
  static Future<List<dynamic>> buscarPokemons() async {
    final resposta = await http.get(
      Uri.parse(url),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao buscar Pokémon',
    );
  }

  // BUSCAR UM POKÉMON
  static Future<Map<String, dynamic>> buscarDetalhes(int id) async {
    final resposta = await http.get(
      Uri.parse(
        '$url/$id',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao buscar detalhes',
    );
  }

  // BUSCAR PELO NOME -> GET /pokemons/nome/<nome>
  static Future<Map<String, dynamic>?> buscarPorNome(String nome) async {
    final resposta = await http.get(
      Uri.parse(
        '$url/nome/${Uri.encodeComponent(nome)}',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    // 404 = nao achou o pokemon
    if (resposta.statusCode == 404) {
      return null;
    }

    throw Exception(
      'Erro ao pesquisar Pokémon',
    );
  }

  // POKÉMON ALEATÓRIO -> GET /pokemons/aleatorio
  static Future<Map<String, dynamic>> buscarAleatorio() async {
    final resposta = await http.get(
      Uri.parse(
        '$url/aleatorio',
      ),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(
        resposta.body,
      );
    }

    throw Exception(
      'Erro ao sortear Pokémon',
    );
  }
}
