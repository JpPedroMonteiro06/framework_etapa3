// Tela inicial: busca por aeroporto, escolha do tipo de voo e lista de voos.
//
// A tela NÃO faz http.get. Ela lê tudo do VooProvider e pede novas buscas
// chamando os métodos do provider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/voo.dart';
import '../providers/voo_provider.dart';
import 'detalhes_page.dart';
import 'estilo_voo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _aeroportoController;
  final TextEditingController _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<VooProvider>();
    _aeroportoController = TextEditingController(text: provider.aeroporto);

    // Primeira carga assim que a tela aparece.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.carregarVoos();
    });
  }

  @override
  void dispose() {
    _aeroportoController.dispose();
    _filtroController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<VooProvider>();
    final ok = await provider.buscarPorAeroporto(_aeroportoController.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Informe um código ICAO com 4 letras (ex.: SBGR, SBSP).',
            ),
          ),
        );
    }
  }

  void _selecionarSugestao(String icao) {
    _aeroportoController.text = icao;
    _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VooProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Voos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: provider.carregando ? null : provider.carregarVoos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.carregarVoos,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Busca(
                controller: _aeroportoController,
                onBuscar: _buscar,
                onSugestao: _selecionarSugestao,
              ),
            ),
            SliverToBoxAdapter(
              child: _Resumo(filtroController: _filtroController),
            ),
            ..._corpo(provider),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /// Escolhe entre carregando / erro / vazio / lista de voos.
  List<Widget> _corpo(VooProvider provider) {
    if (provider.carregando) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Mensagem(
            icone: null,
            titulo: 'Buscando voos...',
            descricao:
                'O Python está raspando o painel do FlightAware neste momento.',
          ),
        ),
      ];
    }

    if (provider.erro != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Mensagem(
            icone: Icons.cloud_off,
            titulo: 'Não foi possível carregar',
            descricao: provider.erro!,
            acao: FilledButton.icon(
              onPressed: provider.carregarVoos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ),
        ),
      ];
    }

    if (provider.voos.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Mensagem(
            icone: Icons.search_off,
            titulo: provider.temFiltroAtivo
                ? 'Nenhum voo com esse filtro'
                : 'Nenhum voo encontrado',
            descricao: provider.temFiltroAtivo
                ? 'Tente outro termo ou limpe o filtro.'
                : 'O painel de ${provider.aeroporto} não trouxe voos de '
                    '"${provider.tipo.rotulo.toLowerCase()}" agora.',
          ),
        ),
      ];
    }

    // Voos agrupados por categoria, com um cabeçalho por grupo.
    final linhas = <Widget>[];
    provider.voosPorCategoria.forEach((categoria, lista) {
      linhas.add(_TituloGrupo(categoria: categoria, quantidade: lista.length));
      linhas.addAll(lista.map((voo) => _CartaoVoo(voo: voo)));
    });

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, indice) => linhas[indice],
          childCount: linhas.length,
        ),
      ),
    ];
  }
}

/// Campo do código ICAO, atalhos de aeroportos e seletor de tipo de voo.
class _Busca extends StatelessWidget {
  const _Busca({
    required this.controller,
    required this.onBuscar,
    required this.onSugestao,
  });

  final TextEditingController controller;
  final VoidCallback onBuscar;
  final ValueChanged<String> onSugestao;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VooProvider>();
    final cores = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: cores.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onBuscar(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                    LengthLimitingTextInputFormatter(4),
                    _MaiusculasFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Código ICAO',
                    hintText: 'SBGR',
                    prefixIcon: const Icon(Icons.local_airport),
                    filled: true,
                    fillColor: cores.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: provider.carregando ? null : onBuscar,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: aeroportosSugeridos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, indice) {
                final sugestao = aeroportosSugeridos[indice];
                final selecionado = sugestao.icao == provider.aeroporto;
                return ChoiceChip(
                  label: Text('${sugestao.icao} · ${sugestao.nome}'),
                  selected: selecionado,
                  onSelected: provider.carregando
                      ? null
                      : (_) => onSugestao(sugestao.icao),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TipoBusca>(
              segments: const [
                ButtonSegment(
                  value: TipoBusca.chegadas,
                  label: Text('Chegadas'),
                  icon: Icon(Icons.flight_land),
                ),
                ButtonSegment(
                  value: TipoBusca.partidas,
                  label: Text('Partidas'),
                  icon: Icon(Icons.flight_takeoff),
                ),
                ButtonSegment(
                  value: TipoBusca.todos,
                  label: Text('Todos'),
                  icon: Icon(Icons.all_inclusive),
                ),
              ],
              selected: {provider.tipo},
              onSelectionChanged: provider.carregando
                  ? null
                  : (selecao) => provider.alterarTipo(selecao.first),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faixa com o total de voos, o horário da consulta e o filtro local.
class _Resumo extends StatelessWidget {
  const _Resumo({required this.filtroController});

  final TextEditingController filtroController;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VooProvider>();
    final tema = Theme.of(context);
    final resultado = provider.resultado;
    final nome = nomeDoAeroporto(provider.aeroporto);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome == null
                          ? provider.aeroporto
                          : '${provider.aeroporto} · $nome',
                      style: tema.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      resultado == null
                          ? 'Aguardando a API Python'
                          : '${provider.voos.length} de '
                              '${provider.totalRecebido} voos · '
                              'atualizado às '
                              '${horaFormatada(resultado.buscadoEm)}',
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (provider.carregando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (resultado != null && provider.totalRecebido > 0) ...[
            const SizedBox(height: 12),
            TextField(
              controller: filtroController,
              onChanged: provider.alterarFiltro,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Filtrar por voo, companhia ou cidade',
                prefixIcon: const Icon(Icons.filter_alt_outlined),
                suffixIcon: provider.temFiltroAtivo
                    ? IconButton(
                        tooltip: 'Limpar filtro',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          filtroController.clear();
                          provider.limparFiltro();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cabeçalho de cada grupo de voos (Chegadas, Partidas, Em rota...).
class _TituloGrupo extends StatelessWidget {
  const _TituloGrupo({required this.categoria, required this.quantidade});

  final CategoriaVoo categoria;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final estilo = EstiloCategoria.de(categoria);
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(estilo.icone, size: 18, color: estilo.cor),
          const SizedBox(width: 8),
          Text(
            categoria.rotulo.toUpperCase(),
            style: tema.textTheme.labelLarge?.copyWith(
              color: estilo.cor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Text('($quantidade)', style: tema.textTheme.labelMedium),
          const Expanded(child: Divider(indent: 12)),
        ],
      ),
    );
  }
}

/// Cartão de um voo na lista. Ao tocar, abre a tela de detalhes.
class _CartaoVoo extends StatelessWidget {
  const _CartaoVoo({required this.voo});

  final Voo voo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estilo = EstiloCategoria.de(voo.categoria);
    final horario = voo.categoria.ehChegada ? voo.chegada : voo.partida;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalhesPage(voo: voo)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: estilo.cor.withValues(alpha: 0.12),
                foregroundColor: estilo.cor,
                child: Icon(estilo.icone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            voo.identificacao,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (voo.tipoAeronave != null) ...[
                          const SizedBox(width: 8),
                          _Etiqueta(texto: voo.tipoAeronave!),
                        ],
                      ],
                    ),
                    if (voo.companhia != null)
                      Text(voo.companhia!, style: tema.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          voo.categoria.ehChegada
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 14,
                          color: tema.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${voo.rotuloLocal}: '
                            '${voo.local ?? "não informado"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    horario ?? '--',
                    style: tema.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    voo.categoria.ehChegada ? 'chegada' : 'partida',
                    style: tema.textTheme.labelSmall
                        ?.copyWith(color: tema.colorScheme.outline),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta pequena usada para o modelo da aeronave.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(texto, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// Estado de carregamento / erro / lista vazia, no meio da tela.
class _Mensagem extends StatelessWidget {
  const _Mensagem({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
  });

  /// Quando null, mostra um CircularProgressIndicator no lugar do ícone.
  final IconData? icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icone == null)
            const CircularProgressIndicator()
          else
            Icon(icone, size: 56, color: tema.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: tema.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium
                ?.copyWith(color: tema.colorScheme.outline),
          ),
          if (acao != null) ...[
            const SizedBox(height: 20),
            acao!,
          ],
        ],
      ),
    );
  }
}

/// Deixa o código ICAO sempre em maiúsculas enquanto o usuário digita.
class _MaiusculasFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue novo,
  ) {
    return novo.copyWith(text: novo.text.toUpperCase());
  }
}
