# Cadastro de Feiticeiros

App da Escola Jujutsu com Flutter, Firebase Authentication (login com Google) e Cloud Firestore.

- Se não estiver logado abre a tela de login, se estiver vai pra Central Jujutsu
- Na central mostra a foto, o nome e o email de quem entrou
- Dá pra cadastrar, listar, marcar como concluída e excluir missões
- Cada missão salva o `usuarioId` com o uid do usuário, e a lista usa `where('usuarioId', isEqualTo: uid)`, então cada feiticeiro só vê as missões dele

As missões ficam na collection `missoes_jujutsu`. As regras que usei no Firestore estão no arquivo `firestore.rules`.

## Como rodar

Usa o projeto do Firebase `framework-etapa3` (configuração web no `lib/firebase_options.dart`), com o login do Google ativado em Authentication.

```
flutter pub get
flutter run -d chrome
```
