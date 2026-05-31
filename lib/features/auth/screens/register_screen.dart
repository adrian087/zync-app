import '../../../main_screen.dart';
import 'package:flutter/material.dart';
import '../facades/auth_facade.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthFacade _authFacade = AuthFacade();

  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _estaCargando = false;

  void _hacerRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    // Llamamos al Facade con los 5 campos
    final resultado = await _authFacade.intentarRegistro(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _estaCargando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['message']),
        backgroundColor: resultado['success'] ? Colors.green : Colors.red,
      ),
    );

    if (resultado['success']) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false, // Esto borra el historial para que no puedan darle "Atrás" y volver al registro
      ); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Únete a Zync')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 60, color: Colors.blue),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _nombresController,
                  decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Nombre de usuario (@)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.alternate_email)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  validator: (v) => v!.contains('@') ? null : 'Correo inválido',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _estaCargando ? null : _hacerRegistro,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: _estaCargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}