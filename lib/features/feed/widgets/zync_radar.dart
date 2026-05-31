import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:image_picker/image_picker.dart';
import '../facades/feed_facade.dart';
import '../screens/story_viewer_screen.dart';
import 'zync_radar_list.dart'; 

class ZyncRadar extends StatefulWidget {
  final List<dynamic> stories;
  final VoidCallback onStoryVisto;
  final String? miAvatarUrl;

  const ZyncRadar({
    super.key, 
    required this.stories, 
    required this.onStoryVisto, 
    this.miAvatarUrl
  });

  @override
  State<ZyncRadar> createState() => _ZyncRadarState();
}

class _ZyncRadarState extends State<ZyncRadar> {
  final FeedFacade _facade = FeedFacade();
  final ImagePicker _picker = ImagePicker();
  bool _subiendo = false;

  List<Map<String, dynamic>> _agruparStories() {
    Map<int, Map<String, dynamic>> agrupados = {};
    for (var story in widget.stories) {
      int uId = story['usuario_id'];
      if (!agrupados.containsKey(uId)) {
        agrupados[uId] = {
          'usuario_id': uId, 
          'username': story['username'], 
          'avatar_url': story['avatar_url'], 
          'stories': <dynamic>[], 
          'todas_vistas': true, 
          'tiene_drop_no_visto': false
        };
      }
      agrupados[uId]!['stories'].add(story);
      if (story['la_he_visto'] == false) {
        agrupados[uId]!['todas_vistas'] = false;
        if (story['tipo'] == 'drop') agrupados[uId]!['tiene_drop_no_visto'] = true;
      }
    }
    return agrupados.values.toList();
  }

  Future<void> _crearNuevaStory() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (foto == null || !mounted) return;

    String tipoSeleccionado = 'normal';
    final TextEditingController vistasController = TextEditingController(text: '10');

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Crear Historia'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb 
                        ? Image.network(foto.path, height: 150, fit: BoxFit.cover)
                        : Image.file(File(foto.path), height: 150, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile(
                    title: const Text('Historia Normal (24h)'),
                    value: 'normal',
                    groupValue: tipoSeleccionado,
                    onChanged: (v) => setStateDialog(() => tipoSeleccionado = v.toString()),
                  ),
                  RadioListTile(
                    title: const Text('Zync Drop 🔥', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Caduca por visualizaciones'),
                    value: 'drop',
                    groupValue: tipoSeleccionado,
                    onChanged: (v) => setStateDialog(() => tipoSeleccionado = v.toString()),
                  ),
                  if (tipoSeleccionado == 'drop')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: vistasController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Límite de visualizaciones', border: OutlineInputBorder()),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Publicar')),
            ],
          );
        },
      ),
    );

    if (confirmar != true) return;

    setState(() => _subiendo = true);
    
    int? vistasDrop;
    if (tipoSeleccionado == 'drop') {
      vistasDrop = int.tryParse(vistasController.text) ?? 10;
    }

    final exito = await _facade.subirStory(foto, tipoSeleccionado, maxVis: vistasDrop);
    
    if (mounted) {
      setState(() => _subiendo = false);
      if (exito) {
        widget.onStoryVisto();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Historia subida! 🚀'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir historia'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: ZyncRadarList(
        usuariosAgrupados: _agruparStories(),
        miAvatarUrl: widget.miAvatarUrl,
        subiendo: _subiendo,
        onAddTap: _crearNuevaStory,
        onStoryTap: (stories) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoryViewerScreen(stories: stories, onStoryVisto: widget.onStoryVisto))),
      ),
    );
  }
}