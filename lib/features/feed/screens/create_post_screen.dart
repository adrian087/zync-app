import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 👈 IMPORTANTE
import 'package:image_picker/image_picker.dart';
import '../facades/feed_facade.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contenidoController = TextEditingController();
  final FeedFacade _facade = FeedFacade();
  bool _estaCargando = false;

  final ImagePicker _picker = ImagePicker();
  
  List<XFile> _imagenesSeleccionadas = []; 

  Future<void> _seleccionarImagenes() async {
    final List<XFile> seleccionadas = await _picker.pickMultiImage(
      imageQuality: 70,
    );
    
    if (seleccionadas.isNotEmpty) {
      setState(() {
        for (var img in seleccionadas) {
          if (_imagenesSeleccionadas.length < 4) {
            _imagenesSeleccionadas.add(img);
          }
        }
      });
      
      if (_imagenesSeleccionadas.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo 4 imágenes por Zync')),
        );
      }
    }
  }

  void _publicar() async {
    final texto = _contenidoController.text.trim();
    
    if (texto.isEmpty && _imagenesSeleccionadas.isEmpty) return; 

    setState(() => _estaCargando = true);

    final exito = await _facade.crearPublicacion(
      texto, 
      imagenes: _imagenesSeleccionadas
    );

    if (!mounted) return;

    setState(() => _estaCargando = false);

    if (exito) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al publicar'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Zync'),
        actions: [
          TextButton(
            onPressed: _estaCargando ? null : _publicar,
            child: _estaCargando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _contenidoController,
                      autofocus: true,
                      maxLength: 280,
                      maxLines: null, 
                      decoration: const InputDecoration(
                        hintText: '¿Qué está pasando?',
                        border: InputBorder.none,
                      ),
                    ),
                    
                    if (_imagenesSeleccionadas.isNotEmpty)
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(top: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imagenesSeleccionadas.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb 
                                      ? Image.network(
                                          _imagenesSeleccionadas[index].path,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_imagenesSeleccionadas[index].path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _imagenesSeleccionadas.removeAt(index));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 28,
                    onPressed: _seleccionarImagenes,
                  ),
                  const Text('Añadir fotos (Max. 4)', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}