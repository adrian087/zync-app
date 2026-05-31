import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/chat_facade.dart';
import 'chat_screen.dart';
import '../../notifications/facades/badge_facade.dart';
import 'package:mi_red_social_app/globals.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatFacade _facade = ChatFacade();
  List<dynamic> _chats = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _cargarChats();
  }

  Future<void> _cargarChats() async {
    setState(() => _estaCargando = true);
    final chats = await _facade.obtenerChatsRecientes();

    int realesNoLeidos = 0;
    for (var chat in chats) {
      if (chat['leido'] == 0 && chat['remitente_id'] == chat['otro_usuario_id']) {
        realesNoLeidos++;
      }
    }
    unreadMessagesCount.value = realesNoLeidos;

    if (mounted) {
      setState(() {
        _chats = chats;
        _estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes Directos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _estaCargando
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(child: Text('No tienes mensajes aún.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _cargarChats,
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      String tiempoAmigable = '';
                      if (chat['fecha_envio'] != null) {
                        try {
                          tiempoAmigable = timeago.format(DateTime.parse(chat['fecha_envio']), locale: 'es');
                        } catch (_) {}
                      }

                      final bool noLeido = chat['leido'] == 0 && chat['remitente_id'] == chat['otro_usuario_id'];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          backgroundImage: chat['avatar_url'] != null ? NetworkImage(chat['avatar_url']) : null,
                          child: chat['avatar_url'] == null 
                              ? Text(chat['username'][0].toUpperCase()) 
                              : null,
                        ),
                        title: Text('@${chat['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          chat['ultimo_mensaje'], 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: noLeido ? FontWeight.bold : FontWeight.normal,
                            color: noLeido ? Colors.black : Colors.grey,
                          ),
                        ),
                        trailing: Text(tiempoAmigable, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        onTap: () {
                          // 👇 Apagamos la negrita al instante de tocar la pantalla 👇
                          setState(() {
                            chat['leido'] = 1;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otroUsuarioId: chat['otro_usuario_id'],
                                username: chat['username'],
                                avatarUrl: chat['avatar_url'],
                              ),
                            ),
                          ).then((_) {
                            _cargarChats();
                            BadgeFacade().actualizarBadges(); 
                          });
                        },
                      );
                    },
                  ),
                ),
    );
  }
}