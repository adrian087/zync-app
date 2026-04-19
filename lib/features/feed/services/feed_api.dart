import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedApi {
  // Misma URL base que usamos en el login
  final String _baseUrl = 'http://localhost:3000/api';

  // Fíjate que le pedimos el token por parámetro para poder entrar
  Future<List<dynamic>> obtenerPublicaciones(String token) async {
    final url = Uri.parse('$_baseUrl/publicaciones');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // ¡Aquí le enseñamos el pasaporte VIP al servidor!
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Si el servidor responde OK, devolvemos la lista de tweets convertida desde JSON
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor al cargar el feed');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> crearPublicacion(String token, String contenido) async {
    final url = Uri.parse('$_baseUrl/publicaciones');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // Enviamos el texto en formato JSON
        body: jsonEncode({'contenido': contenido}),
      );

      // Si el servidor responde con 201 (Creado) o 200 (OK), ha sido un éxito
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al publicar');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> alternarLike(String token, int publicacionId) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/like');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Si el servidor responde 200 OK (ya sea poniendo o quitando el like), devolvemos true
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error de conexión al dar like: $e');
      return false;
    }
  }

  // --- AÑADE ESTO ---
  // Obtener comentarios
  Future<List<dynamic>> obtenerComentarios(String token, int publicacionId) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar comentarios');
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  // Escribir un comentario
  Future<bool> crearComentario(String token, int publicacionId, String contenido) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'contenido': contenido}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error al comentar: $e');
      return false;
    }
  }
}
