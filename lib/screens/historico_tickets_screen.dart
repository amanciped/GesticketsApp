import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class HistoricoTicketsScreen extends StatefulWidget {
  const HistoricoTicketsScreen({super.key});

  @override
  State<HistoricoTicketsScreen> createState() => _HistoricoTicketsScreenState();
}

class _HistoricoTicketsScreenState extends State<HistoricoTicketsScreen> {
  late Future<List<Ticket>> _ticketsCerrados;

  @override
  void initState() {
    super.initState();
    _ticketsCerrados = ApiService.getTicketsPorEstado('resuelto');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Tickets')),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsCerrados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tickets cerrados'));
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