// Modelo de um voo devolvido pela API Python (GET /api/voos).
//
// JSON de origem (services/flightaware.py):
// {
//   "categoria": "chegadas",
//   "identificacao": "GLO7649",
//   "tipo_aeronave": "B38M",
//   "local": "Jorge Newbery ( AEP )",
//   "partida": "09:10a -03",
//   "chegada": "11:11a -03"
// }

/// Companhias aéreas mais comuns no painel do FlightAware,
/// identificadas pelo prefixo ICAO de 3 letras da identificação do voo.
const Map<String, String> _companhiasPorPrefixo = {
  'GLO': 'GOL',
  'AZU': 'Azul',
  'TAM': 'LATAM Brasil',
  'LAN': 'LATAM',
  'LPE': 'LATAM Perú',
  'JAT': 'JetSMART Argentina',
  'ARG': 'Aerolíneas Argentinas',
  'AVA': 'Avianca',
  'CMP': 'Copa Airlines',
  'AAL': 'American Airlines',
  'UAL': 'United Airlines',
  'DAL': 'Delta Air Lines',
  'ACA': 'Air Canada',
  'AFR': 'Air France',
  'KLM': 'KLM',
  'DLH': 'Lufthansa',
  'BAW': 'British Airways',
  'IBE': 'Iberia',
  'TAP': 'TAP Air Portugal',
  'UAE': 'Emirates',
  'QTR': 'Qatar Airways',
  'ETD': 'Etihad Airways',
  'THY': 'Turkish Airlines',
  'SWR': 'Swiss',
  'ETH': 'Ethiopian Airlines',
  'SAA': 'South African Airways',
  'ANA': 'All Nippon Airways',
  'JAL': 'Japan Airlines',
  'PTB': 'Voepass',
  'MWM': 'MAP Linhas Aéreas',
  'TTL': 'Total Linhas Aéreas',
  'SID': 'Sideral',
  'ABJ': 'Abaeté',
  'GLG': 'Gol Cargo',
  'FDX': 'FedEx',
  'UPS': 'UPS Airlines',
  'CLX': 'Cargolux',
  'ABW': 'AirBridgeCargo',
};

/// As categorias que a API devolve no campo `categoria`.
enum CategoriaVoo {
  chegadas('chegadas', 'Chegadas'),
  emRota('em_rota', 'Em rota'),
  partidas('partidas', 'Partidas'),
  partidasProgramadas('partidas_programadas', 'Partidas programadas'),
  desconhecida('', 'Outros');

  const CategoriaVoo(this.chave, this.rotulo);

  /// Valor exatamente como vem no JSON.
  final String chave;

  /// Texto amigável mostrado na interface.
  final String rotulo;

  static CategoriaVoo doJson(String valor) {
    for (final categoria in CategoriaVoo.values) {
      if (categoria.chave == valor) return categoria;
    }
    return CategoriaVoo.desconhecida;
  }

  /// Chegadas e voos em rota pousam no aeroporto consultado.
  bool get ehChegada =>
      this == CategoriaVoo.chegadas || this == CategoriaVoo.emRota;
}

class Voo {
  const Voo({
    required this.categoria,
    required this.identificacao,
    this.tipoAeronave,
    this.local,
    this.partida,
    this.chegada,
  });

  final CategoriaVoo categoria;
  final String identificacao;
  final String? tipoAeronave;
  final String? local;
  final String? partida;
  final String? chegada;

  factory Voo.fromJson(Map<String, dynamic> json) {
    return Voo(
      categoria: CategoriaVoo.doJson(_texto(json['categoria']) ?? ''),
      identificacao: _texto(json['identificacao']) ?? 'Sem identificação',
      tipoAeronave: _texto(json['tipo_aeronave']),
      local: _texto(json['local']),
      partida: _texto(json['partida']),
      chegada: _texto(json['chegada']),
    );
  }

  /// Converte qualquer valor do JSON em texto, tratando null e string vazia.
  static String? _texto(Object? valor) {
    if (valor == null) return null;
    final texto = valor.toString().trim();
    return texto.isEmpty ? null : texto;
  }

  /// Nome da companhia deduzido do prefixo ICAO (GLO7649 -> GOL).
  /// Devolve null quando o prefixo não é conhecido.
  String? get companhia {
    final prefixo = prefixoCompanhia;
    if (prefixo == null) return null;
    return _companhiasPorPrefixo[prefixo];
  }

  /// As 3 primeiras letras da identificação, quando existirem (GLO7649 -> GLO).
  String? get prefixoCompanhia {
    final match = RegExp(r'^[A-Z]{3}').firstMatch(identificacao.toUpperCase());
    return match?.group(0);
  }

  /// Código IATA dentro do campo local: "Jorge Newbery ( AEP )" -> "AEP".
  String? get codigoLocal {
    if (local == null) return null;
    final match = RegExp(r'\(\s*([A-Za-z0-9]{3,4})\s*\)').firstMatch(local!);
    return match?.group(1)?.toUpperCase();
  }

  /// Nome do aeroporto sem o código: "Jorge Newbery ( AEP )" -> "Jorge Newbery".
  String? get nomeLocal {
    if (local == null) return null;
    final nome = local!.split('(').first.trim();
    return nome.isEmpty ? local : nome;
  }

  /// Para uma chegada o `local` é a origem; para uma partida, o destino.
  String get rotuloLocal => categoria.ehChegada ? 'Origem' : 'Destino';

  /// Texto usado pelo filtro da tela inicial.
  bool combinaCom(String termo) {
    final busca = termo.trim().toLowerCase();
    if (busca.isEmpty) return true;
    return identificacao.toLowerCase().contains(busca) ||
        (local ?? '').toLowerCase().contains(busca) ||
        (tipoAeronave ?? '').toLowerCase().contains(busca) ||
        (companhia ?? '').toLowerCase().contains(busca);
  }
}
