import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/feed_facade.dart';

class CommentsScreen extends StatefulWidget {
  // Le pasamos la publicación entera para poder mostrarla arriba
  final Map<String, dynamic> publicacion;

  const CommentsScreen({super.key, required this.publicacion});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FeedFacade _facade = FeedFacade();
  final TextEditingController _comentarioController = TextEditingController();
  
  List<dynamic> _comentarios = [];
  bool _estaCargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final comentarios = await _facade.cargarComentarios(widget.publicacion['id']);
    if (mounted) {
      setState(() {
        _comentarios = comentarios;
        _estaCargando = false;
      });
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);
    
    final exito = await _facade.publicarComentario(widget.publicacion['id'], texto);
    
    if (exito) {
      _comentarioController.clear(); // Limpiamos la caja de texto
      await _cargarDatos(); // Recargamos la lista para ver el nuevo comentario
    }
    
    if (mounted) setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Comentarios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. EL TWEET ORIGINAL (Arriba del todo)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.publicacion['username']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(widget.publicacion['contenido'], style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. LA LISTA DE COMENTARIOS
          Expanded(
            child: _estaCargando
                ? const Center(child: CircularProgressIndicator())
                : _comentarios.isEmpty
                    ? const Center(child: Text('Sé el primero en comentar.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _comentarios.length,
                        itemBuilder: (context, index) {
                          final comentario = _comentarios[index];
                          
                          // Formatear la fecha
                          String tiempo = '';
                          if (comentario['fecha_creacion'] != null) {
                            try {
                              tiempo = timeago.format(DateTime.parse(comentario['fecha_creacion']), locale: 'es');
                            } catch (_) {}
                          }

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('@${comentario['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(tiempo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(comentario['contenido'], style: const TextStyle(color: Colors.black87)),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // 3. LA BARRA INFERIOR PARA ESCRIBIR
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      decoration: InputDecoration(
                        hintText: 'Añadir un comentario...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _enviando
                      ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator())
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _enviarComentario,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}