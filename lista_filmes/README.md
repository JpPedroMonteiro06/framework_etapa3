# Minha Lista de Filmes

App em Flutter pra guardar os filmes que quero assistir, usando MVVM + Provider + Service + SQLite.

## Estrutura

- `models/filme.dart` - classe Filme (id, titulo, assistido)
- `services/filme_service.dart` - acesso ao SQLite (banco filmes.db, tabela filmes)
- `viewmodels/filme_viewmodel.dart` - lista de filmes e notifyListeners
- `pages/pagina_inicial.dart` - tela com o TextField, botao e a lista

Fluxo: View -> ViewModel -> Service -> SQLite

## Como rodar

```
flutter pub get
flutter run -d chrome
```

## Teste

Cadastrei Interestelar, Homem-Aranha e Shrek, marquei Interestelar como assistido e reiniciei o app. Os 3 filmes continuaram na lista e o Interestelar continuou marcado e riscado.
