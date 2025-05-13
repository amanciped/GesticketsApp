import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8081/api/tickets'; // ajusta según tu backend

  static Future<bool> crearTicket(Ticket ticket) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(ticket.toJson()),
    );

    return response.statusCode == 201; // suponiendo que tu backend responde con 201
  }
}