import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class TicketForm extends StatefulWidget {
  const TicketForm({super.key});

  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _categoria = 'Software';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final ticket = Ticket(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        categoria: _categoria,
        estado: 'abierto',
      );

      final success = await ApiService.crearTicket(ticket);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Ticket creado exitosamente' : 'Error al crear ticket'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _tituloController,
            decoration: InputDecoration(labelText: 'Título'),
            validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
          ),
          TextFormField(
            controller: _descripcionController,
            decoration: InputDecoration(labelText: 'Descripción'),
            validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
          ),
          DropdownButtonFormField<String>(
            value: _categoria,
            items: ['Software', 'Hardware']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) => setState(() => _categoria = value!),
            decoration: InputDecoration(labelText: 'Categoría'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Crear Ticket'),
          ),
        ],
      ),
    );
  }
}
