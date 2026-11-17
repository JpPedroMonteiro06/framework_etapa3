# Minha Lista de Filmes

App em Flutter pra guardar os filmes que quero assistir, usando MVVM + Provider + Service + SQLite.

## Estrutura

- `models/filme.dart` - classe Filme (id, titulo, assistido)
- `services/filme_service.dart` - acesso ao SQLite (banco filmes.db, tabela filmes)
- `viewmodels/filme_viewmodel.dart` - lista de filmes e notifyListeners
- `pages/pagina_inicial.dart` - tela com o TextField, o botao e a lista

Fluxo: View -> ViewModel -> Service -> SQLite

Quando o app abre o ViewModel ja chama o `carregarFilmes()`, que faz o SELECT no banco.

## Como rodar

```
flutter pub get
flutter run -d chrome
```

Os arquivos `sqlite3.wasm` e `sqflite_sw.js` da pasta web sao necessarios pro SQLite funcionar no Chrome.
