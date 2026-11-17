# Revisão 1

Nome: João Pedro Monteiro Esteves Casaes
Turma: 3A1

| Teste | Resultado esperado | Resultado encontrado |
|---|---|---|
| Nome vazio/espaços | Não salva e mostra "Preencha este campo." | |
| Quantidade negativa | Não salva e mostra "Use somente números inteiros maiores ou iguais a zero." | |
| Quantidade decimal | Não salva e mostra a mesma mensagem | |
| Nome repetido com maiúsculas/espaços | " microfone " é recusado: "Já existe um material com esse nome." | |
| Edição mantendo o próprio nome | Salva normalmente | |
| Edição para o nome de outro material | Não salva e mostra "Já existe um material com esse nome." | |
| Cadastro com atualização automática | O material aparece na lista logo depois de cadastrar | |
| Edição persistida após recarregar | A alteração continua depois de recarregar a página | |
| Cancelamento da exclusão | O material continua na lista | |
| Exclusão individual | Só o material escolhido some, os outros continuam | |
| Quantidade zero e mínimo zero | Sem estoque | |
| Quantidade igual ao mínimo | Estoque adequado | |

## Explique uma validação

Qual validação foi escolhida?

A validação das quantidades (disponível e mínima), que só aceita números inteiros maiores ou iguais a zero.

Em qual arquivo e método ela foi implementada?

No arquivo `lib/utils/validadores.dart`, no método `Validadores.quantidade`. Ele recusa campo vazio e usa uma expressão regular que só aceita dígitos, então letras, o sinal de menos (negativo) e ponto ou vírgula (decimal) não passam.

Por que esse local é adequado para essa responsabilidade?

Porque a regra fica num lugar só e é usada por duas camadas: a tela usa no `validator` do formulário pra mostrar a mensagem embaixo do campo, e a ViewModel chama de novo no `salvar` antes de gravar. Se a regra mudar, só muda aqui. O Repository fica só com o acesso ao banco e não precisa saber de regra de formulário.
