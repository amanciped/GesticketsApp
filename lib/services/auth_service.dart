import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String loginUrl = 'http://10.0.2.2:8081/login/api/autenticar';
  static String? token;
  static String? rol;

  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['username'];
        rol = data['rol'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String nombreCompleto,
    required String username,
    required String password,
    required String nacionalidad,
    required String rol,
  }) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8081/login/api/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombreCompleto': nombreCompleto,
        'username': username,
        'password': password,
        'nacionalidad': nacionalidad,
        'rol': rol.toUpperCase(),
      }),
    );

    return response.statusCode == 200;
  }

  static void logout() {
    token = null;
    rol = null;
  }
}