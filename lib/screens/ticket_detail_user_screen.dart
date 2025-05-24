import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

const Color naranja = Color(0xFFFF6F00);

class TicketDetailUser extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailUser({super.key, required this.ticket});

  @override
  State<TicketDetailUser> createState() => _TicketDetailUserState();
}

class _TicketDetailUserState extends State<TicketDetailUser> {
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
      headers: {
        'Authorization': 'Bearer ${AuthService.token}'
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _comentarios = json.decode(response.body);
        _loadingComentarios = false;
      });
    } else {
      setState(() {
        _loadingComentarios = false;
      });
    }
  }

  void _agregarComentario(BuildContext context) {
    final TextEditingController _comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Nuevo Comentario', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _comentarioController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Escribe tu comentario',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: naranja)),
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
                  'Authorization': 'Bearer ${AuthService.token}'
                },
                body: json.encode({'contenido': contenido}),
              );

              Navigator.of(ctx).pop();

              if (response.statusCode == 200) {
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
            child: const Text('Enviar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _detalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comentariosContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comentarios:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        ..._comentarios.map((c) {
          final contenido = c['contenido'];
          final autor = c['autor']?['username'] ?? 'Anónimo';
          final fechaRaw = c['fecha'] ?? '';
          final fecha = DateTime.tryParse(fechaRaw);
          final fechaFormateada = fecha != null
              ? '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
              : 'Fecha desconocida';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text.rich(
              TextSpan(
                text: '- $contenido\n',
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                    text: 'por $autor el $fechaFormateada',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.white60,
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
      return const Center(child: CircularProgressIndicator(color: naranja));
    }

    if (_comentarios.isEmpty) {
      return const Text('No hay comentarios aún.', style: TextStyle(color: Colors.white70));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: _comentariosContenido(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Detalle del Ticket'),
        backgroundColor: Colors.black,
      ),
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
            _detalle('Creador ID', ticket['creador']?['id']?.toString() ?? 'Desconocido'),
            _detalle('Gestor ID', ticket['gestorAsignado']?['id']?.toString() ?? 'No asignado'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.comment),
              label: const Text('Añadir Comentario'),
              onPressed: () => _agregarComentario(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: naranja,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            _buildComentarios(),
          ],
        ),
      ),
    );
  }
}