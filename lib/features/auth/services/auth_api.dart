import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // Como usas el simulador de iPhone en Mac, localhost funciona perfectamente.
  // (Si usaras un emulador de Android, tendrías que poner 10.0.2.2 en lugar de localhost)
  final String _baseUrl = 'http://localhost:3000/api';

  Future<String> loginBackend(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      // Hacemos la petición POST a tu servidor Node.js
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Le decimos que enviamos JSON
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Si el servidor responde con 200 OK
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Devolvemos el Token real (eyJ...)
      } else {
        // Si hay un error (ej: 401 Email o contraseña incorrectos)
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']);
      }
    } catch (e) {
      // Error si el servidor está apagado o no hay internet
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}