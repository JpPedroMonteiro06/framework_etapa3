# Integração Python API + Flutter

Atividade prática da **Aula 19 (professora Janaína)**: um backend em Python que faz
**web scraping de voos** no FlightAware e expõe os dados por uma API JSON, e um
**aplicativo Flutter** que consome essa API e apresenta os voos de forma organizada.

```
FLIGHTAWARE → WEB SCRAPING → PYTHON / FLASK → API JSON
            → FLUTTER → SERVICE → PROVIDER → PAGES → USUÁRIO
```

## Os dois projetos

| Pasta | O que é |
|-------|---------|
| [`AulaJanaina - Webscraping/`](AulaJanaina%20-%20Webscraping/) | Backend Python/Flask — scraping + API JSON |
| [`voos_app/`](voos_app/) | Aplicativo Flutter que consome a API |

O Python é usado **apenas como backend/API**. Toda a parte visual está no Flutter.

## Como rodar (dois terminais ao mesmo tempo)

### Terminal 1 — Python

```shell
cd "AulaJanaina - Webscraping"
pip install -r requirements.txt
python app.py
```

Deve aparecer `Running on http://127.0.0.1:5001`. Para testar no navegador:

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

## A API

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api` | Lista os endpoints |
| GET | `/api/voos` | Scraping ao vivo (não grava no banco) |
| POST | `/api/voos/sincronizar` | Scraping + grava a coleta |
| GET | `/api/historico/coletas` | Coletas salvas |
| GET | `/api/historico/coletas/<id>` | Detalhe de uma coleta |

Parâmetros: `?aeroporto=SBGR&tipo=chegadas|partidas|todos`

Resposta de `/api/voos`:

```json
{
  "fonte": "https://www.flightaware.com/live/airport/SBGR",
  "aeroporto": "SBGR",
  "tipo_busca": "chegadas",
  "total": 39,
  "voos": [
    {
      "categoria": "chegadas",
      "identificacao": "GLO7649",
      "tipo_aeronave": "B38M",
      "local": "Jorge Newbery ( AEP )",
      "partida": "09:10a -03",
      "chegada": "11:11a -03"
    }
  ]
}
```

## Estrutura do app Flutter

```
lib/
├── main.dart               # monta o app, registra o Provider e o tema
├── models/
│   ├── voo.dart            # um voo + categoria, companhia, código do aeroporto
│   └── resultado_voos.dart # resposta completa da API
├── pages/
│   ├── home_page.dart      # busca, tipo de voo, lista agrupada
│   ├── detalhes_page.dart  # todas as informações do voo escolhido
│   └── estilo_voo.dart     # cores/ícones por categoria e aeroportos sugeridos
├── providers/
│   └── voo_provider.dart   # estado: voos, carregando, erro (ChangeNotifier)
└── services/
    └── voo_service.dart    # única camada que faz HTTP e converte o JSON
```

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
- **Tipo de voo** — `chegadas`, `partidas` ou `todos`, enviado para a API.
- **Tela inicial** — indicador de carregamento, mensagem de erro com botão de
  tentar novamente, lista agrupada por categoria (Chegadas, Em rota, Partidas),
  pull-to-refresh e filtro local por voo, companhia ou cidade.
- **Tela de detalhes** — aberta com `Navigator.push()`, mostra o trajeto, a
  companhia (deduzida do prefixo ICAO da identificação), o modelo da aeronave,
  os horários e os dados da consulta feita na API.
- **`device_preview`** — em modo debug o app abre dentro de um simulador de
  aparelhos.

## Testes

```shell
cd voos_app
flutter test
```

Os testes usam um cliente HTTP falso (`MockClient`), então passam mesmo com o
terminal do Python fechado. Cobrem a conversão do JSON, o estado do provider
(carregamento, erro, filtro, query string enviada) e a navegação da tela inicial
para a tela de detalhes.
