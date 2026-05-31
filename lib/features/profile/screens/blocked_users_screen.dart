import 'package:flutter/material.dart';
import '../facades/profile_facade.dart';
import '../../../services/moderacion_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final ProfileFacade _facade = ProfileFacade();
  List<dynamic> _bloqueados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarBloqueados();
  }

  Future<void> _cargarBloqueados() async {
    setState(() => _cargando = true);
    final lista = await _facade.cargarUsuariosBloqueados();
    if (mounted) {
      setState(() {
        _bloqueados = lista;
        _cargando = false;
      });
    }
  }

  Future<void> _desbloquear(int usuarioId, String username, int index) async {
    final exito = await ModeracionService().bloquearUsuario(usuarioId);
    
    if (exito && mounted) {
      setState(() {
        _bloqueados.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has desbloqueado a @$username'), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al desbloquear usuario'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Bloqueados', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _bloqueados.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes a ningún usuario bloqueado.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _bloqueados.length,
                  itemBuilder: (context, index) {
                    final usr = _bloqueados[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorPrimario.withOpacity(0.1),
                        backgroundImage: usr['avatar_url'] != null ? NetworkImage(usr['avatar_url']) : null,
                        child: usr['avatar_url'] == null
                            ? Text(
                                usr['username'][0].toUpperCase(), 
                                style: TextStyle(color: colorPrimario, fontWeight: FontWeight.bold)
                              )
                            : null,
                      ),
                      title: Text('@${usr['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: TextButton(
                        onPressed: () => _desbloquear(usr['id'], usr['username'], index),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Desbloquear', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
    );
  }
}