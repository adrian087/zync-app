import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'zync_text_formatter.dart';

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comentario;
  final int nivel;
  final int? miUsuarioId;
  final Function(Map<String, dynamic>) onReply;
  final Function(int) onDelete;

  const CommentTile({
    super.key,
    required this.comentario,
    this.nivel = 0,
    required this.miUsuarioId,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double indentacion = (nivel > 4 ? 4 : nivel) * 24.0;
    String tiempoAmigable = '';
    
    if (comentario['fecha_creacion'] != null) {
      try {
        tiempoAmigable = timeago.format(DateTime.parse(comentario['fecha_creacion']), locale: 'es');
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 + indentacion, top: 12, bottom: 4, right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              border: nivel > 0 ? Border(left: BorderSide(color: Colors.grey.shade300, width: 2)) : null,
            ),
            padding: EdgeInsets.only(left: nivel > 0 ? 12.0 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: comentario['avatar_url'] != null ? NetworkImage(comentario['avatar_url']) : null,
                      child: comentario['avatar_url'] == null ? Text(comentario['username'][0].toUpperCase(), style: const TextStyle(fontSize: 10)) : null,
                    ),
                    const SizedBox(width: 8),
                    Text('@${comentario['username']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(tiempoAmigable, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                ZyncTextFormatter(text: comentario['contenido'], fontSize: 15),
                const SizedBox(height: 4),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onReply(comentario),
                      child: Text(
                        'Responder',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    if (miUsuarioId != null && comentario['usuario_id'] == miUsuarioId) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => onDelete(comentario['id']),
                        child: const Text(
                          'Borrar',
                          style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        if (comentario['respuestas'] != null)
          ...((comentario['respuestas'] as List).map((respuesta) => CommentTile(
                comentario: respuesta,
                nivel: nivel + 1,
                miUsuarioId: miUsuarioId,
                onReply: onReply,
                onDelete: onDelete,
              ))),
      ],
    );
  }
}