import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/comment.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081/tickets';

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthService.token}',
  };

  static Future<bool> crearTicket(Ticket ticket) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: _headers(),
      body: jsonEncode(ticket.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/by-usuario'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Ticket.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener los tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener los tickets: $e');
      rethrow;
    }
  }

  static Future<bool> updateTicket(Ticket ticket) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${ticket.titulo}'),
      headers: _headers(),
      body: jsonEncode(ticket.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTicket(String titulo) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$titulo'),
      headers: _headers(),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> asignarTicket(String titulo, String agente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$titulo/asignar'),
      headers: _headers(),
      body: jsonEncode({'asignadoA': agente}),
    );
    return response.statusCode == 200;
  }

  static Future<List<Comment>> getComentarios(String tituloTicket) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$tituloTicket/comentarios'),
      headers: _headers(),
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
      headers: _headers(),
      body: jsonEncode(comentario.toJson()),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> resolverTicket(String titulo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$titulo/resolver'),
      headers: _headers(),
      body: jsonEncode({
        'estado': 'resuelto',
        'fechaResolucion': DateTime.now().toIso8601String(),
      }),
    );
    return response.statusCode == 200;
  }

  static Future<List<Ticket>> getTicketsPorEstado(String estado) async {
    final response = await http.get(
      Uri.parse('$baseUrl?estado=$estado'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Ticket.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener tickets');
    }
  }
}