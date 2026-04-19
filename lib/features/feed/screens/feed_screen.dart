import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../facades/feed_facade.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedFacade _facade = FeedFacade();
  List<dynamic> _publicaciones = [];
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _estaCargando = true);
    final publicaciones = await _facade.cargarFeed();

    if (mounted) {
      setState(() {
        _publicaciones = publicaciones;
        _estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Zync',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _estaCargando
          ? const Center(child: CircularProgressIndicator())
          : _publicaciones.isEmpty
          ? const Center(child: Text('No hay publicaciones todavía.'))
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: _publicaciones.length,
                itemBuilder: (context, index) {
                  final publicacion = _publicaciones[index];

                  String tiempoAmigable = '';

                  if (publicacion['fecha_creacion'] != null) {
                    try {
                      final fechaOriginal = DateTime.parse(
                        publicacion['fecha_creacion'],
                      );
                      tiempoAmigable = timeago.format(
                        fechaOriginal,
                        locale: 'es',
                      );
                    } catch (e) {
                      tiempoAmigable =
                          '';
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '@${publicacion['username']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                tiempoAmigable,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            publicacion['contenido'],
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  publicacion['le_has_dado_like'] > 0
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                color: publicacion['le_has_dado_like'] > 0
                                    ? Colors.red
                                    : Colors.grey[600],
                                onPressed: () async {
                                  final exito = await _facade.alternarLike(
                                    publicacion['id'],
                                  );
                                  if (exito) {
                                    _cargarDatos();
                                  }
                                },
                              ),
                              Text(
                                '${publicacion['total_likes']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline),
                                color: Colors.grey[600],
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) => CommentsScreen(
                                            publicacion: publicacion,
                                          ),
                                        ),
                                      )
                                      .then((_) {
                                        _cargarDatos();
                                      });
                                },
                              ),
                              Text(
                                // Usamos ?? 0 por si acaso el servidor aún no envía el dato
                                '${publicacion['total_comentarios'] ?? 0}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final resultado = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
          if (resultado == true) {
            _cargarDatos();
          }
        },
      ),
    );
  }
}
