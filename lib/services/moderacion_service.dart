import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModeracionService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'https://api.zync-app.net/api';

  Future<bool> bloquearUsuario(int usuarioId) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/$usuarioId/bloquear'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> reportar({int? usuarioId, int? publicacionId, required String motivo}) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/reportar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'usuario_destino_id': usuarioId,
        'publicacion_id': publicacionId,
        'motivo': motivo,
      }),
    );
    return response.statusCode == 200;
  }
}