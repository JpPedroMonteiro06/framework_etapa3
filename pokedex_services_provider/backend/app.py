from flask import Flask, jsonify
from flask_cors import CORS
import requests
import random

app = Flask(__name__)

CORS(app)

POKEAPI = "https://pokeapi.co/api/v2/pokemon"


# MONTA O JSON DE DETALHES (usado no detalhe e no aleatorio)
def montar_detalhes(dados):

    tipos = []

    for tipo in dados["types"]:
        tipos.append(
            tipo["type"]["name"]
        )


    habilidades = []

    for habilidade in dados["abilities"]:
        habilidades.append(
            habilidade["ability"]["name"]
        )


    # os stats vem numa lista, entao guardo pelo nome do stat
    stats = {}

    for stat in dados["stats"]:
        stats[stat["stat"]["name"]] = stat["base_stat"]


    return {
        "id": dados["id"],
        "nome": dados["name"],
        "imagem": dados["sprites"]["front_default"],
        "altura": dados["height"],
        "peso": dados["weight"],
        "experiencia": dados["base_experience"],
        "tipos": tipos,
        "habilidades": habilidades,
        "hp": stats.get("hp"),
        "ataque": stats.get("attack"),
        "defesa": stats.get("defense"),
        "ataque_especial": stats.get("special-attack"),
        "velocidade": stats.get("speed")
    }


# LISTA DE POKÉMON
@app.route("/pokemons", methods=["GET"])
def listar_pokemons():

    resposta = requests.get(
        f"{POKEAPI}?limit=30"
    )

    dados = resposta.json()

    pokemons = []

    for pokemon in dados["results"]:

        detalhes = requests.get(
            pokemon["url"]
        ).json()

        pokemon_formatado = {
            "id": detalhes["id"],
            "nome": detalhes["name"],
            "imagem": detalhes["sprites"]["front_default"],
            "tipo": detalhes["types"][0]["type"]["name"]
        }

        pokemons.append(
            pokemon_formatado
        )

    return jsonify(pokemons)


# DETALHES DE UM POKÉMON
@app.route("/pokemons/<int:id>", methods=["GET"])
def detalhes_pokemon(id):

    resposta = requests.get(
        f"{POKEAPI}/{id}"
    )

    if resposta.status_code != 200:
        return jsonify({
            "erro": "Pokémon não encontrado"
        }), 404

    return jsonify(
        montar_detalhes(resposta.json())
    )


# PARTE 1 - BUSCAR PELO NOME
@app.route("/pokemons/nome/<nome>", methods=["GET"])
def buscar_por_nome(nome):

    # a PokéAPI so aceita o nome em minusculo
    nome = nome.strip().lower()

    resposta = requests.get(
        f"{POKEAPI}/{nome}"
    )

    if resposta.status_code != 200:
        return jsonify({
            "erro": "Pokémon não encontrado"
        }), 404

    dados = resposta.json()

    pokemon = {
        "id": dados["id"],
        "nome": dados["name"],
        "imagem": dados["sprites"]["front_default"],
        "tipo": dados["types"][0]["type"]["name"],
        "altura": dados["height"],
        "peso": dados["weight"]
    }

    return jsonify(pokemon)


# PARTE 3 - POKÉMON ALEATÓRIO
@app.route("/pokemons/aleatorio", methods=["GET"])
def pokemon_aleatorio():

    id = random.randint(1, 1025)

    resposta = requests.get(
        f"{POKEAPI}/{id}"
    )

    if resposta.status_code != 200:
        return jsonify({
            "erro": "Não foi possível sortear"
        }), 500

    return jsonify(
        montar_detalhes(resposta.json())
    )


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5001,
        debug=True
    )
