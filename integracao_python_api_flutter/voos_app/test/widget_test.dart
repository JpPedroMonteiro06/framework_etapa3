// Testes do fluxo Service -> Provider -> Page usando um cliente HTTP falso,
// para não depender do terminal do Python estar aberto.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:voos_app/models/voo.dart';
import 'package:voos_app/pages/home_page.dart';
import 'package:voos_app/providers/voo_provider.dart';
import 'package:voos_app/services/voo_service.dart';

/// Resposta parecida com a que a API Python devolve.
const Map<String, dynamic> _respostaFalsa = {
  'fonte': 'https://www.flightaware.com/live/airport/SBGR',
  'aeroporto': 'SBGR',
  'tipo_busca': 'todos',
  'total': 2,
  'voos': [
    {
      'categoria': 'chegadas',
      'identificacao': 'GLO7649',
      'tipo_aeronave': 'B38M',
      'local': 'Jorge Newbery ( AEP )',
      'partida': '09:10a -03',
      'chegada': '11:11a -03',
    },
    {
      'categoria': 'partidas',
      'identificacao': 'TAM3698',
      'tipo_aeronave': 'A321',
      'local': 'Rio de Janeiro/Galeao Intl ( GIG )',
      'partida': '10:46a -03',
      'chegada': '11:23a -03',
    },
  ],
};

VooProvider _providerFalso({
  int status = 200,
  Object corpo = _respostaFalsa,
  void Function(http.Request)? aoChamar,
}) {
  final cliente = MockClient((requisicao) async {
    aoChamar?.call(requisicao);
    return http.Response(
      jsonEncode(corpo),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
  return VooProvider(service: VooService(cliente: cliente));
}

Widget _appDeTeste(VooProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  group('Voo (model)', () {
    test('converte o JSON da API', () {
      final voo = Voo.fromJson(
        Map<String, dynamic>.from(_respostaFalsa['voos']![0] as Map),
      );

      expect(voo.identificacao, 'GLO7649');
      expect(voo.categoria, CategoriaVoo.chegadas);
      expect(voo.companhia, 'GOL');
      expect(voo.codigoLocal, 'AEP');
      expect(voo.nomeLocal, 'Jorge Newbery');
      expect(voo.rotuloLocal, 'Origem');
    });

    test('trata campos nulos vindos do scraping', () {
      final voo = Voo.fromJson(const {
        'categoria': 'partidas',
        'identificacao': 'PR-ABC',
        'tipo_aeronave': null,
        'local': '',
      });

      expect(voo.tipoAeronave, isNull);
      expect(voo.local, isNull);
      expect(voo.companhia, isNull);
      expect(voo.rotuloLocal, 'Destino');
    });
  });

  group('VooProvider', () {
    test('guarda os voos devolvidos pelo service', () async {
      final provider = _providerFalso();
      await provider.carregarVoos();

      expect(provider.carregando, isFalse);
      expect(provider.erro, isNull);
      expect(provider.voos.length, 2);
      expect(provider.voosPorCategoria.keys, [
        CategoriaVoo.chegadas,
        CategoriaVoo.partidas,
      ]);
    });

    test('envia aeroporto e tipo na query string', () async {
      Uri? chamada;
      final provider = _providerFalso(
        aoChamar: (requisicao) => chamada = requisicao.url,
      );

      await provider.buscarPorAeroporto('sbsp');
      await provider.alterarTipo(TipoBusca.chegadas);

      expect(chamada?.path, '/api/voos');
      expect(chamada?.queryParameters['aeroporto'], 'SBSP');
      expect(chamada?.queryParameters['tipo'], 'chegadas');
    });

    test('recusa código ICAO inválido sem chamar a API', () async {
      var chamou = false;
      final provider = _providerFalso(aoChamar: (_) => chamou = true);

      expect(await provider.buscarPorAeroporto('SBG'), isFalse);
      expect(chamou, isFalse);
    });

    test('guarda a mensagem de erro devolvida pela API', () async {
      final provider = _providerFalso(
        status: 400,
        corpo: {'erro': 'Parâmetro aeroporto deve ser ICAO de 4 letras'},
      );
      await provider.carregarVoos();

      expect(provider.erro, contains('ICAO de 4 letras'));
      expect(provider.voos, isEmpty);
    });

    test('o filtro reduz a lista sem chamar a API de novo', () async {
      var chamadas = 0;
      final provider = _providerFalso(aoChamar: (_) => chamadas++);
      await provider.carregarVoos();

      provider.alterarFiltro('gol');

      expect(chamadas, 1);
      expect(provider.voos.single.identificacao, 'GLO7649');
    });
  });

  group('HomePage', () {
    testWidgets('mostra os voos carregados', (tester) async {
      await tester.pumpWidget(_appDeTeste(_providerFalso()));
      await tester.pumpAndSettle();

      expect(find.text('GLO7649'), findsOneWidget);
      expect(find.text('TAM3698'), findsOneWidget);
      expect(find.text('CHEGADAS'), findsOneWidget);
      expect(find.text('PARTIDAS'), findsOneWidget);
    });

    testWidgets('mostra a mensagem de erro quando a API falha',
        (tester) async {
      await tester.pumpWidget(
        _appDeTeste(_providerFalso(status: 500, corpo: const {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('abre a tela de detalhes ao tocar em um voo', (tester) async {
      await tester.pumpWidget(_appDeTeste(_providerFalso()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('GLO7649'));
      await tester.pumpAndSettle();

      expect(find.text('Dados do voo'), findsOneWidget);

      // O restante das informações fica abaixo da dobra na tela de teste.
      await tester.scrollUntilVisible(find.text('Jorge Newbery'), 200);

      expect(find.text('Aeroporto de origem'), findsOneWidget);
      expect(find.text('Jorge Newbery'), findsOneWidget);
    });
  });
}
