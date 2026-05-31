import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../facades/feed_facade.dart';
import '../widgets/zync_carousel.dart';
import '../widgets/zync_text_formatter.dart';
import '../widgets/comment_tile.dart'; // 👈 IMPORTAMOS NUESTRO WIDGET EXTRAÍDO

class CommentsScreen extends StatefulWidget {
  final dynamic publicacion;
  const CommentsScreen({super.key, required this.publicacion});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FeedFacade _facade = FeedFacade();
  final TextEditingController _comentarioController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _comentariosArbol = [];
  bool _estaCargando = true;
  int? _miUsuarioId; 
  Map<String, dynamic>? _comentarioRespondiendo;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _obtenerMiId();
    _cargarComentarios();
  }

  Future<void> _obtenerMiId() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          if (mounted) setState(() => _miUsuarioId = payload['id']);
        }
      }
    } catch (e) {
      print('Error leyendo mi ID: $e');
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _cargarComentarios() async {
    setState(() => _estaCargando = true);
    final comentariosPlanos = await _facade.obtenerComentarios(widget.publicacion['id']);

    if (mounted) {
      setState(() {
        _comentariosArbol = _construirArbol(comentariosPlanos);
        _estaCargando = false;
      });
    }
  }

  List<Map<String, dynamic>> _construirArbol(List<dynamic> planos) {
    Map<int, Map<String, dynamic>> mapa = {};
    List<Map<String, dynamic>> raices = [];

    for (var c in planos) {
      mapa[c['id']] = {...c, 'respuestas': <Map<String, dynamic>>[]};
    }
    for (var c in planos) {
      final idPadre = c['comentario_padre_id'];
      if (idPadre != null && mapa.containsKey(idPadre)) {
        mapa[idPadre]!['respuestas'].add(mapa[c['id']]!);
      } else {
        raices.add(mapa[c['id']]!); 
      }
    }
    return raices;
  }

  Future<void> _publicarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    final exito = await _facade.comentar(
      widget.publicacion['id'],
      texto,
      comentarioPadreId: _comentarioRespondiendo?['id'], 
    );

    if (exito && mounted) {
      _comentarioController.clear();
      setState(() => _comentarioRespondiendo = null);
      _focusNode.unfocus();
      _cargarComentarios(); 
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al publicar')));
    }
  }

  void _confirmarBorrarComentario(int comentarioId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar comentario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final exito = await _facade.borrarComentario(comentarioId);
              if (exito && mounted) {
                _cargarComentarios();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario eliminado')));
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar', style: TextStyle(color: Colors.red))));
              }
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esReZync = widget.publicacion['publicacion_original_id'] != null;
    final String originalUsername = esReZync ? (widget.publicacion['original_username'] ?? 'Usuario') : widget.publicacion['username'];
    final String? originalAvatar = esReZync ? widget.publicacion['original_avatar_url'] : widget.publicacion['avatar_url'];
    final String originalContenido = esReZync ? (widget.publicacion['original_contenido'] ?? '') : widget.publicacion['contenido'];
    final String originalImagenes = widget.publicacion['imagenes']?.toString() ?? '';

    String tiempoOriginal = '';
    final fechaCruda = esReZync ? widget.publicacion['original_fecha'] : widget.publicacion['fecha_creacion'];
    if (fechaCruda != null) {
      try { tiempoOriginal = timeago.format(DateTime.parse(fechaCruda), locale: 'es'); } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Respuestas')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: originalAvatar != null ? NetworkImage(originalAvatar) : null,
                      child: originalAvatar == null ? Text(originalUsername[0].toUpperCase(), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary)) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@$originalUsername', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(tiempoOriginal, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ZyncTextFormatter(text: originalContenido, fontSize: 17),
                if (originalImagenes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ZyncCarousel(imagenesUrls: originalImagenes.split(','), publicacionId: widget.publicacion['id'].toString()),
                ],
              ],
            ),
          ),

          Expanded(
            child: _estaCargando
                ? const Center(child: CircularProgressIndicator())
                : _comentariosArbol.isEmpty
                ? const Center(child: Text('Sé el primero en responder', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _cargarComentarios,
                    child: ListView.builder(
                      itemCount: _comentariosArbol.length,
                      itemBuilder: (context, index) {
                        // 👇 UTILIZAMOS NUESTRO NUEVO WIDGET 👇
                        return CommentTile(
                          comentario: _comentariosArbol[index],
                          miUsuarioId: _miUsuarioId,
                          onReply: (comentario) {
                            setState(() => _comentarioRespondiendo = comentario);
                            _focusNode.requestFocus();
                          },
                          onDelete: _confirmarBorrarComentario,
                        );
                      },
                    ),
                  ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 5)]),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_comentarioRespondiendo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Respondiendo a @${_comentarioRespondiendo!['username']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
                          GestureDetector(onTap: () => setState(() => _comentarioRespondiendo = null), child: const Icon(Icons.close, size: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: _comentarioRespondiendo == null ? 'Añade un comentario...' : 'Escribe tu respuesta...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: _publicarComentario,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}