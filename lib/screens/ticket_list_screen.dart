import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'new_ticket_screen.dart';
import 'ticket_detail_screen.dart';


class TicketListScreen extends StatefulWidget {
  @override
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final List<Ticket> _tickets = [];

  void _addTicket(Ticket ticket) {
    setState(() {
      _tickets.add(ticket);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tickets de TI')),
      body: _tickets.isEmpty
          ? Center(child: Text('No hay tickets.'))
          : ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (ctx, i) {
                final ticket = _tickets[i];
                return ListTile(
                  title: Text(ticket.title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: ticket),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push<Ticket>(
            MaterialPageRoute(builder: (_) => NewTicketScreen()),
          );
          if (result != null) _addTicket(result);
        },
      ),
    );
  }
}