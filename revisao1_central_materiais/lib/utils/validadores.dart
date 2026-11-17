class Validadores {
  static String? textoObrigatorio(String? valor) {
    // trim() tira os espaços, entao "   " vira texto vazio
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha este campo.';
    }
    return null;
  }

  static String? quantidade(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe a quantidade.';
    }

    // so aceita digitos: recusa letras, sinal de menos, ponto e virgula
    if (!RegExp(r'^\d+$').hasMatch(valor.trim())) {
      return 'Use somente números inteiros maiores ou iguais a zero.';
    }

    if (int.tryParse(valor.trim()) == null) {
      return 'Número muito grande.';
    }

    return null;
  }
}
