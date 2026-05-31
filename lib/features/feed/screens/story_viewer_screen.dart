import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../facades/feed_facade.dart';
import '../../chat/facades/chat_facade.dart';
import '../widgets/story_ui_components.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<dynamic> stories;
  final VoidCallback onStoryVisto;

  const StoryViewerScreen({super.key, required this.stories, required this.onStoryVisto});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _currentIndex = 0;
  final FeedFacade _facade = FeedFacade();
  final ChatFacade _chatFacade = ChatFacade();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  int? _miUsuarioId;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _nextStory();
    });
    _animController.addListener(() => setState(() {}));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _animController.stop();
      else _animController.forward();
    });

    _inicializarYCargarStory();
  }

  Future<void> _inicializarYCargarStory() async {
    await _obtenerMiId();
    _loadStory();
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

  void _loadStory() async {
    _animController.reset();
    _animController.forward();
    
    final story = widget.stories[_currentIndex];
    
    if (_miUsuarioId != null && story['usuario_id'] != _miUsuarioId) {
      if (story['la_he_visto'] == false) {
        await _facade.registrarVistaStory(story['id']);
        if (mounted) {
          setState(() => story['la_he_visto'] = true);
          widget.onStoryVisto();
        }
      }
    }
  }

  Future<void> _enviarRespuestaAlChat() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    final story = widget.stories[_currentIndex];
    _textController.clear();
    _focusNode.unfocus();

    final exito = await _chatFacade.enviarMensaje(story['usuario_id'], '💬 Respondió a tu historia: "$texto"');

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Respuesta enviada! ✉️'), backgroundColor: Colors.blue));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar'), backgroundColor: Colors.red));
      }
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _loadStory();
    } else {
      Navigator.of(context).pop(); 
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadStory();
    } else {
      _animController.reset();
      _animController.forward(); 
    }
  }

  void _mostrarVistasBottomSheet(int storyId) async {
    _animController.stop(); 
    final vistas = await _facade.obtenerVistasStory(storyId);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('👁️ ${vistas.length} visualizaciones', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: vistas.isEmpty
                ? const Center(child: Text('Nadie ha visto esto aún.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: vistas.length,
                    itemBuilder: (context, index) {
                      final vista = vistas[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: vista['avatar_url'] != null ? NetworkImage(vista['avatar_url']) : null,
                          child: vista['avatar_url'] == null ? Text(vista['username'][0].toUpperCase()) : null,
                        ),
                        title: Text('@${vista['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
            ),
          ],
        );
      }
    );
    
    if (mounted) _animController.forward(); 
  }

  void _confirmarEliminarStory(int storyId) async {
    _animController.stop(); 
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar historia?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirmar == true) {
      final exito = await _facade.borrarStory(storyId);
      if (exito && mounted) {
        widget.onStoryVisto(); 
        Navigator.pop(context); 
      }
    } else {
      if (mounted) _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final bool esMia = _miUsuarioId != null && story['usuario_id'] == _miUsuarioId;

    String tiempoAmigable = '';
    if (story['fecha_creacion'] != null) {
      try { tiempoAmigable = timeago.format(DateTime.parse(story['fecha_creacion']), locale: 'es'); } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _animController.stop(), 
        onLongPress: () => _animController.stop(), 
        onLongPressEnd: (_) => _animController.forward(), 
        onTapUp: (details) {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
            return;
          }
          if (details.globalPosition.dx < MediaQuery.of(context).size.width / 3) {
            _previousStory();
          } else {
            _nextStory(); 
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                story['media_url'],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
            
            Positioned(
              top: 0, left: 0, right: 0, height: 120,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black54, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10, right: 10,
              child: StoryProgressBars(
                stories: widget.stories, 
                currentIndex: _currentIndex, 
                animController: _animController
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 30,
              left: 10, right: 10,
              child: StoryHeader(story: story, tiempoAmigable: tiempoAmigable),
            ),

            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16, 
              left: 16, right: 16,
              child: StoryBottomBar(
                esMia: esMia,
                story: story,
                focusNode: _focusNode,
                textController: _textController,
                onSendReply: _enviarRespuestaAlChat,
                onViewStats: () => _mostrarVistasBottomSheet(story['id']),
                onDelete: () => _confirmarEliminarStory(story['id']),
                onLike: () async {
                  setState(() => story['le_has_dado_like'] = !(story['le_has_dado_like'] == true));
                  await _facade.likeStory(story['id']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}