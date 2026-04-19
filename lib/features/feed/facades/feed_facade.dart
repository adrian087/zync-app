import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/feed_api.dart';

class FeedFacade {
  final FeedApi _api = FeedApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<dynamic>> cargarFeed() async {
    try {
      // 1. Buscamos la llave maestra (El Token) en la caja fuerte
      final token = await _storage.read(key: 'jwt_token');

      // 2. Si por algún motivo no hay token, devolvemos una lista vacía y avisamos
      if (token == null) {
        throw Exception('No hay token guardado. Debes iniciar sesión.');
      }

      // 3. Le pasamos el token al Servicio para que vaya a Node.js a por los datos
      final publicaciones = await _api.obtenerPublicaciones(token);
      
      // 4. Devolvemos la lista de tweets lista para ser pintada
      return publicaciones;

    } catch (e) {
      print('Error en FeedFacade: $e');
      // Si algo falla, devolvemos una lista vacía para que la app no se rompa
      return []; 
    }
  }

  Future<bool> crearPublicacion(String contenido) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No hay sesión activa.');
      }

      // Llamamos al servicio para crear el post
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

  // --- AÑADE ESTO ---
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