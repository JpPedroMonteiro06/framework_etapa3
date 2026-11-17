class Filme {
  int? id;
  String titulo;
  bool assistido;

  Filme({this.id, required this.titulo, this.assistido = false});

  // no sqlite nao tem bool, entao salva 0 ou 1
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'assistido': assistido ? 1 : 0,
    };
  }

  factory Filme.fromMap(Map<String, dynamic> map) {
    return Filme(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      assistido: map['assistido'] == 1,
    );
  }
}
