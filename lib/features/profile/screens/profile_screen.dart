import 'package:flutter/material.dart';
import '../facades/profile_facade.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileFacade _facade = ProfileFacade();

  Map<String, dynamic>? _datosPerfil;
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() => _estaCargando = true);
    final datos = await _facade.cargarDatosPerfil();

    if (mounted) {
      setState(() {
        _datosPerfil = datos;
        _estaCargando = false;
      });
    }
  }

  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion),
        ],
      ),
      body: _estaCargando
          ? const Center(child: CircularProgressIndicator())
          : _datosPerfil == null
          ? const Center(child: Text('Error al cargar el perfil'))
          : Column(
              children: [
                // --- CABECERA DEL PERFIL ---
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24.0),
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Avatar (Círculo con la inicial)
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          _datosPerfil!['username'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nombre de usuario
                      Text(
                        '@${_datosPerfil!['username']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Estadísticas
                      Text(
                        '${_datosPerfil!['totalPosts']} Publicaciones',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // --- LISTA DE TUS PUBLICACIONES ---
                Expanded(
                  child: _datosPerfil!['publicaciones'].isEmpty
                      ? const Center(child: Text('Aún no has publicado nada.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _datosPerfil!['publicaciones'].length,
                          itemBuilder: (context, index) {
                            final post = _datosPerfil!['publicaciones'][index];
                            // 👇 ENVOLVEMOS EL CARD EN UN DISMISSIBLE 👇
                            return Dismissible(
                              key: Key(post['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),

                              // 👇 AÑADE ESTE BLOQUE DE CONFIRMACIÓN AQUÍ 👇
                              confirmDismiss: (direction) async {
                                // Mostramos un cuadro de diálogo nativo
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('¿Borrar publicación?'),
                                      content: const Text(
                                        '¿Estás seguro de que quieres eliminar este Zync? Esta acción no se puede deshacer.',
                                      ),
                                      actions: [
                                        // Botón de Cancelar
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop(false), // Devuelve 'false'
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        // Botón de Eliminar
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            context,
                                          ).pop(true), // Devuelve 'true'
                                          child: const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },

                              // 👆 HASTA AQUÍ LA CONFIRMACIÓN 👆
                              onDismissed: (direction) async {
                                // Esta parte se mantiene igual, solo se ejecutará si confirmDismiss devuelve 'true'
                                final exito = await _facade.borrarPublicacion(
                                  post['id'],
                                );
                                if (exito) {
                                  _cargarPerfil();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Publicación eliminada'),
                                    ),
                                  );
                                } else {
                                  _cargarPerfil();
                                }
                              },

                              // Y aquí dentro metemos la tarjeta que ya tenías
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                                child: ListTile(
                                  title: Text(post['contenido']),
                                  subtitle: Text(
                                    '❤️ ${post['total_likes']} me gusta',
                                  ),
                                ),
                              ),
                            );
                            // 👆 HASTA AQUÍ EL DISMISSIBLE 👆
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
