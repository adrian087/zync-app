import 'package:flutter/material.dart';
import '../facades/search_facade.dart';
import 'package:mi_red_social_app/features/profile/screens/public_profile_screen.dart'; 
import '../../feed/widgets/zync_text_formatter.dart'; // 👈 Añadimos nuestro formateador mágico

class SearchScreen extends StatefulWidget {
  final String? initialQuery; 

  const SearchScreen({super.key, this.initialQuery}); // 👈 Lo añadimos al constructor

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _buscadorController = TextEditingController();
  final SearchFacade _facade = SearchFacade();
  
  List<dynamic> _resultadosUsuarios = [];
  List<dynamic> _resultadosPublicaciones = [];
  bool _estaBuscando = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _buscadorController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _realizarBusqueda(widget.initialQuery!);
      });
    }
  }

  void _realizarBusqueda(String texto) async {
    if (texto.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _resultadosUsuarios = [];
          _resultadosPublicaciones = [];
        });
      }
      return;
    }

    setState(() => _estaBuscando = true);

    final resultados = await Future.wait([
      _facade.buscarUsuarios(texto),
      _facade.buscarPublicaciones(texto)
    ]);

    if (!mounted) return;

    setState(() {
      _resultadosUsuarios = resultados[0];
      _resultadosPublicaciones = resultados[1];
      _estaBuscando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      initialIndex: (widget.initialQuery != null && widget.initialQuery!.startsWith('#')) ? 1 : 0,
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _buscadorController,
            autofocus: widget.initialQuery == null, // Solo hace autofocus si NO venimos de un clic
            decoration: InputDecoration(
              hintText: 'Buscar en Zync...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: const TextStyle(fontSize: 18),
            onChanged: _realizarBusqueda,
          ),
          actions: [
            if (_buscadorController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _buscadorController.clear();
                  _realizarBusqueda('');
                },
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Usuarios'),
              Tab(text: 'Zyncs'),
            ],
          ),
        ),
        
        body: TabBarView(
          children: [
            _estaBuscando
                ? const Center(child: CircularProgressIndicator())
                : _resultadosUsuarios.isEmpty
                    ? _mensajeVacio('No se encontraron usuarios')
                    : ListView.builder(
                        itemCount: _resultadosUsuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = _resultadosUsuarios[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorPrimario.withOpacity(0.1),
                              backgroundImage: usuario['avatar_url'] != null ? NetworkImage(usuario['avatar_url']) : null,
                              child: usuario['avatar_url'] == null 
                                ? Text(
                                    usuario['username'][0].toUpperCase(),
                                    style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold),
                                  )
                                : null,
                            ),
                            title: Text('@${usuario['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PublicProfileScreen(
                                    usuarioId: usuario['id'],
                                    usernamePreview: usuario['username'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

            _estaBuscando
                ? const Center(child: CircularProgressIndicator())
                : _resultadosPublicaciones.isEmpty
                    ? _mensajeVacio('No se encontraron publicaciones')
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _resultadosPublicaciones.length,
                        itemBuilder: (context, index) {
                          final post = _resultadosPublicaciones[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@${post['username']}', style: TextStyle(fontWeight: FontWeight.bold, color: colorPrimario)),
                                  const SizedBox(height: 8),
                                  
                                  ZyncTextFormatter(text: post['contenido']), 

                                  if (post['imagen_url'] != null) ...[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        post['imagen_url'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _mensajeVacio(String mensaje) {
    return Center(
      child: Text(
        _buscadorController.text.isEmpty ? 'Escribe para buscar...' : mensaje,
        style: TextStyle(color: Colors.grey[500], fontSize: 16),
      ),
    );
  }
}