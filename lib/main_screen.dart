import 'package:flutter/material.dart';
import 'features/feed/screens/feed_screen.dart';
import 'features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Empezamos en la pestaña 0 (El Muro)
  int _indiceActual = 0;

  // Lista de las pantallas que vamos a mostrar
  final List<Widget> _pantallas = [
    const FeedScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body cambia dinámicamente según el índice
      body: _pantallas[_indiceActual],
      
      // La barra inferior mágica
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        selectedItemColor: Colors.blue, // Usaremos el Azul Zync aquí en el futuro
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _indiceActual = index; // Al pulsar, cambiamos de pantalla
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Muro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}