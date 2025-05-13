import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'edit_ticket_screen.dart';
import '../services/api_service.dart';
import 'assign_ticket_screen.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título', style: Theme.of(context).textTheme.titleLarge),
            Text(ticket.titulo),
            const SizedBox(height: 20),
            Text('Descripción', style: Theme.of(context).textTheme.titleLarge),
            Text(ticket.descripcion),
            const SizedBox(height: 20),
            Text('Categoría', style: Theme.of(context).textTheme.titleLarge),
            Text(ticket.categoria),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTicketScreen(ticket: ticket),
                  ),
                );
              },
              child: Text('Editar Solicitud'),
            ),

            if (ticket.estado == 'abierto')
              ElevatedButton(
                onPressed: () {
                  _confirmarEliminacion(context, ticket);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Eliminar Solicitud'),
              ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignTicketScreen(ticket: ticket),
                  ),
                );
              },
              child: const Text('Asignar Ticket'),
            ),

          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar esta solicitud?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              final eliminado = await ApiService.deleteTicket(ticket.titulo); // o ticket.id
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(eliminado
                      ? 'Solicitud eliminada correctamente'
                      : 'Error al eliminar la solicitud'),
                ),
              );
              if (eliminado && context.mounted) {
                Navigator.pop(context); // Regresa a la lista
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}