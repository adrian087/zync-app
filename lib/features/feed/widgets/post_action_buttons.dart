import 'package:flutter/material.dart';
import '../facades/feed_facade.dart';
import '../screens/comments_screen.dart';

class PostActionButtons extends StatefulWidget {
  final dynamic publicacion;
  final FeedFacade facade;
  final VoidCallback onUpdate;

  const PostActionButtons({
    super.key,
    required this.publicacion,
    required this.facade,
    required this.onUpdate,
  });

  @override
  State<PostActionButtons> createState() => _PostActionButtonsState();
}

class _PostActionButtonsState extends State<PostActionButtons> {
  @override
  Widget build(BuildContext context) {
    final publicacion = widget.publicacion;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Comentarios
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              color: Colors.grey[600],
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CommentsScreen(publicacion: publicacion)),
                ).then((_) => widget.onUpdate());
              },
            ),
            Text('${publicacion['total_comentarios'] ?? 0}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ],
        ),

        // Re-Zyncs
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.repeat),
              color: (publicacion['lo_has_rezynceado'] ?? 0) > 0 ? Colors.green : Colors.grey[600],
              onPressed: () async {
                setState(() {
                  if ((publicacion['lo_has_rezynceado'] ?? 0) > 0) {
                    publicacion['lo_has_rezynceado'] = 0;
                    publicacion['total_rezyncs']--;
                  } else {
                    publicacion['lo_has_rezynceado'] = 1;
                    publicacion['total_rezyncs']++;
                  }
                });
                await widget.facade.alternarReZync(publicacion['id']);
              },
            ),
            Text('${publicacion['total_rezyncs'] ?? 0}', style: TextStyle(color: (publicacion['lo_has_rezynceado'] ?? 0) > 0 ? Colors.green : Colors.grey[600], fontWeight: FontWeight.bold)),
          ],
        ),

        // Likes
        Row(
          children: [
            IconButton(
              icon: Icon(publicacion['le_has_dado_like'] > 0 ? Icons.favorite : Icons.favorite_border),
              color: publicacion['le_has_dado_like'] > 0 ? Colors.red : Colors.grey[600],
              onPressed: () async {
                setState(() {
                  if (publicacion['le_has_dado_like'] > 0) {
                    publicacion['le_has_dado_like'] = 0;
                    publicacion['total_likes']--;
                  } else {
                    publicacion['le_has_dado_like'] = 1;
                    publicacion['total_likes']++;
                  }
                });
                await widget.facade.alternarLike(publicacion['id']);
              },
            ),
            Text('${publicacion['total_likes'] ?? 0}', style: TextStyle(color: publicacion['le_has_dado_like'] > 0 ? Colors.red : Colors.grey[600], fontWeight: FontWeight.bold)),
          ],
        ),

        // Guardar
        IconButton(
          icon: Icon((publicacion['lo_has_guardado'] ?? 0) > 0 ? Icons.bookmark : Icons.bookmark_border),
          color: (publicacion['lo_has_guardado'] ?? 0) > 0 ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          onPressed: () async {
            setState(() {
              if ((publicacion['lo_has_guardado'] ?? 0) > 0) {
                publicacion['lo_has_guardado'] = 0;
              } else {
                publicacion['lo_has_guardado'] = 1;
              }
            });
            await widget.facade.alternarGuardado(publicacion['id']);
          },
        ),
      ],
    );
  }
}