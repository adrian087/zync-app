import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../facades/profile_facade.dart';
import '../../feed/facades/feed_facade.dart';
import '../../auth/screens/login_screen.dart';
import '../../feed/widgets/post_card.dart'; 
import '../widgets/profile_header.dart'; 
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileFacade _profileFacade = ProfileFacade();
  final FeedFacade _feedFacade = FeedFacade();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _datosPerfil;
  List<dynamic> _publicacionesGuardadas = [];
  bool _estaCargando = true;
  bool _subiendoAvatar = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosCompletos();
  }

  Future<void> _cargarDatosCompletos() async {
    setState(() => _estaCargando = true);
    final resultados = await Future.wait([
      _profileFacade.cargarDatosPerfil(),
      _feedFacade.cargarGuardados(),
    ]);

    if (mounted) {
      setState(() {
        _datosPerfil = resultados[0] as Map<String, dynamic>?;
        _publicacionesGuardadas = resultados[1] as List<dynamic>;
        _estaCargando = false;
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tomar foto con la cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  _actualizarAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarAvatar(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (foto == null) return;

      CroppedFile? imagenRecortada = await ImageCropper().cropImage(
        sourcePath: foto.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Ajustar Avatar',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            lockAspectRatio: true,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Ajustar Avatar',
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.page,
          ),
        ],
      );

      if (imagenRecortada != null) {
        setState(() => _subiendoAvatar = true);

        final exito = await _profileFacade.editarPerfil(
          imagePath: imagenRecortada.path,
        );

        if (exito) {
          await _cargarDatosCompletos();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Foto actualizada con éxito! ✅'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar la foto'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error al cambiar avatar: $e");
    } finally {
      if (mounted) setState(() => _subiendoAvatar = false);
    }
  }

  Widget _construirLista(
    List<dynamic> publicaciones, {
    required String mensajeVacio,
    required bool esMiPerfil,
  }) {
    if (publicaciones.isEmpty) {
      return Center(
        child: Text(mensajeVacio, style: const TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatosCompletos,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: publicaciones.length,
        itemBuilder: (context, index) {
          final post = publicaciones[index];

          if (esMiPerfil) {
            return Dismissible(
              key: Key('mis_zyncs_${post['id']}'),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Borrar publicación?'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar este Zync?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                final exito = await _profileFacade.borrarPublicacion(
                  post['id'],
                );
                if (exito) {
                  _cargarDatosCompletos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada')),
                  );
                }
              },
              child: PostCard(
                publicacion: post,
                miUsuarioId: _datosPerfil?['id'],
                onUpdate: _cargarDatosCompletos,
              ),
            );
          }

          return PostCard(
            publicacion: post,
            miUsuarioId: _datosPerfil?['id'],
            onUpdate: _cargarDatosCompletos,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mi Perfil',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _cargarDatosCompletos()),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _storage.delete(key: 'jwt_token');
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: _estaCargando
            ? const Center(child: CircularProgressIndicator())
            : _datosPerfil == null
            ? const Center(child: Text('Error al cargar el perfil'))
            : Column(
                children: [
                  ProfileHeader(
                    datosPerfil: _datosPerfil!,
                    subiendoAvatar: _subiendoAvatar,
                    onAvatarTap: _mostrarOpcionesImagen,
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Mis Zyncs'),
                      Tab(text: 'Guardados'),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _construirLista(
                          _datosPerfil!['publicaciones'],
                          mensajeVacio: 'Aún no has publicado nada.',
                          esMiPerfil: true,
                        ),
                        _construirLista(
                          _publicacionesGuardadas,
                          mensajeVacio: 'Aún no has guardado ningún Zync.',
                          esMiPerfil: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}