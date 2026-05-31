import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/feed_facade.dart';
import '../widgets/comment_tile.dart';
import '../widgets/post_detail_header.dart';

class ZyncDetailScreen extends StatefulWidget {
  final dynamic publicacion;
  final int? miUsuarioId;
  final VoidCallback onUpdate;

  const ZyncDetailScreen({
    super.key,
    required this.publicacion,
    required this.miUsuarioId,
    required this.onUpdate,
  });

  @override
  State<ZyncDetailScreen> createState() => _ZyncDetailScreenState();
}

class _ZyncDetailScreenState extends State<ZyncDetailScreen> {
  final FeedFacade _facade = FeedFacade();
  late dynamic publicacion;

  final TextEditingController _comentarioController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _comentariosArbol = [];
  bool _estaCargandoComentarios = true;
  Map<String, dynamic>? _comentarioRespondiendo;

  @override
  void initState() {
    super.initState();
    publicacion = widget.publicacion;
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _cargarComentarios(); 
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _cargarComentarios() async {
    setState(() => _estaCargandoComentarios = true);
    final comentariosPlanos = await _facade.obtenerComentarios(publicacion['id']);

    if (mounted) {
      setState(() {
        _comentariosArbol = _construirArbol(comentariosPlanos);
        _estaCargandoComentarios = false;
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
      publicacion['id'],
      texto,
      comentarioPadreId: _comentarioRespondiendo?['id'],
    );

    if (exito && mounted) {
      _comentarioController.clear();
      setState(() {
        _comentarioRespondiendo = null;
        publicacion['total_comentarios'] = (publicacion['total_comentarios'] ?? 0) + 1;
      });
      _focusNode.unfocus();
      widget.onUpdate(); 
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final exito = await _facade.borrarComentario(comentarioId);
              if (exito && mounted) {
                setState(() => publicacion['total_comentarios'] = (publicacion['total_comentarios'] ?? 1) - 1);
                widget.onUpdate();
                _cargarComentarios();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario eliminado')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Zync', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                PostDetailHeader(
                  publicacion: publicacion,
                  miUsuarioId: widget.miUsuarioId,
                  focusNode: _focusNode,
                  onReZyncPressed: () async {
                    setState(() {
                      publicacion['lo_has_rezynceado'] = (publicacion['lo_has_rezynceado'] ?? 0) > 0 ? 0 : 1;
                      publicacion['total_rezyncs'] += (publicacion['lo_has_rezynceado'] == 1) ? 1 : -1;
                    });
                    await _facade.alternarReZync(publicacion['id']);
                    widget.onUpdate();
                  },
                  onLikePressed: () async {
                    setState(() {
                      publicacion['le_has_dado_like'] = publicacion['le_has_dado_like'] > 0 ? 0 : 1;
                      publicacion['total_likes'] += (publicacion['le_has_dado_like'] == 1) ? 1 : -1;
                    });
                    await _facade.alternarLike(publicacion['id']);
                    widget.onUpdate();
                  },
                ),
                if (_estaCargandoComentarios)
                  const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()))
                else if (_comentariosArbol.isEmpty)
                  const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Sé el primero en responder', style: TextStyle(color: Colors.grey))))
                else
                  ..._comentariosArbol.map((c) => CommentTile(
                        comentario: c,
                        miUsuarioId: widget.miUsuarioId,
                        onReply: (comentario) {
                          setState(() => _comentarioRespondiendo = comentario);
                          _focusNode.requestFocus();
                        },
                        onDelete: _confirmarBorrarComentario,
                      )),
              ],
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
                      IconButton(icon: const Icon(Icons.send), color: Theme.of(context).colorScheme.primary, onPressed: _publicarComentario),
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