import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_red_social_app/globals.dart';

class BadgeFacade {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<void> actualizarBadges() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/badges'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        unreadNotisCount.value = data['notificaciones'];
      }

      final responseChats = await http.get(
        Uri.parse('$_baseUrl/mensajes/chats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (responseChats.statusCode == 200) {
        final List<dynamic> chats = jsonDecode(responseChats.body);
        int realesNoLeidos = 0;
        
        for (var chat in chats) {
          if (chat['leido'] == 0 && chat['remitente_id'] == chat['otro_usuario_id']) {
            realesNoLeidos++;
          }
        }
        unreadMessagesCount.value = realesNoLeidos;
      }
    } catch (e) {
      print('Error al cargar badges: $e');
    }
  }
}