
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
            backgroundColor: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Ticket: ${ticket['titulo']}', style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descripción: ${ticket['descripcion']}', style: const TextStyle(color: Colors.white)),
                Text('Categoría: ${ticket['categoria']}', style: const TextStyle(color: Colors.white)),
                Text('ID: ${ticket['id']}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Estado', labelStyle: TextStyle(color: Colors.white)),
                  items: ['ABIERTO', 'EN_ESPERA', 'CERRADO'].map((estado) {
                    return DropdownMenuItem(value: estado, child: Text(estado));
                  }).toList(),
                  onChanged: (value) => setState(() => estadoSeleccionado = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Prioridad', labelStyle: TextStyle(color: Colors.white)),
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
                child: const Text('Cancelar', style: TextStyle(color: Colors.orange)),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment_ind),
                label: const Text('Asignarme'),
                onPressed: (estadoSeleccionado != null && prioridadSeleccionada != null)
                    ? () async {
                  final scaffoldContext = context;
                  Navigator.pop(context);

                  final assignResp = await http.post(
                    Uri.parse('http://10.0.2.2:8081/tickets/assign/${ticket['id']}'),
                    headers: {'Authorization': 'Bearer ${AuthService.token}'},
                  );

                  if (assignResp.statusCode == 200) {
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
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Tickets Sin Asignar'),
        backgroundColor: Colors.black,
        elevation: 4,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _ticketsUnassigned.isEmpty
          ? const Center(
        child: Text(
          'No hay tickets sin asignar.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: _ticketsUnassigned.length,
        itemBuilder: (context, index) {
          final ticket = _ticketsUnassigned[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(
                ticket['titulo'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                ticket['descripcion'],
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.info_outline, color: Colors.orange),
              onTap: () => _verDetalle(ticket),
            ),
          );
        },
      ),
    );
  }
}