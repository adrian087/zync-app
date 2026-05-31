import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchApi {
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<List<dynamic>> buscarUsuarios(String token, String query) async {
    final url = Uri.parse('$_baseUrl/usuarios/buscar?q=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error de conexión en buscarUsuarios: $e');
      return [];
    }
  }

  Future<List<dynamic>> buscarPublicaciones(String token, String query) async {
    final url = Uri.parse('$_baseUrl/publicaciones/buscar?q=$query');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print('Error en buscarPublicaciones: $e');
      return [];
    }
  }
}