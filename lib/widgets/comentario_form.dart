import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/comment.dart';

class ComentarioForm extends StatefulWidget {
  final String tituloTicket;

  const ComentarioForm({super.key, required this.tituloTicket});

  @override
  State<ComentarioForm> createState() => _ComentarioFormState();
}

class _ComentarioFormState extends State<ComentarioForm> {
  final _controller = TextEditingController();

  void _agregarComentario() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final nuevoComentario = Comment(
      contenido: texto,
      autor: 'agente_soporte', // deberías reemplazar con usuario actual
      fecha: DateTime.now().toIso8601String(),
    );

    final exito = await ApiService.agregarComentario(widget.tituloTicket, nuevoComentario);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(exito ? 'Comentario añadido' : 'Error al comentar')),
      );

      if (exito) {
        _controller.clear();
        setState(() {}); // Refrescar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Agregar comentario',
          ),
        ),
        ElevatedButton(
          onPressed: _agregarComentario,
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}