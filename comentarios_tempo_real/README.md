# Comentários em Tempo Real

Continuação do Mural da Turma da aula de 19/10. Cadastro, login, perfil e publicações continuam iguais, o que eu adicionei foram os comentários.

- Cada publicação tem um botão de comentários que abre a tela `ComentariosPage` com a publicação e os comentários dela
- Os comentários ficam na collection `comentarios` com: `texto`, `autorNome`, `autorId` (uid), `publicacaoId` e `data`
- A tela usa `StreamBuilder` com `snapshots()`, então o comentário aparece pra todo mundo que está com a discussão aberta sem precisar atualizar
- O botão de excluir só aparece nos comentários do próprio usuário, e as regras do Firestore (`firestore.rules`) também só deixam o autor excluir

Arquivos novos: `lib/services/comentario_service.dart` e `lib/pages/comentarios_page.dart`. Alterado: `lib/pages/home_page.dart`.

Usa o projeto do Firebase `framework-etapa3` (configuração web no `lib/firebase_options.dart`), com login por e-mail/senha ativado e as regras do `firestore.rules` publicadas.

## Questões

**Como o Firebase identifica quem escreveu determinado comentário?**

Pelo uid do usuário logado no Firebase Authentication. Quando o comentário é criado eu salvo `autorId: FirebaseAuth.instance.currentUser!.uid` junto com o nome. Nas regras, o `request.auth.uid` é comparado com esse `autorId`, então ninguém consegue criar comentário no nome de outra pessoa.

**Como relacionar um comentário a uma publicação específica?**

Salvando o id do documento da publicação no campo `publicacaoId` do comentário. Na tela de comentários a consulta é `where('publicacaoId', isEqualTo: id)`, então só vêm os comentários daquela publicação.

**Por que utilizamos StreamBuilder para mostrar os comentários?**

Porque o `snapshots()` devolve uma Stream que fica escutando a collection. Toda vez que alguém adiciona ou exclui um comentário o Firestore manda os dados novos e o StreamBuilder reconstrói a lista sozinho. Com um `get()` normal a lista só seria buscada uma vez.

**Como garantir que os comentários apareçam automaticamente em contas diferentes?**

Todas as contas leem a mesma collection no Firestore e cada tela aberta está escutando com `snapshots()`. Quando uma conta grava um comentário, o Firestore avisa todas as telas que estão escutando aquela consulta, e elas atualizam na hora.

## Como rodar

```
flutter pub get
flutter run -d chrome
```
