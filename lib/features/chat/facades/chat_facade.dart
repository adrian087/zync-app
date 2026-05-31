import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatFacade {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<List<dynamic>> obtenerChatsRecientes() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/mensajes/chats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print('Error al cargar chats: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerHistorial(int otroUsuarioId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/mensajes/$otroUsuarioId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print('Error al cargar historial: $e');
      return [];
    }
  }

  Future<bool> enviarMensaje(int otroUsuarioId, String contenido) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/mensajes/$otroUsuarioId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'contenido': contenido}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al enviar mensaje: $e');
      return false;
    }
  }
}