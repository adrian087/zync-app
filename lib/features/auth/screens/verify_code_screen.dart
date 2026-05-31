import 'dart:async';
import 'package:flutter/material.dart';
import '../facades/auth_facade.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _cargando = false;
  
  Timer? _timer;
  int _segundosRestantes = 60;
  bool _puedeReenviar = false;

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador();
  }

  void _iniciarTemporizador() {
    setState(() {
      _segundosRestantes = 60;
      _puedeReenviar = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        setState(() => _puedeReenviar = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verificarCodigo() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El código debe tener 6 dígitos'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _cargando = true);

    final resultado = await AuthFacade().verificarCodigoReset(widget.email, codigo);

    if (!mounted) return;
    setState(() => _cargando = false);

    if (resultado['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: widget.email, codigo: codigo)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado['error']), backgroundColor: Colors.red));
    }
  }

  void _reenviarCodigo() async {
    if (!_puedeReenviar) return;
    _iniciarTemporizador();
    await AuthFacade().solicitarCodigoReset(widget.email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nuevo código enviado'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Código de Verificación')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hemos enviado un código de 6 dígitos a:\n${widget.email}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _codigoController,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 32, letterSpacing: 8, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '000000', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _verificarCodigo,
                child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Verificar Código'),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _puedeReenviar ? _reenviarCodigo : null,
              child: Text(_puedeReenviar ? 'Reenviar código ahora' : 'Podrás reenviar el código en $_segundosRestantes s', style: TextStyle(color: _puedeReenviar ? Colors.blue : Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}