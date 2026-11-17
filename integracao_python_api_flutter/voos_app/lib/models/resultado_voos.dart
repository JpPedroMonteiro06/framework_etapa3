// Pacote completo devolvido por GET /api/voos: metadados da busca + lista de voos.

import 'voo.dart';

class ResultadoVoos {
  const ResultadoVoos({
    required this.fonte,
    required this.aeroporto,
    required this.tipoBusca,
    required this.total,
    required this.voos,
    required this.buscadoEm,
  });

  /// URL do FlightAware que o Python raspou.
  final String fonte;

  /// Código ICAO consultado (SBGR, SBSP...).
  final String aeroporto;

  /// chegadas | partidas | todos
  final String tipoBusca;

  /// Total informado pela API.
  final int total;

  final List<Voo> voos;

  /// Momento em que o app recebeu a resposta (a API não envia horário).
  final DateTime buscadoEm;

  factory ResultadoVoos.fromJson(Map<String, dynamic> json) {
    final lista = json['voos'];
    return ResultadoVoos(
      fonte: (json['fonte'] ?? '').toString(),
      aeroporto: (json['aeroporto'] ?? '').toString(),
      tipoBusca: (json['tipo_busca'] ?? '').toString(),
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total']}') ?? 0,
      voos: lista is List
          ? lista
              .whereType<Map<String, dynamic>>()
              .map(Voo.fromJson)
              .toList(growable: false)
          : const <Voo>[],
      buscadoEm: DateTime.now(),
    );
  }
}
