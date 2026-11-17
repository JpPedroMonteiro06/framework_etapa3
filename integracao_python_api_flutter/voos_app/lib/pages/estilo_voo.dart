// Detalhes visuais compartilhados pelas telas (cor e ícone de cada categoria)
// e a lista de aeroportos sugeridos. É código de interface, por isso vive
// dentro de pages/.

import 'package:flutter/material.dart';

import '../models/voo.dart';

/// Cor e ícone usados para representar uma categoria de voo.
class EstiloCategoria {
  const EstiloCategoria(this.cor, this.icone);

  final Color cor;
  final IconData icone;

  factory EstiloCategoria.de(CategoriaVoo categoria) {
    switch (categoria) {
      case CategoriaVoo.chegadas:
        return const EstiloCategoria(Color(0xFF1B873F), Icons.flight_land);
      case CategoriaVoo.emRota:
        return const EstiloCategoria(Color(0xFF0A6EBD), Icons.flight);
      case CategoriaVoo.partidas:
        return const EstiloCategoria(Color(0xFFB25000), Icons.flight_takeoff);
      case CategoriaVoo.partidasProgramadas:
        return const EstiloCategoria(Color(0xFF6D4AA6), Icons.schedule_send);
      case CategoriaVoo.desconhecida:
        return const EstiloCategoria(Color(0xFF5A6472), Icons.help_outline);
    }
  }
}

/// Aeroporto sugerido nos atalhos da tela inicial.
class AeroportoSugerido {
  const AeroportoSugerido(this.icao, this.nome);

  final String icao;
  final String nome;
}

const List<AeroportoSugerido> aeroportosSugeridos = [
  AeroportoSugerido('SBGR', 'Guarulhos'),
  AeroportoSugerido('SBSP', 'Congonhas'),
  AeroportoSugerido('SBBR', 'Brasília'),
  AeroportoSugerido('SBCF', 'Confins'),
  AeroportoSugerido('SBGL', 'Galeão'),
  AeroportoSugerido('SBRJ', 'Santos Dumont'),
  AeroportoSugerido('SBCT', 'Curitiba'),
  AeroportoSugerido('SBPA', 'Porto Alegre'),
  AeroportoSugerido('SBSV', 'Salvador'),
  AeroportoSugerido('SBRF', 'Recife'),
];

/// Nome amigável do aeroporto, quando conhecido.
String? nomeDoAeroporto(String icao) {
  for (final aeroporto in aeroportosSugeridos) {
    if (aeroporto.icao == icao.toUpperCase()) return aeroporto.nome;
  }
  return null;
}

/// Formata um horário como 14:07 (a API não devolve a hora da coleta).
String horaFormatada(DateTime momento) {
  String doisDigitos(int valor) => valor.toString().padLeft(2, '0');
  return '${doisDigitos(momento.hour)}:${doisDigitos(momento.minute)}';
}
