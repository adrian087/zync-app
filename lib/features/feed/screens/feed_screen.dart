import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../facades/feed_facade.dart';
import '../../profile/facades/profile_facade.dart';
import '../../notifications/facades/badge_facade.dart';
import '../../chat/screens/inbox_screen.dart';
import 'create_post_screen.dart';
import '../widgets/zync_skeleton_card.dart';
import '../widgets/feed_list.dart';
import 'package:mi_red_social_app/globals.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedFacade _facade = FeedFacade();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late IO.Socket _socket;

  List<dynamic> _publicacionesParaTi = [];
  List<dynamic> _stories = [];
  List<dynamic> _publicacionesSiguiendo = [];
  bool _estaCargando = true;
  int _paginaActual = 1;
  bool _cargandoMas = false;
  bool _hayMasPosts = true;

  int? _miUsuarioId;
  String? _miAvatarUrl;

  @override
  void initState() {
    super.initState();
    _obtenerMiId();
    _cargarCacheYLuegoInternet();
    _conectarSocket();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_cargandoMas &&
          _hayMasPosts) {
        _cargarMasDatos();
      }
    });
  }

  Future<void> _obtenerMiId() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final String payloadStr = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final Map<String, dynamic> payload = jsonDecode(payloadStr);
          if (mounted) setState(() => _miUsuarioId = payload['id']);
        }
      }

      if (_miUsuarioId != null) {
        final perfilPublico = await ProfileFacade().cargarPerfilPublico(_miUsuarioId!);
        if (mounted && perfilPublico != null) {
          setState(() => _miAvatarUrl = perfilPublico['usuario']['avatar_url']);
        }
      }
    } catch (e) {
      print('Error leyendo mis datos del token: $e');
    }
  }

  void _conectarSocket() {
    _socket = IO.io('https://api.zync-app.net', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) => print('🔌 Conectado al túnel Socket.io'));

    _socket.on('actualizacion_like', (data) {
      if (!mounted) return;
      final publicacionId = data['publicacionId'];
      final nuevoTotal = data['total_likes'];

      setState(() {
        for (var post in _publicacionesParaTi) {
          if (post['id'] == publicacionId || post['publicacion_original_id'] == publicacionId) post['total_likes'] = nuevoTotal;
        }
        for (var post in _publicacionesSiguiendo) {
          if (post['id'] == publicacionId || post['publicacion_original_id'] == publicacionId) post['total_likes'] = nuevoTotal;
        }
      });
    });

    _socket.on('actualizacion_rezync', (data) {
      if (!mounted) return;
      final publicacionId = data['publicacionId'];
      final nuevoTotal = data['total_rezyncs'];

      setState(() {
        for (var post in _publicacionesParaTi) {
          if (post['id'] == publicacionId || post['publicacion_original_id'] == publicacionId) post['total_rezyncs'] = nuevoTotal;
        }
        for (var post in _publicacionesSiguiendo) {
          if (post['id'] == publicacionId || post['publicacion_original_id'] == publicacionId) post['total_rezyncs'] = nuevoTotal;
        }
      });
    });

    _socket.on('drop_agotado', (data) {
      if (!mounted) return;
      final int storyDestruidaId = data['storyId'];
      setState(() => _stories.removeWhere((story) => story['id'] == storyDestruidaId));
    });

    _socket.on('nuevo_mensaje', (data) {
      if (!mounted) return;
      if (data['destinatario_id'] == _miUsuarioId) unreadMessagesCount.value++;
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarCacheYLuegoInternet() async {
    final cacheParaTi = await _facade.cargarFeedCachado();
    final cacheSiguiendo = await _facade.cargarFeedSiguiendoCachado();

    if (mounted && (cacheParaTi.isNotEmpty || cacheSiguiendo.isNotEmpty)) {
      setState(() {
        _publicacionesParaTi = cacheParaTi;
        _publicacionesSiguiendo = cacheSiguiendo;
        _estaCargando = false;
      });
    }
    await _cargarDatos(esRefreshOculto: cacheParaTi.isNotEmpty);
  }

  Future<void> _cargarDatos({bool esRefreshOculto = false}) async {
    if (!esRefreshOculto) setState(() => _estaCargando = true);
    setState(() {
      _paginaActual = 1;
      _hayMasPosts = true;
    });

    final resultados = await Future.wait([
      _facade.cargarFeed(page: 1),
      _facade.cargarFeedSiguiendo(),
      _facade.cargarStories(),
    ]);

    if (mounted) {
      setState(() {
        _publicacionesParaTi = resultados[0];
        _publicacionesSiguiendo = resultados[1];
        _stories = resultados[2];
        _estaCargando = false;
      });
    }

    BadgeFacade().actualizarBadges();
  }

  Future<void> _cargarMasDatos() async {
    setState(() => _cargandoMas = true);
    _paginaActual++;
    final nuevosPosts = await _facade.cargarFeed(page: _paginaActual);

    if (mounted) {
      setState(() {
        if (nuevosPosts.isEmpty) {
          _hayMasPosts = false;
        } else {
          _publicacionesParaTi.addAll(nuevosPosts);
        }
        _cargandoMas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zync', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: unreadMessagesCount,
              builder: (context, count, child) {
                return IconButton(
                  icon: Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.mail_outline)),
                  onPressed: () {
                    unreadMessagesCount.value = 0;
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InboxScreen())).then((_) {
                      unreadMessagesCount.value = 0;
                      BadgeFacade().actualizarBadges();
                    });
                  },
                );
              },
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Para ti'), Tab(text: 'Siguiendo')]),
        ),
        body: _estaCargando
            ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: 5,
                itemBuilder: (context, index) => const ZyncSkeletonCard(),
              )
            : TabBarView(
                children: [
                  FeedList(
                    publicaciones: _publicacionesParaTi,
                    stories: _stories,
                    mensajeVacio: 'Aún no hay Zyncs en el mundo.',
                    miUsuarioId: _miUsuarioId,
                    miAvatarUrl: _miAvatarUrl,
                    cargandoMas: _cargandoMas,
                    scrollController: _scrollController,
                    onRefresh: () => _cargarDatos(esRefreshOculto: false),
                    onUpdate: () => _cargarDatos(esRefreshOculto: true),
                  ),
                  FeedList(
                    publicaciones: _publicacionesSiguiendo,
                    stories: _stories,
                    mensajeVacio: 'Aún no sigues a nadie o no han publicado nada.',
                    miUsuarioId: _miUsuarioId,
                    miAvatarUrl: _miAvatarUrl,
                    cargandoMas: _cargandoMas,
                    scrollController: _scrollController,
                    onRefresh: () => _cargarDatos(esRefreshOculto: false),
                    onUpdate: () => _cargarDatos(esRefreshOculto: true),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final resultado = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreatePostScreen()));
            if (resultado == true) _cargarDatos(esRefreshOculto: false);
          },
        ),
      ),
    );
  }
}