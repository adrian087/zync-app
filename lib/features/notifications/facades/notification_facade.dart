import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationFacade {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<List<dynamic>> obtenerNotificaciones({int page = 1}) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/notificaciones?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error al cargar notificaciones: $e');
      return [];
    }
  }

  Future<bool> marcarComoLeidas() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/notificaciones/leidas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}