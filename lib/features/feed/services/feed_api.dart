import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:http/http.dart' as http;

class FeedApi {
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<List<dynamic>> obtenerPublicaciones(String token, {int page = 1}) async {
    final url = Uri.parse('$_baseUrl/publicaciones?page=$page');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error del servidor al cargar el feed');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> crearPublicacion(String token, String contenido, File? imagen) async {
    final url = Uri.parse('$_baseUrl/publicaciones');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['contenido'] = contenido;

      if (imagen != null) {
        if (kIsWeb) {
          final bytes = await imagen.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes('imagen', bytes, filename: 'post.jpg'));
        } else {
          request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));
        }
      }
      var response = await request.send();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> alternarLike(String token, int publicacionId) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/like');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> obtenerComentarios(String token, int publicacionId) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al cargar comentarios');
    } catch (e) {
      return [];
    }
  }

  Future<bool> crearComentario(String token, int publicacionId, String contenido) async {
    final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'contenido': contenido}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> obtenerPublicacionesSiguiendo(String token) async {
    final url = Uri.parse('$_baseUrl/publicaciones/siguiendo');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al cargar feed de seguidos');
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> obtenerStories(String token) async {
    final url = Uri.parse('$_baseUrl/stories');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> verStory(String token, int storyId) async {
    final url = Uri.parse('$_baseUrl/stories/$storyId/ver');
    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> subirStory(String token, File media, String tipo, int? maxVis) async {
    final url = Uri.parse('$_baseUrl/stories');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['tipo'] = tipo;
      if (maxVis != null) request.fields['max_visualizaciones'] = maxVis.toString();

      if (kIsWeb) {
        final bytes = await media.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('media', bytes, filename: 'story.jpg'));
      } else {
        request.files.add(await http.MultipartFile.fromPath('media', media.path));
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likeStory(String token, int storyId) async {
    final url = Uri.parse('$_baseUrl/stories/$storyId/like');
    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> obtenerVistasStory(String token, int storyId) async {
    final url = Uri.parse('$_baseUrl/stories/$storyId/vistas');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> borrarStory(String token, int storyId) async {
    final url = Uri.parse('$_baseUrl/stories/$storyId');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> borrarComentario(String token, int comentarioId) async {
    final url = Uri.parse('$_baseUrl/comentarios/$comentarioId');
    try {
      final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}