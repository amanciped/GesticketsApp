import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/auth_service.dart';

const Color naranja = Color(0xFFFF6F00);

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String? _categoriaSeleccionada;
  bool _isLoading = false;

  final List<String> _categorias = ['HARDWARE', 'SOFTWARE'];

  Future<void> _crearTicket() async {
    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty || _categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8081/tickets/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}'
      },
      body: jsonEncode({
        'titulo': _tituloController.text,
        'descripcion': _descripcionController.text,
        'categoria': _categoriaSeleccionada!.toUpperCase()
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket creado exitosamente')),
      );
      _tituloController.clear();
      _descripcionController.clear();
      setState(() => _categoriaSeleccionada = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear ticket: ${response.body}')),
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
        title: const Text('Crear Ticket'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: _tituloController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Título'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Descripción'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Categoría'),
              value: _categoriaSeleccionada,
              items: _categorias.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) => setState(() => _categoriaSeleccionada = value),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: naranja))
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _crearTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: naranja,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Crear Ticket',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}