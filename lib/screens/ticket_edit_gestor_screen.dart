import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

class TicketEditGestorScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketEditGestorScreen({super.key, required this.ticket});

  @override
  State<TicketEditGestorScreen> createState() => _TicketEditGestorScreenState();
}

class _TicketEditGestorScreenState extends State<TicketEditGestorScreen> {
  final List<String> _estados = ['ABIERTO', 'EN_ESPERA', 'CERRADO'];
  final List<String> _prioridades = ['ALTA', 'MEDIA', 'BAJA'];

  late String _estadoActual;
  late String _prioridadActual;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.ticket['estado'] ?? 'ABIERTO';
    _prioridadActual = widget.ticket['prioridad'] ?? 'MEDIA';
  }

  Future<void> _guardarCambios({bool cerrarTicket = false}) async {
    final nuevoEstado = cerrarTicket ? 'CERRADO' : _estadoActual;

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8081/tickets/gestor/update/${widget.ticket['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
      body: jsonEncode({
        'estado': nuevoEstado,
        'prioridad': _prioridadActual,
      }),
    );

    if (response.statusCode == 200) {
      if (cerrarTicket) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket cerrado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
      }
      Navigator.pop(context, true); // volver con éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${response.body}')),
      );
    }
  }
  Widget _detalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Detalles del Ticket',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _detalle('ID', ticket['id'].toString()),
            _detalle('Título', ticket['titulo']),
            _detalle('Descripción', ticket['descripcion']),
            _detalle('Categoría', ticket['categoria']),
            _detalle('Estado actual', ticket['estado']),
            _detalle('Prioridad actual', ticket['prioridad'] ?? 'No asignada'),
            const Divider(height: 32),
            const Text(
              'Editar Estado y Prioridad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _estadoActual,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: _estados.map((estado) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _estadoActual = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _prioridadActual,
              decoration: const InputDecoration(labelText: 'Prioridad'),
              items: _prioridades.map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _prioridadActual = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              onPressed: () => _guardarCambios(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Marcar como Solucionado'),
              onPressed: () => _guardarCambios(cerrarTicket: true),
            ),
          ],
        )
      ),
    );
  }
}