import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> datosPerfil;
  final bool subiendoAvatar;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.datosPerfil,
    required this.subiendoAvatar,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;
    final usuario = datosPerfil;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      child: Column(
        children: [
          GestureDetector(
            onTap: subiendoAvatar ? null : onAvatarTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: colorPrimario.withOpacity(0.1),
                  backgroundImage: usuario['avatar_url'] != null
                      ? NetworkImage(usuario['avatar_url'])
                      : null,
                  child: usuario['avatar_url'] == null
                      ? Text(
                          usuario['username'][0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colorPrimario,
                          ),
                        )
                      : null,
                ),
                if (subiendoAvatar)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorPrimario,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '@${usuario['username']}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (usuario['bio'] != null && usuario['bio'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 40, right: 40),
              child: Text(
                usuario['bio'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '${usuario['totalPosts'] ?? 0} Publicaciones',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}