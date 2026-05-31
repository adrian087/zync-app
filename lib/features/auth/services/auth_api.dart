import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<String> loginBackend(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        if (response.body.trim().startsWith('<')) {
          throw Exception('El servidor está en mantenimiento (Error 502).');
        }
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error']);
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<bool> registroBackend(String nombres, String apellidos, String username, String email, String password) async {
    final url = Uri.parse('$_baseUrl/registro');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombres': nombres,       
          'apellidos': apellidos,   
          'username': username, 
          'email': email, 
          'password': password
        }),
      );

      if (response.statusCode == 201) return true; 

      if (response.body.trim().startsWith('<')) {
        throw Exception('El servidor de base de datos está apagado.');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Error desconocido');
      
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }


  Future<Map<String, dynamic>> solicitarCodigoReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return {'success': true};

      if (response.body.trim().startsWith('<')) return {'success': false, 'error': 'El servidor no responde.'};
      return {'success': false, 'error': jsonDecode(response.body)['error']};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión. Inténtalo de nuevo.'};
    }
  }

  Future<Map<String, dynamic>> verificarCodigoReset(String email, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return {'success': true};

      if (response.body.trim().startsWith('<')) return {'success': false, 'error': 'El servidor no responde.'};
      return {'success': false, 'error': jsonDecode(response.body)['error']};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión. Inténtalo de nuevo.'};
    }
  }

  Future<Map<String, dynamic>> cambiarPasswordConCodigo(String email, String codigo, String nuevaPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'codigo': codigo, 'nuevaPassword': nuevaPassword}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return {'success': true};

      if (response.body.trim().startsWith('<')) return {'success': false, 'error': 'El servidor no responde.'};
      return {'success': false, 'error': jsonDecode(response.body)['error']};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión. Inténtalo de nuevo.'};
    }
  }
}