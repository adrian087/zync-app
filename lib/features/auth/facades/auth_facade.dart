import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_api.dart';

class AuthFacade {
  final AuthApi _api = AuthApi();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> intentarLogin(String email, String password) async {
    try {
      final token = await _api.loginBackend(email, password);
      await _storage.write(key: 'jwt_token', value: token);
      return true;
    } catch (e) {
      print('Error en el login: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> intentarRegistro({
    required String nombres,
    required String apellidos,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _api.registroBackend(nombres, apellidos, username, email, password);
      final token = await _api.loginBackend(email, password);
      await _storage.write(key: 'jwt_token', value: token);

      return {'success': true, 'message': '¡Cuenta creada! Entrando a Zync...'};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceAll('Exception: ', '')};
    }
  }

  Future<Map<String, dynamic>?> loginConGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      // Extraemos los datos del usuario de Firebase
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('Error: Firebase no devolvió un usuario');
        return null;
      }

      final String email = firebaseUser.email ?? '';
      final String displayName = firebaseUser.displayName ?? '';
      final String photoUrl = firebaseUser.photoURL ?? '';
      final String googleId = firebaseUser.uid;

      if (email.isEmpty || googleId.isEmpty) {
        print('Error: datos de Firebase incompletos');
        return null;
      }

      // Enviamos los datos al backend para que cree o loguee al usuario
      final response = await http.post(
        Uri.parse('https://api.zync-app.net/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'displayName': displayName,
          'photoUrl': photoUrl,
          'googleId': googleId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error en el servidor: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login con Google: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> solicitarCodigoReset(String email) async {
    return await _api.solicitarCodigoReset(email);
  }

  Future<Map<String, dynamic>> verificarCodigoReset(
      String email, String codigo) async {
    return await _api.verificarCodigoReset(email, codigo);
  }

  Future<Map<String, dynamic>> cambiarPasswordConCodigo(
      String email, String codigo, String nuevaPassword) async {
    return await _api.cambiarPasswordConCodigo(email, codigo, nuevaPassword);
  }
}