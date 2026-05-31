// --- lib/features/chat/screens/chat_screen.dart ---
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../facades/chat_facade.dart';

class ChatScreen extends StatefulWidget {
  final int otroUsuarioId;
  final String username;
  final String? avatarUrl;

  const ChatScreen({
    super.key,
    required this.otroUsuarioId,
    required this.username,
    this.avatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatFacade _facade = ChatFacade();
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late IO.Socket _socket;

  List<dynamic> _mensajes = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _conectarSocket();
    _cargarHistorial();
  }

  void _conectarSocket() {
    _socket = IO.io('https://api.zync-app.net', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('nuevo_mensaje', (data) {
      if (!mounted) return;
      if (data['remitente_id'] == widget.otroUsuarioId || data['destinatario_id'] == widget.otroUsuarioId) {
        setState(() {
          _mensajes.add(data);
        });
        _hacerScrollHaciaAbajo();
      }
    });
  }

  Future<void> _cargarHistorial() async {
    final mensajes = await _facade.obtenerHistorial(widget.otroUsuarioId);
    if (mounted) {
      setState(() {
        _mensajes = mensajes;
        _estaCargando = false;
      });
      _hacerScrollHaciaAbajo();
    }
  }

  void _hacerScrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviar() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    _mensajeController.clear();
    await _facade.enviarMensaje(widget.otroUsuarioId, texto);
  }

  @override
  void dispose() {
    _socket.dispose();
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
              child: widget.avatarUrl == null ? Text(widget.username[0].toUpperCase()) : null,
            ),
            const SizedBox(width: 10),
            Text('@${widget.username}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _estaCargando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final msg = _mensajes[index];
                      final soyYo = msg['remitente_id'] != widget.otroUsuarioId;

                      return Align(
                        alignment: soyYo ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: soyYo ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(soyYo ? 16 : 0),
                              bottomRight: Radius.circular(soyYo ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            msg['contenido'],
                            style: TextStyle(color: soyYo ? Colors.white : Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _enviar,
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