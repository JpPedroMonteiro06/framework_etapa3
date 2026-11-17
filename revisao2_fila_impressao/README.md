# Revisão 2 - Fila de Impressão

Projeto do professor com os problemas corrigidos.

| Problema | Arquivo | O que mudei |
|---|---|---|
| DevicePreview | `main.dart`, `pubspec.yaml` | App dentro do `DevicePreview` com `locale` e `builder`. Também adicionei o `provider` no pubspec, que estava faltando |
| Interface em tela pequena | `pages/impressao_page.dart` | Botões de salvar/cancelar num `Wrap` em vez de `Row` e padding menor |
| Ordem de chegada | `repositories/impressao_repository.dart` - `listar` | `orderBy: 'id DESC'` virou `'id ASC'` |
| Quantidades válidas | `providers/impressao_provider.dart` - `validar` | `< 0` virou `<= 0`, então zero também é recusado (vale pro cadastro e pra edição) |
| Consumo de papel | `providers/impressao_provider.dart` - `folhasDoDocumento` | Era `paginas + copias`, agora é `paginas * copias` |
| Filtro Pendentes | `providers/impressao_provider.dart` - `_mostrar` | Pendentes agora é `impresso == 0` |
| Alternar impressão | `repositories/impressao_repository.dart` - `alternarImpressao` | O where era `'id <> ?'`, agora é `'id = ?'` |

## Correção escolhida

**Qual arquivo e método você alterou?**

`lib/repositories/impressao_repository.dart`, método `alternarImpressao`.

**Qual era a causa do problema?**

O UPDATE usava `where: 'id <> ?'`. O `<>` significa "diferente", então o comando mudava o campo `impresso` de todos os documentos menos o que foi clicado. Por isso os outros mudavam e o escolhido ficava igual.

**Como sua alteração resolveu o comportamento observado?**

Troquei para `where: 'id = ?'`. Agora o UPDATE só pega a linha com o id do documento escolhido. Como a alteração é feita no SQLite e depois a lista é buscada de novo, a marcação continua depois de recarregar a página.

## Como executar

```sh
flutter pub get
flutter run -d chrome --web-port=8080
```
