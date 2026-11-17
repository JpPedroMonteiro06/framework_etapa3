// Camada de acesso à API Python/Flask (Aula 19 - webscraping de voos).
//
// Esta é a ÚNICA camada do app que conhece HTTP e JSON.
// As telas nunca chamam http.get: elas falam com o VooProvider,
// que por sua vez chama este service.
//
//   Flutter -> HTTP -> API Python (http://127.0.0.1:5001/api/voos)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/resultado_voos.dart';

/// Erro tratado do service, com mensagem pronta para ser exibida na tela.
class VooServiceException implements Exception {
  const VooServiceException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class VooService {
  VooService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Permite trocar o endereço sem editar o código:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5001
  static const String _baseUrlDefinida = String.fromEnvironment('API_BASE_URL');

  /// O scraping ao vivo do FlightAware costuma levar alguns segundos.
  static const Duration _timeout = Duration(seconds: 45);

  /// Endereço da API Python conforme a plataforma em que o app está rodando.
  static String get baseUrl {
    if (_baseUrlDefinida.isNotEmpty) return _baseUrlDefinida;
    // No emulador Android o localhost da máquina é 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5001';
    }
    return 'http://127.0.0.1:5001';
  }

  /// GET /api/voos?aeroporto=SBGR&tipo=chegadas
  ///
  /// Faz a requisição, converte o JSON e devolve o resultado para o Provider.
  Future<ResultadoVoos> buscarVoos({
    String aeroporto = 'SBGR',
    String tipo = 'todos',
  }) async {
    final uri = Uri.parse('$baseUrl/api/voos').replace(
      queryParameters: {
        'aeroporto': aeroporto.trim().toUpperCase(),
        'tipo': tipo.trim().toLowerCase(),
      },
    );

    final http.Response resposta;
    try {
      resposta = await _cliente.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const VooServiceException(
        'A API demorou demais para responder. '
        'O webscraping do FlightAware pode estar lento — tente novamente.',
      );
    } catch (_) {
      // Sem rede, servidor fora do ar ou CORS bloqueado no Flutter Web.
      throw VooServiceException(_erroDeConexao);
    }

    // O Flask responde sem charset no cabeçalho, então decodificamos
    // os bytes como UTF-8 para não perder os acentos (Brasília, Galeão...).
    final corpo = _decodificar(resposta.bodyBytes);

    if (resposta.statusCode != 200) {
      final mensagemApi =
          corpo is Map<String, dynamic> ? corpo['erro']?.toString() : null;
      throw VooServiceException(
        mensagemApi ??
            'A API respondeu com erro ${resposta.statusCode}. '
                'Confira o terminal do Python.',
      );
    }

    if (corpo is! Map<String, dynamic>) {
      throw const VooServiceException(
        'A API devolveu um formato inesperado de resposta.',
      );
    }

    return ResultadoVoos.fromJson(corpo);
  }

  static String get _erroDeConexao =>
      'Não foi possível falar com a API Python em $baseUrl.\n'
      'Confira se o terminal 1 está rodando "python app.py".';

  /// Decodifica o JSON tratando corpo vazio ou inválido.
  static Object? _decodificar(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(bytes, allowMalformed: true));
    } catch (_) {
      return null;
    }
  }

  void dispose() => _cliente.close();
}
