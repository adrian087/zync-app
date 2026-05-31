import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 IMPORTANTE: Añadido para detectar Web
import 'package:http/http.dart' as http;

class ProfileApi {
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<Map<String, dynamic>?> obtenerPerfilPublico(String token, int usuarioId) async {
    final url = Uri.parse('$_baseUrl/usuarios/$usuarioId');
    
    try {
      final response = await http.get(
        url, 
        headers: {'Authorization': 'Bearer $token'}
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error al cargar perfil público: $e');
      return null;
    }
  }

  Future<bool> alternarSeguimiento(String token, int usuarioId) async {
    final url = Uri.parse('$_baseUrl/usuarios/$usuarioId/seguir');
    
    try {
      final response = await http.post(
        url, 
        headers: {'Authorization': 'Bearer $token'}
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error al seguir usuario: $e');
      return false;
    }
  }

  Future<bool> editarPerfil(String token, String? username, String? bio, String? imagePath) async {
    final url = Uri.parse('$_baseUrl/perfil/editar');
    
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    if (username != null && username.isNotEmpty) request.fields['username'] = username;
    if (bio != null) request.fields['bio'] = bio;

    if (imagePath != null) {
      if (kIsWeb) {
        final uri = Uri.parse(imagePath);
        final imageResponse = await http.get(uri);
        request.files.add(
          http.MultipartFile.fromBytes('avatar', imageResponse.bodyBytes, filename: 'avatar.jpg'),
        );
      } else {
        // En móvil usamos la ruta normal
        request.files.add(
          await http.MultipartFile.fromPath('avatar', imagePath),
        );
      }
    }

    try {
      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error al editar perfil: $e');
      return false;
    }
  }

  Future<List<dynamic>> obtenerUsuariosBloqueados(String token) async {
    final url = Uri.parse('$_baseUrl/usuarios/bloqueados');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      print('STATUS CODE BLOQUEADOS: ${response.statusCode}');
      print('BODY BLOQUEADOS: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error de conexión en obtenerUsuariosBloqueados: $e');
      return [];
    }
  }
}