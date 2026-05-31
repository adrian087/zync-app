import 'package:flutter/material.dart';
import '../facades/auth_facade.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _cargando = false;

  void _solicitarCodigo() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _cargando = true);

    final resultado = await AuthFacade().solicitarCodigoReset(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _cargando = false);

    if (resultado['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyCodeScreen(email: _emailController.text.trim())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado['error']), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Introduce tu correo electrónico. Te enviaremos un código de 6 dígitos para recuperar tu cuenta.', textAlign: TextAlign.center),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _solicitarCodigo,
                child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Enviar Código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}