import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class EditTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const EditTicketScreen({super.key, required this.ticket});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late String _categoria;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.ticket.titulo);
    _descripcionController = TextEditingController(text: widget.ticket.descripcion);
    _categoria = widget.ticket.categoria;
  }

  void _updateTicket() async {
    if (_formKey.currentState!.validate()) {
      final updatedTicket = Ticket(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        categoria: _categoria,
        estado: widget.ticket.estado,
      );

      final success = await ApiService.updateTicket(updatedTicket);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Actualizado correctamente' : 'Error al actualizar'),
          ),
        );

        if (success) Navigator.pop(context); // volver a la pantalla anterior
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.ticket.estado != 'cerrado';

    return Scaffold(
      appBar: AppBar(title: Text('Editar Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: editable
            ? Form(
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
                decoration: InputDecoration(labelText: 'Categoría'),
                items: ['Software', 'Hardware']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _categoria = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTicket,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        )
            : Center(
          child: Text('Este ticket está cerrado y no puede ser modificado.'),
        ),
      ),
    );
  }
}