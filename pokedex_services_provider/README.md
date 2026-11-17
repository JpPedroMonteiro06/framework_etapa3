# Pokédex - Services, Flask e Provider

Continuação da Pokédex da aula.

Caminho dos dados: PokéAPI -> Flask -> Service -> Provider -> Tela. O Flutter não chama a PokéAPI direto, as chamadas HTTP ficam todas no `services/pokemon_service.dart` e o estado no `providers/pokemon_provider.dart`.

## O que foi feito

**Parte 1 - Buscar pelo nome**
- Rota nova no Flask: `GET /pokemons/nome/<nome>` (devolve id, nome, imagem, tipo, altura e peso)
- Na tela inicial tem um TextField e o botão Pesquisar. O resultado aparece num card e clicando nele abre os detalhes

**Parte 2 - Mais informações**
- Escolhi **ataque especial** e **velocidade** (`special-attack` e `speed` nos stats da PokéAPI)
- No Flask juntei a montagem do JSON de detalhes numa função `montar_detalhes` e guardei os stats pelo nome
- Na tela de detalhes aparecem no card de Atributos, junto com HP, ataque e defesa

**Parte 3 - Funcionalidade nova: Pokémon aleatório (opção A)**
- Rota `GET /pokemons/aleatorio`, que sorteia um id de 1 a 1025
- Botão "Pokémon Aleatório" na tela inicial, que abre os detalhes do Pokémon sorteado

## Como rodar

Backend:

```
cd backend
pip install -r requirements.txt
python app.py
```

App (com o Flask rodando na porta 5001):

```
cd pokemonapp
flutter pub get
flutter run -d chrome
```
