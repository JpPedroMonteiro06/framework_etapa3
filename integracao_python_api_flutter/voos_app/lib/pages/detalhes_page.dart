// Segunda tela: todas as informações do voo escolhido na tela inicial.
// Chegamos aqui por Navigator.push(), recebendo o Voo pelo construtor.
// Os dados da consulta (aeroporto, tipo, fonte) vêm do VooProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/voo.dart';
import '../providers/voo_provider.dart';
import 'estilo_voo.dart';

class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key, required this.voo});

  final Voo voo;

  @override
  Widget build(BuildContext context) {
    final resultado = context.watch<VooProvider>().resultado;
    final estilo = EstiloCategoria.de(voo.categoria);

    return Scaffold(
      appBar: AppBar(
        title: Text(voo.identificacao),
        backgroundColor: estilo.cor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Cabecalho(voo: voo, estilo: estilo),
          _Trajeto(voo: voo, estilo: estilo),
          _Bloco(
            titulo: 'Dados do voo',
            filhos: [
              _LinhaInfo(
                icone: Icons.confirmation_number_outlined,
                rotulo: 'Identificação',
                valor: voo.identificacao,
              ),
              _LinhaInfo(
                icone: Icons.business,
                rotulo: 'Companhia aérea',
                valor: voo.companhia ??
                    (voo.prefixoCompanhia == null
                        ? null
                        : 'Prefixo ${voo.prefixoCompanhia}'),
              ),
              _LinhaInfo(
                icone: Icons.airplanemode_active,
                rotulo: 'Tipo de aeronave',
                valor: voo.tipoAeronave,
              ),
              _LinhaInfo(
                icone: estilo.icone,
                rotulo: 'Tipo do voo',
                valor: voo.categoria.rotulo,
              ),
            ],
          ),
          _Bloco(
            titulo: voo.categoria.ehChegada
                ? 'Aeroporto de origem'
                : 'Aeroporto de destino',
            filhos: [
              _LinhaInfo(
                icone: Icons.location_on_outlined,
                rotulo: 'Nome',
                valor: voo.nomeLocal,
              ),
              _LinhaInfo(
                icone: Icons.tag,
                rotulo: 'Código',
                valor: voo.codigoLocal,
              ),
              _LinhaInfo(
                icone: Icons.flight_takeoff,
                rotulo: 'Horário de partida',
                valor: voo.partida,
              ),
              _LinhaInfo(
                icone: Icons.flight_land,
                rotulo: 'Horário de chegada',
                valor: voo.chegada,
              ),
            ],
          ),
          if (resultado != null)
            _Bloco(
              titulo: 'Sobre esta consulta',
              filhos: [
                _LinhaInfo(
                  icone: Icons.local_airport,
                  rotulo: 'Aeroporto consultado',
                  valor: nomeDoAeroporto(resultado.aeroporto) == null
                      ? resultado.aeroporto
                      : '${resultado.aeroporto} · '
                          '${nomeDoAeroporto(resultado.aeroporto)}',
                ),
                _LinhaInfo(
                  icone: Icons.filter_alt_outlined,
                  rotulo: 'Filtro usado na API',
                  valor: resultado.tipoBusca,
                ),
                _LinhaInfo(
                  icone: Icons.format_list_numbered,
                  rotulo: 'Voos nesta coleta',
                  valor: '${resultado.total}',
                ),
                _LinhaInfo(
                  icone: Icons.schedule,
                  rotulo: 'Atualizado às',
                  valor: horaFormatada(resultado.buscadoEm),
                ),
                _LinhaInfo(
                  icone: Icons.link,
                  rotulo: 'Fonte do webscraping',
                  valor: resultado.fonte,
                  selecionavel: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Faixa colorida do topo com a identificação e a companhia do voo.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.voo, required this.estilo});

  final Voo voo;
  final EstiloCategoria estilo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [estilo.cor, Color.lerp(estilo.cor, Colors.black, 0.28)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(estilo.icone, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                voo.categoria.rotulo.toUpperCase(),
                style: tema.textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            voo.identificacao,
            style: tema.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (voo.companhia != null)
            Text(
              voo.companhia!,
              style: tema.textTheme.titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
          if (voo.tipoAeronave != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Aeronave ${voo.tipoAeronave}',
                style: tema.textTheme.labelMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cartão do trajeto: horário de partida, avião no meio e horário de chegada.
class _Trajeto extends StatelessWidget {
  const _Trajeto({required this.voo, required this.estilo});

  final Voo voo;
  final EstiloCategoria estilo;

  @override
  Widget build(BuildContext context) {
    final consultado = context.watch<VooProvider>().aeroporto;
    final codigoLocal = voo.codigoLocal ?? '???';

    // Numa chegada o voo vem do "local" para o aeroporto consultado.
    // Numa partida acontece o contrário.
    final origem = voo.categoria.ehChegada ? codigoLocal : consultado;
    final destino = voo.categoria.ehChegada ? consultado : codigoLocal;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            _Ponta(
              codigo: origem,
              rotulo: 'Partida',
              horario: voo.partida,
              alinhamento: CrossAxisAlignment.start,
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.flight, color: estilo.cor),
                  const SizedBox(height: 4),
                  Divider(color: estilo.cor.withValues(alpha: 0.4)),
                ],
              ),
            ),
            _Ponta(
              codigo: destino,
              rotulo: 'Chegada',
              horario: voo.chegada,
              alinhamento: CrossAxisAlignment.end,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma das pontas do trajeto (código do aeroporto + horário).
class _Ponta extends StatelessWidget {
  const _Ponta({
    required this.codigo,
    required this.rotulo,
    required this.horario,
    required this.alinhamento,
  });

  final String codigo;
  final String rotulo;
  final String? horario;
  final CrossAxisAlignment alinhamento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: alinhamento,
      children: [
        Text(
          codigo,
          style: tema.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(rotulo, style: tema.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          horario ?? '--',
          style: tema.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Cartão com um título e várias linhas de informação.
class _Bloco extends StatelessWidget {
  const _Bloco({required this.titulo, required this.filhos});

  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...filhos,
          ],
        ),
      ),
    );
  }
}

/// Uma linha "rótulo: valor". Mostra "não informado" quando a API não trouxe.
class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    this.selecionavel = false,
  });

  final IconData icone;
  final String rotulo;
  final String? valor;
  final bool selecionavel;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final texto = valor?.trim();
    final vazio = texto == null || texto.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: tema.colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: tema.textTheme.labelMedium
                      ?.copyWith(color: tema.colorScheme.outline),
                ),
                const SizedBox(height: 2),
                if (vazio)
                  Text(
                    'não informado',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: tema.colorScheme.outline,
                    ),
                  )
                else if (selecionavel)
                  SelectableText(texto, style: tema.textTheme.bodyMedium)
                else
                  Text(texto, style: tema.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
