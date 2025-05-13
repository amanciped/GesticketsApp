import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.getTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de Soporte')),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay solicitudes'));
          } else {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return TicketCard(
                  ticket: tickets[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: tickets[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}