import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthFacade {
  final AuthApi _api = AuthApi();
  // 1. Creamos la instancia de nuestra caja fuerte
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> intentarLogin(String email, String password) async {
    try {
      // 2. Pedimos el token a Node.js
      final token = await _api.loginBackend(email, password);
      
      // 3. ¡Lo guardamos en la caja fuerte! 
      // Le ponemos la etiqueta 'jwt_token' para saber cómo buscarlo luego
      await _storage.write(key: 'jwt_token', value: token);
      
      print('Token guardado en la caja fuerte de forma segura');
      return true; // Login exitoso
    } catch (e) {
      print('Error en el login: $e');
      return false; // Login fallido
    }
  }

  // 4. Creamos un método extra que usaremos más adelante para "leer" la caja fuerte
  Future<String?> obtenerToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // 5. Y un método por si el usuario quiere "Cerrar Sesión"
  Future<void> cerrarSesion() async {
    await _storage.delete(key: 'jwt_token');
  }
}