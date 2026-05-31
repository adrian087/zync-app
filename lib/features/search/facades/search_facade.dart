import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/search_api.dart'; 

class SearchFacade {
  final SearchApi _api = SearchApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<dynamic>> buscarUsuarios(String query) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('No hay sesión activa.');
      }

      return await _api.buscarUsuarios(token, query);

    } catch (e) {
      print('Error en SearchFacade: $e');
      return []; 
    }
  }

  Future<List<dynamic>> buscarPublicaciones(String query) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) throw Exception('No hay sesión');
      return await _api.buscarPublicaciones(token, query);
    } catch (e) {
      print('Error en Facade publicaciones: $e');
      return []; 
    }
  }
}