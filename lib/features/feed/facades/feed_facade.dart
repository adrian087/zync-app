import 'dart:convert'; 
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:http/http.dart' as http; 
import '../services/feed_api.dart';

class FeedFacade {
  final FeedApi _api = FeedApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<List<dynamic>> cargarFeedCachado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cache = prefs.getString('feed_cache_parati');
      if (cache != null) return jsonDecode(cache); 
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> cargarFeed({int page = 1}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No hay token guardado.');

      final publicaciones = await _api.obtenerPublicaciones(token, page: page);

      if (page == 1 && publicaciones.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('feed_cache_parati', jsonEncode(publicaciones));
      }
      return publicaciones;
    } catch (e) {
      return []; 
    }
  }

  Future<bool> crearPublicacion(String contenido, {List<XFile>? imagenes}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/publicaciones'));
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['contenido'] = contenido;

      if (imagenes != null && imagenes.isNotEmpty) {
        for (var imagen in imagenes) {
          if (kIsWeb) {
            final bytes = await imagen.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes('imagenes', bytes, filename: imagen.name),
            );
          } else {
            request.files.add(
              await http.MultipartFile.fromPath('imagenes', imagen.path),
            );
          }
        }
      }

      final response = await request.send();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> alternarLike(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No hay sesión activa.');
      return await _api.alternarLike(token, publicacionId);
    } catch (e) {
      return false; 
    }
  }

  Future<List<dynamic>> obtenerComentarios(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];
      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> comentar(int publicacionId, String contenido, {int? comentarioPadreId}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/comentarios');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'contenido': contenido, 'comentario_padre_id': comentarioPadreId}),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> cargarFeedSiguiendo() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No hay sesión activa.');
      final publicaciones = await _api.obtenerPublicacionesSiguiendo(token);
      if (publicaciones.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('feed_cache_siguiendo', jsonEncode(publicaciones));
      }
      return publicaciones;
    } catch (e) {
      return []; 
    }
  }

  Future<List<dynamic>> cargarFeedSiguiendoCachado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cache = prefs.getString('feed_cache_siguiendo');
      if (cache != null) return jsonDecode(cache);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> alternarReZync(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/rezync');
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false; 
    }
  }

  Future<bool> alternarGuardado(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId/guardar');
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      return response.statusCode == 200;
    } catch (e) {
      return false; 
    }
  }

  Future<List<dynamic>> cargarGuardados() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];
      final url = Uri.parse('$_baseUrl/publicaciones/guardadas');
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> editarZync(int publicacionId, String nuevoContenido) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      final response = await http.put(
        Uri.parse('$_baseUrl/publicaciones/$publicacionId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'contenido': nuevoContenido}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> cargarStories() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];
      return await _api.obtenerStories(token);
    } catch (e) {
      return [];
    }
  }

  Future<bool> registrarVistaStory(int storyId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      return await _api.verStory(token, storyId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> subirStory(dynamic media, String tipo, {int? maxVis}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/stories'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['tipo'] = tipo;
      if (maxVis != null) {
        request.fields['max_visualizaciones'] = maxVis.toString();
      }

      if (kIsWeb) {
        final bytes = await media.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('media', bytes, filename: 'story.jpg'),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('media', media.path),
        );
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likeStory(int storyId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      return await _api.likeStory(token, storyId);
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> obtenerVistasStory(int storyId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];
      return await _api.obtenerVistasStory(token, storyId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> borrarStory(int storyId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      return await _api.borrarStory(token, storyId);
    } catch (e) {
      return false;
    }
  }

  Future<bool> borrarComentario(int comentarioId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;
      return await _api.borrarComentario(token, comentarioId);
    } catch (e) {
      return false;
    }
  }
}