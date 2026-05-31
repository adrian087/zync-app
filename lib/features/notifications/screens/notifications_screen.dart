import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/notification_facade.dart';
import '../../profile/screens/public_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationFacade _facade = NotificationFacade();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _notificaciones = [];
  bool _estaCargando = true;
  int _paginaActual = 1;
  bool _cargandoMas = false;
  bool _hayMasPosts = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _cargarDatos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_cargandoMas &&
          _hayMasPosts) {
        _cargarMasDatos();
      }
    });
  }

  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    final notas = await _facade.obtenerNotificaciones(page: 1);
    
    if (mounted) {
      setState(() {
        _notificaciones = notas;
        _estaCargando = false;
        _paginaActual = 1;
        _hayMasPosts = notas.length == 20;
      });
      _facade.marcarComoLeidas();
    }
  }

  Future<void> _cargarMasDatos() async {
    setState(() => _cargandoMas = true);
    _paginaActual++;
    final nuevas = await _facade.obtenerNotificaciones(page: _paginaActual);
    
    if (mounted) {
      setState(() {
        if (nuevas.isEmpty) {
          _hayMasPosts = false;
        } else {
          _notificaciones.addAll(nuevas);
        }
        _cargandoMas = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _construirIcono(String tipo) {
    switch (tipo) {
      case 'like':
        return const Icon(Icons.favorite, color: Colors.red, size: 28);
      case 'rezync':
        return const Icon(Icons.repeat, color: Colors.green, size: 28);
      case 'comentario':
        return const Icon(Icons.chat_bubble, color: Colors.blue, size: 28);
      case 'seguir':
        return Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 28);
      default:
        return const Icon(Icons.notifications, color: Colors.grey, size: 28);
    }
  }

  String _construirTexto(String tipo) {
    switch (tipo) {
      case 'like':
        return ' le dio Me gusta a tu Zync.';
      case 'rezync':
        return ' ha re-zynceado tu publicación.';
      case 'comentario':
        return ' comentó en tu publicación.';
      case 'seguir':
        return ' ha comenzado a seguirte.';
      default:
        return ' interactuó contigo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _estaCargando
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? const Center(child: Text('Aún no tienes notificaciones.', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _notificaciones.length + (_cargandoMas ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notificaciones.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final noti = _notificaciones[index];
                      final bool esNueva = noti['leida'] == 0;

                      String tiempoAmigable = '';
                      if (noti['fecha_creacion'] != null) {
                        try {
                          tiempoAmigable = timeago.format(DateTime.parse(noti['fecha_creacion']), locale: 'es');
                        } catch (_) {}
                      }

                      return Container(
                        // Fondo azul claro si es nueva
                        color: esNueva ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PublicProfileScreen(
                                  usuarioId: noti['usuario_origen_id'] ?? 0,
                                  usernamePreview: noti['origen_username'] ?? 'Usuario',
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ICONO GRANDE
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0, top: 4.0),
                                  child: _construirIcono(noti['tipo']),
                                ),
                                
                                // CONTENIDO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundImage: noti['origen_avatar'] != null ? NetworkImage(noti['origen_avatar']) : null,
                                            child: noti['origen_avatar'] == null ? Text(noti['origen_username'][0].toUpperCase(), style: const TextStyle(fontSize: 10)) : null,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(color: Colors.black87, fontSize: 15),
                                                children: [
                                                  TextSpan(text: '@${noti['origen_username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  TextSpan(text: _construirTexto(noti['tipo'])),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      if (noti['publicacion_contenido'] != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          noti['publicacion_contenido'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 6),
                                      Text(tiempoAmigable, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}