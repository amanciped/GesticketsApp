import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

class TicketDetailGestorScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailGestorScreen({super.key, required this.ticket});

  @override
  State<TicketDetailGestorScreen> createState() => _TicketDetailGestorScreenState();
}

class _TicketDetailGestorScreenState extends State<TicketDetailGestorScreen> {
  List<dynamic> _comentarios = [];
  bool _loadingComentarios = true;

  @override
  void initState() {
    super.initState();
    _fetchComentarios();
  }

  Future<void> _fetchComentarios() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8081/tickets/comentario/${widget.ticket['id']}'),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _comentarios = json.decode(response.body);
        _loadingComentarios = false;
      });
    } else {
      setState(() => _loadingComentarios = false);
    }
  }

  void _agregarComentario(BuildContext context) {
    final TextEditingController _comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Comentario'),
        content: TextField(
          controller: _comentarioController,
          decoration: const InputDecoration(hintText: 'Escribe tu comentario'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final contenido = _comentarioController.text.trim();
              if (contenido.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El comentario no puede estar vacío.')),
                );
                return;
              }

              final response = await http.post(
                Uri.parse('http://10.0.2.2:8081/tickets/comentario/${widget.ticket['id']}'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${AuthService.token}',
                },
                body: json.encode({'contenido': contenido}),
              );

              Navigator.of(ctx).pop();

              if (response.statusCode == 200 || response.statusCode == 201) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comentario añadido')),
                );
                _fetchComentarios();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${response.body}')),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _detalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _comentariosContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comentarios:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._comentarios.map((c) {
          final contenido = c['contenido'];
          final autor = c['autor']?['username'] ?? 'Anónimo';
          final fechaRaw = c['fecha'] ?? '';
          final fecha = DateTime.tryParse(fechaRaw);
          final fechaFormateada = fecha != null
              ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
              : 'Fecha desconocida';

          final esGestor = autor == AuthService.token;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text.rich(
              TextSpan(
                text: '- $contenido\n',
                children: [
                  TextSpan(
                    text: 'por $autor el $fechaFormateada',
                    style: TextStyle(
                      fontWeight: esGestor ? FontWeight.bold : FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildComentarios() {
    if (_loadingComentarios) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comentarios.isEmpty) {
      return const Text('No hay comentarios aún.');
    }

    return SizedBox(
      height: 250,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(child: _comentariosContenido()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _detalle('ID', ticket['id'].toString()),
            _detalle('Título', ticket['titulo']),
            _detalle('Descripción', ticket['descripcion']),
            _detalle('Categoría', ticket['categoria']),
            _detalle('Estado', ticket['estado']),
            _detalle('Prioridad', ticket['prioridad'] ?? 'No asignada'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.comment),
              label: const Text('Añadir Comentario'),
              onPressed: () => _agregarComentario(context),
            ),
            const SizedBox(height: 24),
            _buildComentarios(),
          ],
        ),
      ),
    );
  }
}