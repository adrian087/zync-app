import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/profile_api.dart';

class ProfileFacade {
  final ProfileApi _api = ProfileApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final String _baseUrl = 'https://api.zync-app.net/api';

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

  Future<bool> borrarPublicacion(int publicacionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final url = Uri.parse('$_baseUrl/publicaciones/$publicacionId');
      
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al borrar publicación: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> cargarPerfilPublico(int usuarioId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    return await _api.obtenerPerfilPublico(token, usuarioId);
  }

  Future<bool> alternarSeguimiento(int usuarioId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;
    return await _api.alternarSeguimiento(token, usuarioId);
  }

  Future<bool> editarPerfil({String? username, String? bio, String? imagePath}) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;
    
    return await _api.editarPerfil(token, username, bio, imagePath);
  }

  Future<bool> eliminarCuenta() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/usuarios/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar cuenta: $e');
      return false;
    }
  }

  Future<String?> actualizarDatoCuenta(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return 'Error de autenticación';

      final response = await http.put(
        Uri.parse('$_baseUrl/usuarios/me/$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['error'] ?? 'Error al actualizar';
      }
    } catch (e) {
      return 'Error de conexión con el servidor';
    }
  }

  Future<List<dynamic>> cargarUsuariosBloqueados() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return [];
    return await _api.obtenerUsuariosBloqueados(token);
  }
}