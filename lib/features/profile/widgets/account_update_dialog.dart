import 'package:flutter/material.dart';

class AccountUpdateDialog extends StatefulWidget {
  final String titulo;
  final String endpoint;
  final String campoBase;
  final bool esPassword;
  final Future<String?> Function(String, Map<String, dynamic>) onSave;

  const AccountUpdateDialog({
    super.key, required this.titulo, required this.endpoint, required this.campoBase,
    this.esPassword = false, required this.onSave,
  });

  @override
  State<AccountUpdateDialog> createState() => _AccountUpdateDialogState();
}

class _AccountUpdateDialogState extends State<AccountUpdateDialog> {
  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _c1, obscureText: widget.esPassword, decoration: InputDecoration(labelText: widget.esPassword ? 'Contraseña Actual' : 'Nuevo valor', border: const OutlineInputBorder())),
        if (widget.esPassword) ...[
          const SizedBox(height: 12),
          TextField(controller: _c2, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva Contraseña', border: OutlineInputBorder())),
        ],
      ]),
      actions: [
        TextButton(onPressed: _cargando ? null : () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: _cargando ? null : () async {
            if (_c1.text.trim().isEmpty) return;
            setState(() => _cargando = true);
            Map<String, dynamic> body = widget.esPassword 
                ? {'password_actual': _c1.text, 'password_nueva': _c2.text} 
                : {widget.campoBase: _c1.text.trim()};
            
            final error = await widget.onSave(widget.endpoint, body);
            if (mounted) {
              setState(() => _cargando = false);
              if (error == null) Navigator.pop(context, true);
              else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
            }
          },
          child: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
        ),
      ],
    );
  }
}