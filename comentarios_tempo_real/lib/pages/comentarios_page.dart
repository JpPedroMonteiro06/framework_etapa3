import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/comentario_service.dart';

class ComentariosPage extends StatefulWidget {
  final String publicacaoId;
  final String autorNome;
  final String texto;

  const ComentariosPage({
    super.key,
    required this.publicacaoId,
    required this.autorNome,
    required this.texto,
  });

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  final comentario = TextEditingController();
  final service = ComentarioService();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> comentarios =
      service.acompanhar(widget.publicacaoId);
  bool enviando = false;

  @override
  void dispose() {
    comentario.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (comentario.text.trim().isEmpty) return;
    setState(() => enviando = true);
    try {
      await service.comentar(widget.publicacaoId, comentario.text);
      comentario.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao comentar: $e')));
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  Future<void> excluir(String id) async {
    try {
      await service.excluir(id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Column(children: [
        // publicacao que foi aberta
        Card(margin: const EdgeInsets.all(16), child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(widget.autorNome),
          subtitle: Text(widget.texto),
        )),
        const Divider(height: 1),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: comentarios,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Erro ao carregar comentários: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final lista = snapshot.data!.docs.toList();
            // ordena aqui pra nao precisar criar indice no Firestore
            // comentario que acabou de ser enviado ainda vem com data null, entao fica no fim
            lista.sort((a, b) {
              final ta = a.data()['data'] as Timestamp?;
              final tb = b.data()['data'] as Timestamp?;
              final agora = DateTime.now().millisecondsSinceEpoch;
              return (ta?.millisecondsSinceEpoch ?? agora).compareTo(tb?.millisecondsSinceEpoch ?? agora);
            });
            if (lista.isEmpty) return const Center(child: Text('Nenhum comentário ainda.'));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final doc = lista[index];
                final dados = doc.data();
                final meu = dados['autorId'] == service.uidAtual;
                return ListTile(
                  leading: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                  title: Text(dados['autorNome'] ?? 'Usuário', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dados['texto'] ?? ''),
                  // so aparece o botao de excluir nos comentarios do proprio usuario
                  trailing: meu
                      ? IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Excluir comentário', onPressed: () => excluir(doc.id))
                      : null,
                );
              },
            );
          },
        )),
        const Divider(height: 1),
        SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(
            controller: comentario,
            maxLength: 280,
            decoration: const InputDecoration(labelText: 'Escreva um comentário', border: OutlineInputBorder(), counterText: ''),
            onSubmitted: (_) => enviar(),
          )),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: enviando ? null : enviar, icon: const Icon(Icons.send), tooltip: 'Enviar'),
        ]))),
      ]))),
    );
  }
}
