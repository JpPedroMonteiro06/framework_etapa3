# Laudo Técnico - Operação Resgate: Detetives de Bugs

Projeto: Central de Achados e Perdidos (Flutter + Firebase)

O caminho investigado foi `main` -> `GatePage` -> `CentralPage` -> `DetalhePage`, passando pelo `CentralService` e pelo modelo `Ocorrencia`. O enunciado fala em 12 bugs; na investigação apareceram 13 pontos com defeito, todos registrados abaixo.

Pré-requisito (não é bug): o arquivo `lib/firebase_options.dart` não vem no ZIP, como avisa o README. Ele precisa ser gerado com o FlutterFire CLI (`flutterfire configure`) no projeto Firebase da turma, com o login Google ativado no Authentication.

---

## Bug 01 - Texto quebrado no subtítulo do card

- **Arquivo:** `lib/pages/central_page.dart` (subtítulo do `ListTile`)
- **Sintoma:** o projeto não compilava. O analisador acusava string não terminada.
- **Causa:** a string com aspas simples tinha uma quebra de linha "de verdade" no meio. Em Dart, uma string com aspas simples precisa ficar numa linha só.
- **Correção:** troquei a quebra de linha pelo `\n`:
  `'${o.local} • ${...}\nPor ${o.autorNome}'`
- **Teste:** o erro de string some do `flutter analyze` e o card mostra o local/status na primeira linha e "Por ..." na segunda.

## Bug 02 - DetalhePage aberta sem a ocorrência

- **Arquivo:** `lib/pages/central_page.dart` (`onTap` do card)
- **Sintoma:** erro de compilação: o parâmetro obrigatório `ocorrencia` não foi passado.
- **Causa:** `DetalhePage` exige `required this.ocorrencia`, mas era chamada como `DetalhePage()`. A tela de detalhes não teria como saber qual objeto mostrar.
- **Correção:** `MaterialPageRoute(builder: (_) => DetalhePage(ocorrencia: o))`.
- **Teste:** o app compila; ao tocar em um card abre a tela "Investigação" com o título, local e autor daquele item.

## Bug 03 - autorId lido do campo errado

- **Arquivo:** `lib/models/ocorrencia.dart` (`fromDoc`)
- **Sintoma:** o dono de um registro não conseguia marcar o objeto como encontrado. O botão nunca aparecia para ninguém.
- **Causa:** o `autorId` era preenchido com `d['autorNome']`. A tela compara o `uid` do usuário com o `autorId`, e um nome nunca é igual a um uid.
- **Correção:** `autorId: d['autorId'] as String? ?? ''`. Também separei a leitura em `fromMap` para conseguir testar sem Firebase.
- **Teste:** teste automatizado em `test/widget_test.dart` ("lê o autorId do campo certo").

## Bug 04 - Status "resolvido" invertido

- **Arquivo:** `lib/models/ocorrencia.dart` (`fromDoc`)
- **Sintoma:** objetos recém-registrados apareciam como "Resolvido" e os resolvidos como "Em aberto".
- **Causa:** havia um `!` na leitura: `!(d['resolvido'] ...)`. O banco salva `false` e o app mostrava `true`.
- **Correção:** `resolvido: d['resolvido'] as bool? ?? false`.
- **Teste:** teste automatizado ("status resolvido não vem invertido") e, no app, um objeto novo aparece como "Em aberto".

## Bug 05 - Ordem dos registros

- **Arquivo:** `lib/services/central_service.dart` (`acompanhar`)
- **Sintoma:** os registros novos iam para o fim da lista, e era preciso rolar para encontrar o que acabou de ser cadastrado.
- **Causa:** `orderBy('criadoEm', descending: false)` ordena do mais antigo para o mais novo.
- **Correção:** `descending: true`, para mostrar o mais recente no topo.
- **Teste:** registrar o objeto A e depois o B; o B deve aparecer em cima do A.

## Bug 06 - Dono salvo com o e-mail em vez do uid

- **Arquivo:** `lib/services/central_service.dart` (`registrar`)
- **Sintoma:** mesmo com o Bug 03 corrigido, o dono continuava sem permissão para alterar o status ("Apenas o dono pode alterar o status").
- **Causa:** o registro gravava `'autorId': u.email`, mas `alterarStatus` e a `DetalhePage` comparam com `u.uid`.
- **Correção:** `'autorId': u.uid`. O nome exibido continua vindo de `displayName`/e-mail.
- **Teste:** na conta A, registrar um objeto e abrir o detalhe: o botão "Marcar como resolvido" aparece. No Firestore, o campo `autorId` do documento é o uid da conta A.

## Bug 07 - Marcar como encontrado não mudava nada

- **Arquivo:** `lib/services/central_service.dart` (`alterarStatus`)
- **Sintoma:** o dono clicava em "Marcar como resolvido", a tela fechava, mas o status continuava igual.
- **Causa:** o update gravava o próprio valor atual: `{'resolvido': item.resolvido}`.
- **Correção:** `{'resolvido': !item.resolvido}`, que inverte o status (resolver / reabrir).
- **Teste:** marcar como resolvido e conferir que o card muda para "Resolvido"; abrir de novo e usar "Reabrir" para voltar a "Em aberto".

## Bug 08 - Pistas salvas na ocorrência errada

- **Arquivo:** `lib/services/central_service.dart` (`enviarPista`)
- **Sintoma:** as pistas enviadas não apareciam em nenhuma ocorrência. Só aparece observando o Firestore: todas iam para `ocorrencias/pistas/pistas`.
- **Causa:** o caminho usava o texto fixo `doc('pistas')` em vez do id recebido.
- **Correção:** `doc(ocorrenciaId).collection('pistas')`, o mesmo caminho que o método `pistas(id)` usa para ler.
- **Teste:** na conta B, enviar uma pista no objeto da conta A; a pista aparece só naquele objeto, nas duas contas, e fica em `ocorrencias/<id>/pistas` no Firestore.

## Bug 09 - Validação deixava passar campo vazio

- **Arquivo:** `lib/pages/central_page.dart` (`cadastrar`)
- **Sintoma:** dava para registrar um objeto sem título ou sem local; o aviso só aparecia se os dois estivessem vazios.
- **Causa:** a condição usava `&&` (os dois vazios) em vez de `||` (qualquer um vazio).
- **Correção:** `if (titulo.text.trim().isEmpty || local.text.trim().isEmpty)`.
- **Teste:** tentar registrar só com o título preenchido aparece "Informe título e local." e nada é salvo; com os dois preenchidos, registra.

## Bug 10 - Switch "Somente não resolvidos" invertido

- **Arquivo:** `lib/pages/central_page.dart` (`SwitchListTile`)
- **Sintoma:** ao tocar no switch ele não ligava, ou ficava no estado contrário do que o usuário escolheu.
- **Causa:** `somenteAbertos = !value` grava o oposto do valor recebido.
- **Correção:** `somenteAbertos = value`.
- **Teste:** tocar no switch liga, tocar de novo desliga.

## Bug 11 - Filtro mostrava os resolvidos

- **Arquivo:** `lib/pages/central_page.dart` (filtro da lista)
- **Sintoma:** com o filtro "Somente não resolvidos" ligado, a lista mostrava justamente os resolvidos.
- **Causa:** `where((o) => o.resolvido)` mantém os resolvidos.
- **Correção:** `where((o) => !o.resolvido)`.
- **Teste:** com um objeto resolvido e outro em aberto, ligar o filtro: só o "Em aberto" fica na lista.

## Bug 12 - Botão de enviar pista com a condição invertida

- **Arquivo:** `lib/pages/detalhe_page.dart` (`enviar`)
- **Sintoma:** ao digitar uma pista e enviar, nada acontecia; com o campo vazio, a função continuava.
- **Causa:** `if (pista.text.trim().isNotEmpty) return;` sai da função quando existe texto.
- **Correção:** `if (pista.text.trim().isEmpty) return;`
- **Teste:** com o campo vazio, nada é enviado; com texto, a pista é enviada e o campo é limpo.

## Bug 13 - Pista enviada sem o texto

- **Arquivo:** `lib/pages/detalhe_page.dart` (`enviar`)
- **Sintoma:** depois de corrigir o Bug 12, as pistas apareciam em branco na lista.
- **Causa:** a chamada enviava uma string vazia fixa: `enviarPista(widget.ocorrencia.id, '')`.
- **Correção:** `enviarPista(widget.ocorrencia.id, pista.text)`.
- **Teste:** enviar "Vi na cantina" e conferir que a pista aparece com esse texto e com o nome de quem enviou.

---

## Ajustes extras (não fazem parte dos 13)

- `test/widget_test.dart` era o teste padrão do contador (`MyApp`, pacote `bugsresolver`), que não existe neste projeto (o pacote se chama `central_achados`). Troquei por testes do modelo `Ocorrencia`.
- `pubspec.yaml` não tinha `dev_dependencies`, mas o `analysis_options.yaml` usa `flutter_lints` e o teste usa `flutter_test`. Adicionei os dois.

## Observação sobre autorização

O app esconde o botão de status para quem não é dono e o `CentralService` também confere o `uid`. Mesmo assim, a proteção de verdade tem que estar nas regras do Firestore, por exemplo permitindo `update` do campo `resolvido` só quando `request.auth.uid == resource.data.autorId`. As regras de segurança não foram desativadas nem alteradas.

Registros antigos, criados antes da correção do Bug 06, têm o e-mail no `autorId`. Por isso o dono não consegue alterar o status deles; é preciso criar registros novos para testar.

## Teste com duas contas

1. Rodar com `flutter run -d chrome` e abrir em duas janelas (uma normal e uma anônima, ou dois perfis do navegador).
2. Conta A: registrar uma ocorrência. Ela aparece sozinha na conta B, sem recarregar (`snapshots()` do Firestore).
3. Conta B: abrir a ocorrência e enviar uma pista. A pista aparece na mesma ocorrência na conta A.
4. Conta B: não vê o botão "Marcar como resolvido" na ocorrência da conta A. Conta A vê e consegue alterar.

Print das duas contas visualizando a mesma ocorrência: `prints/duas-contas.png`
