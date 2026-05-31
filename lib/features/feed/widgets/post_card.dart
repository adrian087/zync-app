import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../facades/feed_facade.dart';
import '../../../services/moderacion_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/public_profile_screen.dart';
import '../screens/zync_detail_screen.dart';
import 'zync_text_formatter.dart';
import 'zync_carousel.dart';
import 'post_action_buttons.dart';

class PostCard extends StatefulWidget {
  final dynamic publicacion;
  final int? miUsuarioId;
  final VoidCallback onUpdate;

  const PostCard({
    super.key,
    required this.publicacion,
    required this.miUsuarioId,
    required this.onUpdate,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FeedFacade _facade = FeedFacade();

  String _formatearFecha(String? fechaCruda) {
    if (fechaCruda == null) return '';
    try {
      final fechaPublicacion = DateTime.parse(fechaCruda);
      final diferencia = DateTime.now().difference(fechaPublicacion);
      if (diferencia.inDays >= 2) return DateFormat('dd/MM/yy').format(fechaPublicacion);
      return timeago.format(fechaPublicacion, locale: 'es');
    } catch (_) { return ''; }
  }

  void _mostrarDialogoEditar(BuildContext context) {
    final TextEditingController editController = TextEditingController(text: widget.publicacion['contenido'] ?? '');
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar Zync'),
              content: TextField(
                controller: editController,
                maxLines: 4,
                decoration: InputDecoration(hintText: '¿Qué quieres cambiar?', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              actions: [
                TextButton(onPressed: guardando ? null : () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: guardando
                      ? null
                      : () async {
                          setStateDialog(() => guardando = true);
                          final exito = await _facade.editarZync(widget.publicacion['id'], editController.text);
                          if (mounted && context.mounted) {
                            Navigator.pop(context);
                            if (exito) {
                              widget.onUpdate();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zync editado correctamente')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al editar el Zync')));
                            }
                          }
                        },
                  child: guardando ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarMenuOpciones(BuildContext context) {
    final int publicacionId = widget.publicacion['id'];
    final int autorId = widget.publicacion['usuario_id'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.orange),
                title: const Text('Reportar publicación'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ModeracionService().reportar(publicacionId: publicacionId, usuarioId: autorId, motivo: 'Contenido inapropiado o spam');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias. Hemos recibido tu reporte.')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Bloquear usuario', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ModeracionService().bloquearUsuario(autorId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario bloqueado. Recarga el muro para actualizar.')));
                    widget.onUpdate();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicacion = widget.publicacion;
    final bool esReZync = publicacion['publicacion_original_id'] != null;

    final String mostrarUsername = esReZync ? (publicacion['original_username'] ?? 'Usuario') : publicacion['username'];
    final String? mostrarAvatar = esReZync ? publicacion['original_avatar_url'] : publicacion['avatar_url'];
    final String mostrarContenido = esReZync ? (publicacion['original_contenido'] ?? '') : publicacion['contenido'];

    final fechaCruda = esReZync ? publicacion['original_fecha'] : publicacion['fecha_creacion'];
    final String tiempoAmigable = _formatearFecha(fechaCruda);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZyncDetailScreen(publicacion: publicacion, miUsuarioId: widget.miUsuarioId, onUpdate: widget.onUpdate),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (esReZync)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.repeat, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('${publicacion['username']} ha re-zynceado', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    backgroundImage: mostrarAvatar != null ? NetworkImage(mostrarAvatar) : null,
                    child: mostrarAvatar == null ? Text(mostrarUsername[0].toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final targetId = esReZync ? publicacion['publicacion_original_id'] : publicacion['usuario_id'];
                            if (targetId != null) {
                              if (widget.miUsuarioId != null && targetId == widget.miUsuarioId) {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PublicProfileScreen(usuarioId: targetId, usernamePreview: mostrarUsername)));
                              }
                            }
                          },
                          child: Text('@$mostrarUsername', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tiempoAmigable, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            if (widget.miUsuarioId != null && publicacion['usuario_id'] == widget.miUsuarioId && !esReZync) ...[
                              const SizedBox(width: 8),
                              GestureDetector(onTap: () => _mostrarDialogoEditar(context), child: const Icon(Icons.edit, size: 16, color: Colors.grey)),
                            ],
                            if (widget.miUsuarioId != null && publicacion['usuario_id'] != widget.miUsuarioId) ...[
                              const SizedBox(width: 8),
                              GestureDetector(onTap: () => _mostrarMenuOpciones(context), child: const Icon(Icons.more_vert, size: 18, color: Colors.grey)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ZyncTextFormatter(text: mostrarContenido),

              if (publicacion['imagenes'] != null && publicacion['imagenes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                ZyncCarousel(imagenesUrls: publicacion['imagenes'].toString().split(','), publicacionId: publicacion['id'].toString()),
              ],

              const SizedBox(height: 12),

              PostActionButtons(
                publicacion: publicacion,
                facade: _facade,
                onUpdate: widget.onUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}