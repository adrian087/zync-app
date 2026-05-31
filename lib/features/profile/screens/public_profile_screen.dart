import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/profile_facade.dart';
import '../../chat/screens/chat_screen.dart';
import '../../../services/moderacion_service.dart';
import '../../feed/widgets/post_card.dart'; 

class PublicProfileScreen extends StatefulWidget {
  final int usuarioId;
  final String usernamePreview; 

  const PublicProfileScreen({
    super.key, 
    required this.usuarioId, 
    required this.usernamePreview
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ProfileFacade _facade = ProfileFacade();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Map<String, dynamic>? _datosPerfil;
  bool _estaCargando = true;
  int? _miUsuarioId;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _obtenerMiId();
    _cargarDatos();
  }

  Future<void> _obtenerMiId() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payloadStr = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final payload = jsonDecode(payloadStr);
          if (mounted) setState(() => _miUsuarioId = payload['id']);
        }
      }
    } catch (e) {
      print('Error leyendo mi ID: $e');
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    final datos = await _facade.cargarPerfilPublico(widget.usuarioId);
    if (mounted) {
      setState(() {
        _datosPerfil = datos;
        _estaCargando = false;
      });
    }
  }

  Future<void> _seguirUsuario() async {
    setState(() {
      _datosPerfil!['le_sigo'] = !_datosPerfil!['le_sigo'];
      if (_datosPerfil!['le_sigo']) {
        _datosPerfil!['usuario']['total_seguidores']++;
      } else {
        _datosPerfil!['usuario']['total_seguidores']--;
      }
    });
    await _facade.alternarSeguimiento(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;
    final bool estaBloqueado = _datosPerfil?['le_tengo_bloqueado'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('@${widget.usernamePreview}', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_datosPerfil != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'reportar') {
                  await ModeracionService().reportar(
                    usuarioId: widget.usuarioId, 
                    motivo: 'Perfil falso o comportamiento abusivo'
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil reportado.')),
                    );
                  }
                } else if (value == 'bloquear') {
                  await ModeracionService().bloquearUsuario(widget.usuarioId);
                  
                  setState(() {
                    _datosPerfil!['le_tengo_bloqueado'] = !estaBloqueado;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(estaBloqueado ? 'Usuario desbloqueado.' : 'Usuario bloqueado con éxito.')),
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'reportar',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Reportar perfil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'bloquear',
                    child: Row(
                      children: [
                        Icon(estaBloqueado ? Icons.lock_open : Icons.block, color: estaBloqueado ? Colors.green : Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          estaBloqueado ? 'Desbloquear usuario' : 'Bloquear usuario', 
                          style: TextStyle(color: estaBloqueado ? Colors.green : Colors.red)
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: _estaCargando
          ? const Center(child: CircularProgressIndicator())
          : _datosPerfil == null
              ? const Center(child: Text('Error al cargar el perfil'))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      width: double.infinity,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: colorPrimario.withOpacity(0.1),
                            backgroundImage: _datosPerfil!['usuario']['avatar_url'] != null 
                                ? NetworkImage(_datosPerfil!['usuario']['avatar_url']) 
                                : null,
                            child: _datosPerfil!['usuario']['avatar_url'] == null
                                ? Text(
                                    _datosPerfil!['usuario']['username'][0].toUpperCase(),
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorPrimario),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '@${_datosPerfil!['usuario']['username']}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          
                          if (_datosPerfil!['usuario']['bio'] != null && _datosPerfil!['usuario']['bio'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 40, right: 40),
                              child: Text(_datosPerfil!['usuario']['bio'], textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                            ),
                            
                          const SizedBox(height: 16),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _construirEstadistica('${_datosPerfil!['usuario']['totalPosts'] ?? 0}', 'Zyncs'),
                              _construirEstadistica('${_datosPerfil!['usuario']['total_seguidores'] ?? 0}', 'Seguidores'),
                              _construirEstadistica('${_datosPerfil!['usuario']['total_siguiendo'] ?? 0}', 'Siguiendo'),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          if (!estaBloqueado)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _datosPerfil!['le_sigo'] ? Colors.grey[200] : colorPrimario,
                                      foregroundColor: _datosPerfil!['le_sigo'] ? Colors.black : Colors.white,
                                      elevation: 0,
                                    ),
                                    onPressed: _seguirUsuario,
                                    child: Text(
                                      _datosPerfil!['le_sigo'] ? 'Siguiendo' : 'Seguir',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.mail_outline),
                                  color: colorPrimario,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          otroUsuarioId: widget.usuarioId,
                                          username: _datosPerfil!['usuario']['username'],
                                          avatarUrl: _datosPerfil!['usuario']['avatar_url'],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: estaBloqueado 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.block, size: 60, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('Tienes a este usuario bloqueado.', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text('No puedes ver sus publicaciones.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          )
                        : _datosPerfil!['publicaciones'].isEmpty
                          ? const Center(child: Text('Este usuario aún no ha publicado nada.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _datosPerfil!['publicaciones'].length,
                              itemBuilder: (context, index) {
                                final post = _datosPerfil!['publicaciones'][index];
                                return PostCard(
                                  publicacion: post, 
                                  miUsuarioId: _miUsuarioId, 
                                  onUpdate: _cargarDatos
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _construirEstadistica(String numero, String etiqueta) {
    return Column(
      children: [
        Text(numero, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(etiqueta, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }
}