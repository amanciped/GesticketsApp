import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

const Color naranja = Color(0xFFFF6F00);

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

    if (!_formKey.currentState!.validate()) return;

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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black12,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black54),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: naranja),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Editar Ticket'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Título'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Descripción'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                value: _categoriaSeleccionada,
                decoration: _inputDecoration('Categoría'),
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoriaSeleccionada = value),
                validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: naranja))
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _actualizarTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: naranja,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Actualizar Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}