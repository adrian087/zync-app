import 'package:flutter/material.dart';
import 'package:mi_red_social_app/features/feed/screens/feed_screen.dart';
import 'package:mi_red_social_app/features/profile/screens/profile_screen.dart';
import 'package:mi_red_social_app/features/search/screens/search_screen.dart';
import 'package:mi_red_social_app/features/notifications/screens/notifications_screen.dart';
import 'package:mi_red_social_app/features/notifications/services/notifications_service.dart';
import 'package:mi_red_social_app/features/notifications/facades/badge_facade.dart';
import 'package:mi_red_social_app/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceActual = 0;
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); 

  final List<Widget> _pantallas = [
    const FeedScreen(),
    const SearchScreen(), 
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    _configurarPushNotificaciones();
    BadgeFacade().actualizarBadges();
  }

  void _configurarPushNotificaciones() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido');

      String? token = await messaging.getToken();
      
      if (token != null) {
        print('Token FCM: $token');
        _guardarTokenEnServidor(token);
      }
      messaging.onTokenRefresh.listen((nuevoToken) {
        _guardarTokenEnServidor(nuevoToken);
      });
    } else {
      print('Permiso denegado por el usuario');
    }
  }
  Future<void> _guardarTokenEnServidor(String fcmToken) async {
    try {
      String? jwt = await _storage.read(key: 'jwt_token');
      if (jwt == null) return;

      final url = Uri.parse('https://api.zync-app.net/api/usuarios/fcm-token');
      await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      print('Token guardado en la Base de Datos con éxito');
    } catch (e) {
      print('Error al guardar token FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).colorScheme.primary, 
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
          if (index == 2) {
            unreadNotisCount.value = 0;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Muro'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<int>(
              valueListenable: unreadNotisCount,
              builder: (context, count, child) {
                return Badge(
                  isLabelVisible: count > 0, 
                  label: Text('$count'),
                  child: const Icon(Icons.notifications),
                );
              },
            ),
            label: 'Avisos', 
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}