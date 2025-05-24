import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';
import 'edit_ticket_screen.dart';
import 'ticket_detail_user_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8081/tickets/by-usuario'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _tickets = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar tickets: ${response.body}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarTicket(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8081/tickets/delete/$id'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket eliminado')),
      );
      _fetchTickets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar ticket: ${response.body}')),
      );
    }
  }

  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _eliminarTicket(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editarTicket(dynamic ticket) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTicketScreen(
          ticketId: ticket['id'],
          titulo: ticket['titulo'],
          descripcion: ticket['descripcion'],
          categoria: ticket['categoria'],
          estado: ticket['estado'],
        ),
      ),
    );

    if (actualizado == true) {
      _fetchTickets(); // Recargar después de editar
    }
  }

  void _verDetalle(dynamic ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailUser(ticket: ticket),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tickets')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              onTap: () => _verDetalle(ticket), // ✅ Al hacer click
              title: Text(ticket['titulo']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket['descripcion']),
                  const SizedBox(height: 5),
                  Text("Estado: ${ticket['estado']}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editarTicket(ticket),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarEliminacion(ticket['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}