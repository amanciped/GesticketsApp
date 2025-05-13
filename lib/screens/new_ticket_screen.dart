import 'package:flutter/material.dart';
import '../models/ticket.dart';

class NewTicketScreen extends StatefulWidget {
  @override
  _NewTicketScreenState createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Hardware', 'Software'];

  void _submit() {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedCategory == null) return;

    final newTicket = Ticket(
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory!,
    );

    Navigator.of(context).pop(newTicket);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(labelText: 'Título'),
            controller: _titleController,
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Descripción'),
            controller: _descController,
            maxLines: 3,
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: Text('Seleccione categoría'),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Guardar Ticket'),
            onPressed: _submit,
          )
        ]),
      ),
    );
  }
}
