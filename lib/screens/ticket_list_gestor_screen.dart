import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ticket_detail_gestor_screen.dart';
import 'ticket_edit_gestor_screen.dart'; // Asegúrate de tener esta pantalla creada
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
    _fetchTickets(); // recargar al volver
  }

  void _editarTicket(dynamic ticket) async {
    if (ticket['estado'] == 'CERRADO') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ticket cerrado'),
          content: const Text('Este ticket ya está cerrado y no se puede editar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
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
        title: const Text('¿Eliminar ticket?'),
        content: const Text('¿Estás seguro que deseas borrar el ticket sin finalizarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('Mis Tickets Asignados')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
          ? const Center(child: Text('No tienes tickets asignados.'))
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
          return Card(
            color: estaCerrado ? Colors.grey[200] : null, // Fondo gris si está cerrado
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              onTap: () => _verDetalle(ticket),
              leading: Icon(icono, color: color),
              title: Text(
                ticket['titulo'],
                style: TextStyle(
                  color: estaCerrado ? Colors.black54 : Colors.black,
                  fontWeight: estaCerrado ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                ticket['descripcion'],
                style: TextStyle(
                  color: estaCerrado ? Colors.black45 : Colors.black87,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar',
                    onPressed: () => _editarTicket(ticket),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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