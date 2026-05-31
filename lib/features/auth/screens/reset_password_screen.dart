import 'package:flutter/material.dart';
import '../facades/auth_facade.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String codigo;
  const ResetPasswordScreen({super.key, required this.email, required this.codigo});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();
  bool _cargando = false;

  void _cambiarPassword() async {
    if (_passController.text != _pass2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red));
      return;
    }
    if (_passController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _cargando = true);
    final resultado = await AuthFacade().cambiarPasswordConCodigo(widget.email, widget.codigo, _passController.text);

    if (!mounted) return;
    setState(() => _cargando = false);

    if (resultado['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Contraseña cambiada con éxito! Inicia sesión.'), backgroundColor: Colors.green));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado['error']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pass2Controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _cambiarPassword,
                child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar y Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}