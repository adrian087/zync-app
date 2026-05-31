import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../facades/profile_facade.dart';
import '../../auth/screens/login_screen.dart';
import '../../../../main.dart';
import 'blocked_users_screen.dart';
import '../widgets/account_update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileFacade _facade = ProfileFacade();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  void _abrirDialogo(String t, String e, String c, {bool pass = false}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AccountUpdateDialog(titulo: t, endpoint: e, campoBase: c, esPassword: pass, onSave: _facade.actualizarDatoCuenta),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actualizado correctamente ✅'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          _buildSection('Ajustes de Perfil', [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Cambiar Nombre de Usuario'), onTap: () => _abrirDialogo('Cambiar Usuario', 'username', 'username')),
            ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Cambiar Correo Electrónico'), onTap: () => _abrirDialogo('Cambiar Correo', 'email', 'email')),
            ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Cambiar Contraseña'), onTap: () => _abrirDialogo('Cambiar Contraseña', 'password', '', pass: true)),
            ListTile(leading: const Icon(Icons.block_outlined), title: const Text('Usuarios Bloqueados'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockedUsersScreen()))),
          ]),
          _buildSection('Apariencia', [
            SwitchListTile(secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Modo Oscuro'), value: themeNotifier.value == ThemeMode.dark, onChanged: (val) async {
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              await _storage.write(key: 'is_dark_mode', value: val.toString());
              setState(() {});
            }),
          ]),
          _buildSection('Información Legal', [
            ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Política de Privacidad'), onTap: () async {
              final Uri url = Uri.parse('https://www.zync-app.net/politica');
              if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
            }),
          ]),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        ...children,
        const Divider(),
      ]);

  Widget _buildDangerZone() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('Zona de Peligro', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ListTile(leading: const Icon(Icons.delete_forever, color: Colors.red), title: const Text('Eliminar Cuenta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: _confirmarEliminar),
      ]);

  void _confirmarEliminar() {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('¿Eliminar cuenta?'), content: const Text('Esta acción es irreversible.'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
        if (await _facade.eliminarCuenta()) {
          await _storage.delete(key: 'jwt_token');
          if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
        }
      }, child: const Text('Sí, eliminar', style: TextStyle(color: Colors.white))),
    ]));
  }
}