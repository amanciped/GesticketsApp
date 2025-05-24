import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class AssignTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const AssignTicketScreen({super.key, required this.ticket});

  @override
  State<AssignTicketScreen> createState() => _AssignTicketScreenState();
}

class _AssignTicketScreenState extends State<AssignTicketScreen> {
  final _agenteController = TextEditingController();
  bool _isLoading = false;

  void _asignar() async {
    setState(() => _isLoading = true);

    final success = await ApiService.asignarTicket(
      widget.ticket.titulo,
      _agenteController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Ticket asignado exitosamente'
              : 'Error al asignar el ticket'),
        ),
      );

      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Ticket: ${widget.ticket.titulo}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _agenteController,
              decoration: const InputDecoration(
                labelText: 'Correo o nombre del agente',
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _asignar,
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }
}