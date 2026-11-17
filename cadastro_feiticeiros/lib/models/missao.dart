class Missao {
  String? id;
  String titulo;
  int grau;
  bool concluida;
  String usuarioId;

  Missao({
    this.id,
    required this.titulo,
    required this.grau,
    this.concluida = false,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'grau': grau,
      'concluida': concluida,
      'usuarioId': usuarioId,
    };
  }

  factory Missao.fromMap(String id, Map<String, dynamic> map) {
    return Missao(
      id: id,
      titulo: map['titulo'] ?? '',
      grau: (map['grau'] as num?)?.toInt() ?? 4,
      concluida: map['concluida'] ?? false,
      usuarioId: map['usuarioId'] ?? '',
    );
  }
}
