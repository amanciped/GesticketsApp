
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ticket_detail_gestor_screen.dart';
import 'ticket_edit_gestor_screen.dart';
import '../services/auth_service.dart';

class TicketListGestorScreen extends StatefulWidget {
  const TicketListGestorScreen({super.key});

  @override
  State<TicketListGestorScreen> createState() => _TicketListGestorScreenState();
}

class _TicketListGestorScreenState extends State<TicketListGestorScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8081/tickets/my'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _tickets = json.decode(response.body);
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

  void _verDetalle(dynamic ticket) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TicketDetailGestorScreen(ticket: ticket)),
    );
    _fetchTickets();
  }

  void _editarTicket(dynamic ticket) async {
    if (ticket['estado'] == 'CERRADO') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ticket cerrado', style: TextStyle(color: Colors.white)),
          content: const Text('Este ticket ya está cerrado y no se puede editar.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    } else {
      final actualizado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketEditGestorScreen(ticket: ticket)),
      );
      if (actualizado == true) _fetchTickets();
    }
  }

  void _mostrarConfirmacionEliminar(dynamic ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar ticket?', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que deseas borrar el ticket sin finalizarlo?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.orange)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _eliminarTicket(ticket['id']);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarTicket(int ticketId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8081/tickets/delete/$ticketId'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket eliminado')),
        );
        _fetchTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado al eliminar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Mis Tickets Asignados'),
        backgroundColor: Colors.black,
        elevation: 4,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _tickets.isEmpty
          ? const Center(
        child: Text(
          'No tienes tickets asignados.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          final prioridad = (ticket['prioridad'] ?? 'NO').toString().toUpperCase();

          IconData icono = Icons.help_outline;
          Color color = Colors.grey;

          switch (prioridad) {
            case 'ALTA':
              icono = Icons.priority_high;
              color = Colors.red;
              break;
            case 'MEDIA':
              icono = Icons.priority_high;
              color = Colors.orange;
              break;
            case 'BAJA':
              icono = Icons.priority_high;
              color = Colors.green;
              break;
          }

          final estaCerrado = ticket['estado'] == 'CERRADO';
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: estaCerrado ? Colors.grey[700] : Colors.black54,
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
              onTap: () => _verDetalle(ticket),
              leading: Icon(icono, color: color),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(
                ticket['titulo'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: estaCerrado ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                ticket['descripcion'],
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    tooltip: 'Editar',
                    onPressed: () => _editarTicket(ticket),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Eliminar',
                    onPressed: () => _mostrarConfirmacionEliminar(ticket),
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