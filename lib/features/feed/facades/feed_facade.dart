import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/feed_api.dart';

class FeedFacade {
  final FeedApi _api = FeedApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<dynamic>> cargarFeed() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No hay token guardado. Debes iniciar sesión.');
      }

      final publicaciones = await _api.obtenerPublicaciones(token);
      
      return publicaciones;

    } catch (e) {
      print('Error en FeedFacade: $e');
      return []; 
    }
  }

  Future<bool> crearPublicacion(String contenido) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No hay sesión activa.');
      }

      return await _api.crearPublicacion(token, contenido);

    } catch (e) {
      print('Error al publicar en FeedFacade: $e');
      return false; 
    }
  }

  Future<bool> alternarLike(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No hay sesión activa.');
      }

      return await _api.alternarLike(token, publicacionId);
    } catch (e) {
      print('Error al procesar el like en FeedFacade: $e');
      return false; 
    }
  }

  Future<List<dynamic>> cargarComentarios(int publicacionId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return [];
    return await _api.obtenerComentarios(token, publicacionId);
  }

  Future<bool> publicarComentario(int publicacionId, String contenido) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;
    return await _api.crearComentario(token, publicacionId, contenido);
  }
}