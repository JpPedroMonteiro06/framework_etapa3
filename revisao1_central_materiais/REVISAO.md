# Revisão 1

Nome: João Pedro Monteiro Esteves Casaes
Turma: 3A1

| Teste | Resultado esperado | Resultado encontrado |
|---|---|---|
| Nome vazio/espaços | Não salva e mostra "Preencha este campo." | OK - recusado com "Preencha este campo." |
| Quantidade negativa | Não salva e mostra que só aceita inteiro >= 0 | OK - "-3" recusado com "Use somente números inteiros maiores ou iguais a zero." |
| Quantidade decimal | Não salva e mostra a mesma mensagem | OK - "2.5" e "2,5" recusados (letras "abc" também) |
| Nome repetido com maiúsculas/espaços | " microfone " é recusado | OK - recusado com "Já existe um material com esse nome." |
| Edição mantendo o próprio nome | Salva normalmente | OK - salvou |
| Edição para o nome de outro material | Não salva | OK - Microfone renomeado para "cabo hdmi" foi recusado |
| Cadastro com atualização automática | O material aparece na lista logo depois de cadastrar | OK - cadastrei Projetor e Tripé e a lista foi de 4 para 6 sem recarregar |
| Edição persistida após recarregar | A alteração continua depois de recarregar | OK - Microfone editado para 6 continuou 6 depois de carregar de novo do banco |
| Cancelamento da exclusão | O material continua na lista | OK - ao cancelar o diálogo o `_excluir` sai antes de chamar o repositório, nada é apagado |
| Exclusão individual | Só o material escolhido some | OK - excluí Projetor e os outros 5 continuaram |
| Quantidade zero e mínimo zero | Sem estoque | OK - Sem estoque |
| Quantidade igual ao mínimo | Estoque adequado | OK - Estoque adequado (e 2 com mínimo 3 deu Estoque baixo) |

## Explique uma validação

Qual validação foi escolhida?

A validação das quantidades (disponível e mínima), que só aceita números inteiros maiores ou iguais a zero.

Em qual arquivo e método ela foi implementada?

No arquivo `lib/utils/validadores.dart`, no método `Validadores.quantidade`. Ele recusa campo vazio e usa uma expressão regular que só aceita dígitos, então letras, o sinal de menos (negativo) e ponto ou vírgula (decimal) não passam.

Por que esse local é adequado para essa responsabilidade?

Porque a regra fica num lugar só e é usada por duas camadas: a tela usa no `validator` do formulário pra mostrar a mensagem embaixo do campo, e a ViewModel chama de novo no `salvar` antes de gravar. Se a regra mudar, só muda aqui. O Repository fica só com o acesso ao banco e não precisa saber de regra de formulário.
