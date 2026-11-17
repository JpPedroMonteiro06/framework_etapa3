import 'package:flutter/material.dart';

class Estrelas extends StatelessWidget {
  final int quantidade;

  const Estrelas({super.key, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        quantidade,
        (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
      ),
    );
  }
}
