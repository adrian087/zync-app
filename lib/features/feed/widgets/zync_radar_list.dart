import 'package:flutter/material.dart';

class ZyncRadarList extends StatelessWidget {
  final List<Map<String, dynamic>> usuariosAgrupados;
  final String? miAvatarUrl;
  final bool subiendo;
  final VoidCallback onAddTap;
  final Function(List<dynamic>) onStoryTap;

  const ZyncRadarList({
    super.key,
    required this.usuariosAgrupados,
    this.miAvatarUrl,
    required this.subiendo,
    required this.onAddTap,
    required this.onStoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: usuariosAgrupados.length + 1,
      itemBuilder: (context, index) {
        // Botón "Añadir historia"
        if (index == 0) {
          return _buildAddButton(context);
        }

        final usuarioData = usuariosAgrupados[index - 1];
        final bool vista = usuarioData['todas_vistas'] == true;
        final bool dropNoVisto = usuarioData['tiene_drop_no_visto'] == true;

        Color colorBorde = vista ? Colors.grey.shade300 : (dropNoVisto ? Colors.greenAccent : Theme.of(context).colorScheme.primary);

        return GestureDetector(
          onTap: () => onStoryTap(usuarioData['stories']),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorBorde, width: vista ? 1 : 2.5)),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: usuarioData['avatar_url'] != null ? NetworkImage("${usuarioData['avatar_url']}?t=${DateTime.now().millisecondsSinceEpoch}") : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(usuarioData['username'], style: TextStyle(fontSize: 12, fontWeight: vista ? FontWeight.normal : FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: subiendo ? null : onAddTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                  child: CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade100, backgroundImage: miAvatarUrl != null ? NetworkImage(miAvatarUrl!) : null, child: miAvatarUrl == null ? const Icon(Icons.person) : null),
                ),
                Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Añadir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}