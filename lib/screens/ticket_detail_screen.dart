import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'edit_ticket_screen.dart';

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
          ],
        ),
      ),
    );
  }
}