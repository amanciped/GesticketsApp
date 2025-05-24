import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

class EditTicketScreen extends StatefulWidget {
  final int ticketId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String estado;

  const EditTicketScreen({
    super.key,
    required this.ticketId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
  });

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  String? _categoriaSeleccionada;
  bool _isLoading = false;

  final List<String> _categorias = ['HARDWARE', 'SOFTWARE'];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _descripcionController = TextEditingController(text: widget.descripcion);
    _categoriaSeleccionada = widget.categoria.toUpperCase();
  }

  Future<void> _actualizarTicket() async {
    if (widget.estado == 'CERRADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este ticket está cerrado y no puede ser modificado.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8081/tickets/edit/${widget.ticketId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}'
      },
      body: jsonEncode({
        'titulo': _tituloController.text,
        'descripcion': _descripcionController.text,
        'categoria': _categoriaSeleccionada
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizado correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                hint: const Text('Selecciona una categoría'),
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _actualizarTicket,
                child: const Text('Actualizar Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}