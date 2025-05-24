import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

class TicketListUnassignedScreen extends StatefulWidget {
  const TicketListUnassignedScreen({super.key});

  @override
  State<TicketListUnassignedScreen> createState() => _TicketListUnassignedScreenState();
}

class _TicketListUnassignedScreenState extends State<TicketListUnassignedScreen> {
  List<dynamic> _ticketsUnassigned = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8081/tickets/all'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final allTickets = json.decode(response.body) as List;
        setState(() {
          _ticketsUnassigned = allTickets
              .where((ticket) => ticket['gestorAsignado'] == null)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener tickets')),
      );
    }
  }

  void _verDetalle(dynamic ticket) {
    String? estadoSeleccionado;
    String? prioridadSeleccionada;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Ticket: ${ticket['titulo']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descripción: ${ticket['descripcion']}'),
                Text('Categoría: ${ticket['categoria']}'),
                Text('ID: ${ticket['id']}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: ['ABIERTO', 'EN_ESPERA', 'CERRADO'].map((estado) {
                    return DropdownMenuItem(value: estado, child: Text(estado));
                  }).toList(),
                  onChanged: (value) => setState(() => estadoSeleccionado = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: ['ALTA', 'MEDIA', 'BAJA'].map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) => setState(() => prioridadSeleccionada = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment_ind),
                label: const Text('Asignarme'),
                onPressed: (estadoSeleccionado != null && prioridadSeleccionada != null)
                    ? () async {
                  final scaffoldContext = context;
                  Navigator.pop(context);

                  // PRIMERO: asignar ticket
                  final assignResp = await http.post(
                    Uri.parse('http://10.0.2.2:8081/tickets/assign/${ticket['id']}'),
                    headers: {'Authorization': 'Bearer ${AuthService.token}'},
                  );

                  if (assignResp.statusCode == 200) {
                    // SEGUNDO: actualizar estado y prioridad
                    final updateResp = await http.put(
                      Uri.parse('http://10.0.2.2:8081/tickets/gestor/update/${ticket['id']}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${AuthService.token}',
                      },
                      body: jsonEncode({
                        'estado': estadoSeleccionado,
                        'prioridad': prioridadSeleccionada,
                      }),
                    );

                    if (updateResp.statusCode == 200) {
                      Future.delayed(Duration.zero, () {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(content: Text('Ticket asignado exitosamente')),
                        );
                      });
                      _fetchTickets();
                    } else {
                      Future.delayed(Duration.zero, () {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(content: Text('Error al actualizar ticket: ${updateResp.body}')),
                        );
                      });
                    }
                  } else {
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(content: Text('Error al asignar ticket: ${assignResp.body}')),
                      );
                    });
                  }
                }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tickets Sin Asignar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticketsUnassigned.isEmpty
          ? const Center(child: Text('No hay tickets sin asignar.'))
          : ListView.builder(
        itemCount: _ticketsUnassigned.length,
        itemBuilder: (context, index) {
          final ticket = _ticketsUnassigned[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(ticket['titulo']),
              subtitle: Text(ticket['descripcion']),
              trailing: const Icon(Icons.info_outline),
              onTap: () => _verDetalle(ticket),
            ),
          );
        },
      ),
    );
  }
}