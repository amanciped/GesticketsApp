import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/comment.dart';

class ApiService {
  //static const String baseUrl = 'http://127.0.0.1:8081/api/tickets'; // ajusta según tu backend
  static const String baseUrl = 'http://127.0.0.1:8081/tickets/create'; // ajusta según tu backend

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

  static Future<List<Ticket>> getTickets() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Ticket.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener los tickets');
    }
  }

  static Future<bool> updateTicket(Ticket ticket) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${ticket.titulo}'), // O usa el ID si lo tienes
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ticket.toJson()),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteTicket(String titulo) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$titulo'), // O usa ID si tu backend trabaja con ID
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> asignarTicket(String titulo, String agente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$titulo/asignar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'asignadoA': agente}),
    );

    return response.statusCode == 200;
  }

  static Future<List<Comment>> getComentarios(String tituloTicket) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$tituloTicket/comentarios'),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((c) => Comment.fromJson(c)).toList();
    } else {
      throw Exception('Error al cargar comentarios');
    }
  }

  static Future<bool> agregarComentario(String tituloTicket, Comment comentario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$tituloTicket/comentarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comentario.toJson()),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

}