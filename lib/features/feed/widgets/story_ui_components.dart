import 'package:flutter/material.dart';

class StoryProgressBars extends StatelessWidget {
  final List<dynamic> stories;
  final int currentIndex;
  final AnimationController animController;

  const StoryProgressBars({
    super.key,
    required this.stories,
    required this.currentIndex,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stories.asMap().entries.map((entry) {
        final int index = entry.key;
        double percent = 0.0;
        if (index < currentIndex) {
          percent = 1.0;
        } else if (index == currentIndex) {
          percent = animController.value;
        }
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              height: 3,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StoryHeader extends StatelessWidget {
  final Map<String, dynamic> story;
  final String tiempoAmigable;

  const StoryHeader({
    super.key,
    required this.story,
    required this.tiempoAmigable,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: story['avatar_url'] != null ? NetworkImage(story['avatar_url']) : null,
          child: story['avatar_url'] == null ? Text(story['username'][0].toUpperCase()) : null,
        ),
        const SizedBox(width: 10),
        Text(
          story['username'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(width: 8),
        Text(
          tiempoAmigable,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        if (story['tipo'] == 'drop') ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.greenAccent.shade400.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.greenAccent.shade400, size: 16),
                const SizedBox(width: 4),
                Text('Zync Drop', style: TextStyle(color: Colors.greenAccent.shade400, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ],
    );
  }
}

class StoryBottomBar extends StatelessWidget {
  final bool esMia;
  final Map<String, dynamic> story;
  final FocusNode focusNode;
  final TextEditingController textController;
  final VoidCallback onSendReply;
  final VoidCallback onLike;
  final VoidCallback onViewStats;
  final VoidCallback onDelete;

  const StoryBottomBar({
    super.key,
    required this.esMia,
    required this.story,
    required this.focusNode,
    required this.textController,
    required this.onSendReply,
    required this.onLike,
    required this.onViewStats,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (esMia) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onViewStats,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: const [
                  Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Vistas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 30),
            onPressed: onDelete,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 1.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enviar mensaje...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white70, size: 18),
                    onPressed: onSendReply,
                  ),
                ),
                onSubmitted: (_) => onSendReply(), 
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onLike,
            child: Icon(
              story['le_has_dado_like'] == true ? Icons.favorite : Icons.favorite_border,
              color: story['le_has_dado_like'] == true ? Colors.red : Colors.white,
              size: 32,
            ),
          ),
        ],
      );
    }
  }
}