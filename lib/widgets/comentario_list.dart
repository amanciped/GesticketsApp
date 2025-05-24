import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/comment.dart';

class ComentarioList extends StatelessWidget {
  final String tituloTicket;

  const ComentarioList({super.key, required this.tituloTicket});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: ApiService.getComentarios(tituloTicket),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error al cargar comentarios');
        } else if (snapshot.data!.isEmpty) {
          return const Text('Sin comentarios');
        } else {
          final comentarios = snapshot.data!;
          return Column(
            children: comentarios
                .map((c) => ListTile(
              title: Text(c.contenido),
              subtitle: Text('${c.autor} – ${c.fecha}'),
            ))
                .toList(),
          );
        }
      },
    );
  }
}