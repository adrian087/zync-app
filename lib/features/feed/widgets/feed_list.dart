import 'package:flutter/material.dart';
import 'zync_radar.dart';
import 'zync_skeleton_card.dart';
import 'post_card.dart';

class FeedList extends StatelessWidget {
  final List<dynamic> publicaciones;
  final List<dynamic> stories;
  final String mensajeVacio;
  final int? miUsuarioId;
  final String? miAvatarUrl;
  final bool cargandoMas;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onUpdate;

  const FeedList({
    super.key,
    required this.publicaciones,
    required this.stories,
    required this.mensajeVacio,
    required this.miUsuarioId,
    required this.miAvatarUrl,
    required this.cargandoMas,
    required this.scrollController,
    required this.onRefresh,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    String? avatarDefinitivo = miAvatarUrl;
    if (avatarDefinitivo == null && miUsuarioId != null) {
      try {
        final miPost = publicaciones.firstWhere((p) => p['usuario_id'] == miUsuarioId);
        avatarDefinitivo = miPost['avatar_url'];
      } catch (_) {
        try {
          final miStory = stories.firstWhere((s) => s['usuario_id'] == miUsuarioId);
          avatarDefinitivo = miStory['avatar_url'];
        } catch (_) {}
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 0, bottom: 8, left: 8, right: 8),
        itemCount: publicaciones.isEmpty ? 2 : publicaciones.length + (cargandoMas ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ZyncRadar(
              stories: stories,
              miAvatarUrl: avatarDefinitivo,
              onStoryVisto: onUpdate,
            );
          }

          if (publicaciones.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                mensajeVacio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final postIndex = index - 1;

          if (postIndex == publicaciones.length) {
            return const ZyncSkeletonCard();
          }

          return PostCard(
            publicacion: publicaciones[postIndex],
            miUsuarioId: miUsuarioId,
            onUpdate: onUpdate,
          );
        },
      ),
    );
  }
}