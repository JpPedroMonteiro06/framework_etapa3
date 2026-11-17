# Cadastro de Feiticeiros

App da Escola Jujutsu com Flutter, Firebase Authentication (login com Google) e Cloud Firestore.

- Se não estiver logado abre a tela de login, se estiver vai pra Central Jujutsu
- Na central mostra a foto, o nome e o email de quem entrou
- Dá pra cadastrar, listar, marcar como concluída e excluir missões
- Cada missão salva o `usuarioId` com o uid do usuário, e a lista usa `where('usuarioId', isEqualTo: uid)`, então cada feiticeiro só vê as missões dele

As missões ficam na collection `missoes_jujutsu`. As regras que usei no Firestore estão no arquivo `firestore.rules`.

## Como rodar

O `firebase_options.dart` não está no repositório, precisa gerar com o flutterfire. No console do Firebase tem que ativar o login com Google em Authentication.

```
flutter pub get
dart pub global run flutterfire_cli:flutterfire configure
flutter run -d chrome
```
