import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  //static const String loginUrl = 'http://127.0.0.1:8081/api/auth/login'; // actualiza con tu backend real
  static const String loginUrl = 'http://127.0.0.1:8081/login/api/autenticar'; // actualiza con tu backend real

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Aquí puedes guardar el token si se retorna
      final data = json.decode(response.body);
      print('Token recibido: ${data['token']}'); // opcional
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8081/login/api/registro'), // ajusta esto
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': name,
        'email': email,
        'password': password,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

}