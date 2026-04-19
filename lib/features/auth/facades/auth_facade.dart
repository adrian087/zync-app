import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthFacade {
  final AuthApi _api = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> intentarLogin(String email, String password) async {
    try {
      final token = await _api.loginBackend(email, password);
      
      await _storage.write(key: 'jwt_token', value: token);
      
      print('Token guardado en la caja fuerte de forma segura');
      return true;
    } catch (e) {
      print('Error en el login: $e');
      return false;
    }
  }

  Future<String?> obtenerToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> cerrarSesion() async {
    await _storage.delete(key: 'jwt_token');
  }
}