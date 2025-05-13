import 'package:flutter/material.dart';
import '../widgets/ticket_form.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TicketForm(),
      ),
    );
  }
}