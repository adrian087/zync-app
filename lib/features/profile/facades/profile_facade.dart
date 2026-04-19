import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileFacade {
  final _storage = const FlutterSecureStorage();
  
  
  final String _baseUrl = 'http://localhost:3000/api';

  Future<Map<String, dynamic>?> cargarDatosPerfil() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;

      final url = Uri.parse('$_baseUrl/perfil');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error al cargar perfil: $e');
      return null;
    }
  }

  // --- AÑADE ESTE MÉTODO ---
  Future<bool> borrarPublicacion(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId');
      
      // Fíjate que usamos http.delete en lugar de get o post
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Si el servidor responde 200 OK, el borrado fue un éxito
      return response.statusCode == 200;
    } catch (e) {
      print('Error al borrar publicación: $e');
      return false;
    }
  }
}