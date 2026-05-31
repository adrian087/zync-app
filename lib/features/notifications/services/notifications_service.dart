import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.zync-app.net/api';

  Future<void> inicializarYGuardarToken() async {
    // 1. Pedir permiso al usuario (Obligatorio en iOS y Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos de notificación concedidos.');

      try {
        String? tokenFCM = await _firebaseMessaging.getToken();

        if (tokenFCM != null) {
          print('Mi FCM Token es: $tokenFCM');
          await _enviarTokenAlServidor(tokenFCM);
        }

        _firebaseMessaging.onTokenRefresh.listen(_enviarTokenAlServidor);
      } catch (e) {
        print(
          '⚠️ Aviso: No se pudo obtener el token Push (Normal en simuladores iOS)',
        );
      }
    } else {
      print('El usuario rechazó las notificaciones.');
    }
  }

  Future<void> _enviarTokenAlServidor(String fcmToken) async {
    try {
      final jwtToken = await _storage.read(key: 'jwt_token');
      if (jwtToken == null) return;

      final url = Uri.parse('$_baseUrl/usuarios/fcm-token');
      await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      print('Token FCM guardado en la base de datos');
    } catch (e) {
      print('Error al guardar token en servidor: $e');
    }
  }
}
