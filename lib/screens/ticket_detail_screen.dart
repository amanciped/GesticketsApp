import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.title),
            SizedBox(height: 12),
            Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.description),
            SizedBox(height: 12),
            Text('Categoría:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.category),
            SizedBox(height: 12),
            Text('Fecha y hora de creación:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket.createdAt.toString()),
          ],
        ),
      ),
    );
  }
}