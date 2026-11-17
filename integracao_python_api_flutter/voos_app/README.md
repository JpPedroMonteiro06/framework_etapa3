# Painel de Voos — Flutter + API Python

Aplicativo Flutter que consome a API do projeto Python da **Aula 19** (webscraping
de voos no FlightAware) e apresenta os voos de forma organizada.

```
FLIGHTAWARE → WEB SCRAPING → PYTHON/FLASK → API JSON
            → FLUTTER → SERVICE → PROVIDER → PAGES → USUÁRIO
```

## Como rodar (dois terminais abertos ao mesmo tempo)

### Terminal 1 — Python

```shell
cd "AulaJanaina - Webscraping"
pip install -r requirements.txt
python app.py
```

Deve aparecer `Running on http://127.0.0.1:5001`. Para conferir, abra no navegador:

```
http://127.0.0.1:5001/api/voos?aeroporto=SBGR&tipo=chegadas
```

Se aparecer um JSON, deixe esse terminal aberto.

### Terminal 2 — Flutter

```shell
cd voos_app
flutter pub get
flutter run -d chrome
```

Se o terminal do Python for fechado, o app mostra a tela de erro com o botão
**Tentar novamente**.

### Rodando em celular ou emulador

O endereço da API é escolhido automaticamente:

| Plataforma | Endereço usado |
|------------|----------------|
| Flutter Web / Windows | `http://127.0.0.1:5001` |
| Emulador Android | `http://10.0.2.2:5001` |

Em um celular físico, aponte para o IP da máquina que roda o Flask:

```shell
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:5001
```

## Estrutura

```
lib/
├── main.dart               # monta o app, registra o Provider e o tema
├── models/
│   ├── voo.dart            # um voo + categoria, companhia, código do aeroporto
│   └── resultado_voos.dart # resposta completa da API (metadados + lista)
├── pages/
│   ├── home_page.dart      # busca, tipo de voo, lista agrupada
│   ├── detalhes_page.dart  # todas as informações do voo escolhido
│   └── estilo_voo.dart     # cores/ícones por categoria e aeroportos sugeridos
├── providers/
│   └── voo_provider.dart   # estado: voos, carregando, erro (ChangeNotifier)
└── services/
    └── voo_service.dart    # única camada que faz HTTP e converte o JSON
```

### Responsabilidades

| Pasta | Sabe |
|-------|------|
| `services` | **como buscar** os dados (HTTP + JSON) |
| `providers` | **quais dados** o app tem agora (estado, carregamento, erro) |
| `pages` | **como mostrar** os dados |

As telas nunca chamam `http.get`: elas falam com o `VooProvider`, que chama o
`VooService`, que chama a API Python. Quando os dados voltam, o provider chama
`notifyListeners()` e as telas se redesenham.

## O que o app faz

- **Busca por aeroporto** — campo para o código ICAO (4 letras) e atalhos para
  SBGR, SBSP, SBBR, SBCF, SBGL, SBRJ, SBCT, SBPA, SBSV e SBRF.
- **Tipo de voo** — `chegadas`, `partidas` ou `todos`, enviado para a API em
  `/api/voos?aeroporto=SBGR&tipo=chegadas`.
- **Tela inicial** — indicador de carregamento, mensagem de erro com botão de
  tentar novamente, lista dos voos agrupada por categoria (Chegadas, Em rota,
  Partidas) e um filtro local por voo, companhia ou cidade.
- **Tela de detalhes** — aberta com `Navigator.push()`, mostra o trajeto, a
  companhia (deduzida do prefixo ICAO da identificação), o modelo da aeronave,
  os horários e os dados da consulta feita na API.
- **`device_preview`** — em modo debug o app abre dentro de um simulador de
  aparelhos, para conferir o layout em vários tamanhos de tela.

## Testes

```shell
flutter test
```

Os testes usam um cliente HTTP falso (`MockClient`), então passam mesmo com o
terminal do Python fechado. Eles cobrem a conversão do JSON, o estado do
provider (carregamento, erro, filtro, query string enviada) e a navegação da
tela inicial para a tela de detalhes.
