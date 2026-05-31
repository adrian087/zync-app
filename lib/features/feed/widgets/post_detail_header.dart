import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/public_profile_screen.dart';
import 'zync_text_formatter.dart';
import 'zync_carousel.dart';

class PostDetailHeader extends StatelessWidget {
  final dynamic publicacion;
  final int? miUsuarioId;
  final FocusNode focusNode;
  final VoidCallback onReZyncPressed;
  final VoidCallback onLikePressed;

  const PostDetailHeader({
    super.key,
    required this.publicacion,
    required this.miUsuarioId,
    required this.focusNode,
    required this.onReZyncPressed,
    required this.onLikePressed,
  });

  String _formatearFechaExacta(String? fechaCruda) {
    if (fechaCruda == null) return '';
    try {
      final fecha = DateTime.parse(fechaCruda);
      final hora = DateFormat('HH:mm').format(fecha);
      final dia = DateFormat('dd/MM/yy').format(fecha);
      return '$hora · $dia';
    } catch (_) { return ''; }
  }

  Widget _buildStat(int count, String label) {
    return Row(
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esReZync = publicacion['publicacion_original_id'] != null;
    final String mostrarUsername = esReZync ? (publicacion['original_username'] ?? 'Usuario') : publicacion['username'];
    final String? mostrarAvatar = esReZync ? publicacion['original_avatar_url'] : publicacion['avatar_url'];
    final String mostrarContenido = esReZync ? (publicacion['original_contenido'] ?? '') : publicacion['contenido'];
    final String fechaExacta = _formatearFechaExacta(esReZync ? publicacion['original_fecha'] : publicacion['fecha_creacion']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                backgroundImage: mostrarAvatar != null ? NetworkImage(mostrarAvatar) : null,
                child: mostrarAvatar == null
                    ? Text(mostrarUsername[0].toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))
                    : null,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  final targetId = esReZync ? publicacion['publicacion_original_id'] : publicacion['usuario_id'];
                  if (targetId != null) {
                    if (miUsuarioId != null && targetId == miUsuarioId) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PublicProfileScreen(usuarioId: targetId, usernamePreview: mostrarUsername)));
                    }
                  }
                },
                child: Text('@$mostrarUsername', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ZyncTextFormatter(text: mostrarContenido, fontSize: 18),
        ),
        
        if (publicacion['imagenes'] != null && publicacion['imagenes'].toString().isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ZyncCarousel(
              imagenesUrls: publicacion['imagenes'].toString().split(','),
              publicacionId: publicacion['id'].toString(),
            ),
          ),
        ],
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(fechaExacta, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ),
        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildStat(publicacion['total_rezyncs'] ?? 0, 'Re-Zyncs'),
              const SizedBox(width: 16),
              _buildStat(publicacion['total_likes'] ?? 0, 'Me gusta'),
            ],
          ),
        ),
        const Divider(height: 1),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.chat_bubble_outline), color: Colors.grey[600], onPressed: () => focusNode.requestFocus()),
            IconButton(
              icon: const Icon(Icons.repeat),
              color: (publicacion['lo_has_rezynceado'] ?? 0) > 0 ? Colors.green : Colors.grey[600],
              onPressed: onReZyncPressed,
            ),
            IconButton(
              icon: Icon(publicacion['le_has_dado_like'] > 0 ? Icons.favorite : Icons.favorite_border),
              color: publicacion['le_has_dado_like'] > 0 ? Colors.red : Colors.grey[600],
              onPressed: onLikePressed,
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}