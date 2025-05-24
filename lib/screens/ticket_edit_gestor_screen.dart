
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cerrarTicket
              ? 'Ticket cerrado correctamente'
              : 'Cambios guardados'),
        ),
      );
      Navigator.pop(context, true);
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Editar Ticket'),
        backgroundColor: Colors.black,
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Detalles del Ticket',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            _detalle('ID', ticket['id'].toString()),
            _detalle('Título', ticket['titulo']),
            _detalle('Descripción', ticket['descripcion']),
            _detalle('Categoría', ticket['categoria']),
            _detalle('Estado actual', ticket['estado']),
            _detalle('Prioridad actual', ticket['prioridad'] ?? 'No asignada'),
            const Divider(height: 32, color: Colors.white24),
            const Text(
              'Editar Estado y Prioridad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _estadoActual,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Estado',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
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
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _guardarCambios(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Marcar como Solucionado'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                foregroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _guardarCambios(cerrarTicket: true),
            ),
          ],
        ),
      ),
    );
  }
}