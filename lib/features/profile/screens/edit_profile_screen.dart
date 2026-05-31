import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../facades/profile_facade.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String? currentBio;
  final String? currentAvatarUrl;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    this.currentBio,
    this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileFacade _facade = ProfileFacade();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  File? _nuevaImagen;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio ?? '');
  }

  Future<void> _seleccionarYRecortarImagen() async {
    final XFile? imagenOriginal = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagenOriginal == null) return;

    if (!mounted) return;
    final ctx = context;

    CroppedFile? imagenRecortada = await ImageCropper().cropImage(
      sourcePath: imagenOriginal.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto',
          toolbarColor: Theme.of(ctx).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Ajustar Foto',
          cropStyle: CropStyle.circle,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          aspectRatioLockEnabled: true,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
        if (kIsWeb)
          WebUiSettings(
            context: ctx,
            presentStyle: WebPresentStyle.page, 
            size: const CropperSize(width: 520, height: 520),
            viewwMode: WebViewMode.mode_1,
            dragMode: WebDragMode.move,
            initialAspectRatio: 1.0,
            cropBoxMovable: false,
            cropBoxResizable: false,
            guides: false,
            center: true,
            translations: const WebTranslations(
              title: 'Ajustar Foto',
              rotateLeftTooltip: 'Rotar a la izquierda',
              rotateRightTooltip: 'Rotar a la derecha',
              cancelButton: 'Cancelar',
              cropButton: 'Recortar',
            ),
          ),
      ],
    );

    if (imagenRecortada != null && mounted) {
      setState(() {
        _nuevaImagen = File(imagenRecortada.path);
      });
    }
  }

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);

    final exito = await _facade.editarPerfil(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      imagePath: _nuevaImagen?.path,
    );

    if (mounted) {
      setState(() => _guardando = false);
      if (exito) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar o usuario ya en uso')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          _guardando
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : TextButton(
                  onPressed: _guardarCambios,
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _seleccionarYRecortarImagen,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _obtenerImagenAvatar(),
                    child: _obtenerImagenAvatar() == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorPrimario,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de usuario',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                labelText: 'Biografía',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                hintText: 'Cuéntanos algo sobre ti...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _obtenerImagenAvatar() {
    if (_nuevaImagen != null) {
      return FileImage(_nuevaImagen!);
    } else if (widget.currentAvatarUrl != null) {
      return NetworkImage(widget.currentAvatarUrl!);
    }
    return null;
  }
}