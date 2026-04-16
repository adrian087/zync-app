import 'package:flutter/material.dart';
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

  void _publicar() async {
    final texto = _contenidoController.text.trim();
    if (texto.isEmpty) return; // No permitimos tweets vacíos

    setState(() => _estaCargando = true);

    final exito = await _facade.crearPublicacion(texto);

    if (!mounted) return;

    setState(() => _estaCargando = false);

    if (exito) {
      // Si va bien, cerramos esta pantalla y le decimos al Muro que "true" (hubo éxito)
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
          // El botón de publicar arriba a la derecha
          TextButton(
            onPressed: _estaCargando ? null : _publicar,
            child: _estaCargando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contenidoController,
          autofocus: true, // Abre el teclado automáticamente
          maxLength: 280, // Estilo Twitter
          maxLines: 8, // Permite escribir varias líneas
          decoration: const InputDecoration(
            hintText: '¿Qué está pasando?',
            border: InputBorder.none, // Quitamos la línea de abajo para que quede más limpio
          ),
        ),
      ),
    );
  }
}