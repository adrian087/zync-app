import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {

  final String _baseUrl = 'http://localhost:3000/api';

  Future<String> loginBackend(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']);
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}