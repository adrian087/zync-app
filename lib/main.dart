import 'package:flutter/material.dart';
// ¡Aquí está la nueva ruta actualizada!
import 'features/auth/screens/login_screen.dart'; 

void main() {
  runApp(const MiRedSocialApp());
}

class MiRedSocialApp extends StatelessWidget {
  const MiRedSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Red Social',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}