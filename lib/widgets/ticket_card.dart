import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ticket.titulo),
        subtitle: Text(ticket.descripcion),
        onTap: onTap,
      ),
    );
  }
}
