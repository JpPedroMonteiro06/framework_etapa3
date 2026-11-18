# Central de Missões

App Flutter + Cloud Firestore pra cadastrar missões, concluir, excluir e somar os pontos das concluídas.

Fácil = 10 pontos, Médio = 20, Difícil = 30.

Fiz também os dois desafios extras: campo data e tela de detalhes (clicando na missão).

## Estrutura

```
lib/
  main.dart
  models/missao.dart
  providers/missao_provider.dart
  services/missao_service.dart
  pages/home_page.dart
  pages/detalhes_page.dart
  widgets/estrelas.dart
```

HomePage -> MissaoProvider -> MissaoService -> Cloud Firestore (collection `missoes`)

## Como rodar

Usa o projeto do Firebase `framework-etapa3` (configuração web no `lib/firebase_options.dart`).

```
flutter pub get
flutter run -d chrome
```
