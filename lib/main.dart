import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/screens/login_screen.dart';
import 'main_screen.dart';
import 'firebase_options.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const storage = FlutterSecureStorage();
  final isDark = await storage.read(key: 'is_dark_mode');
  if (isDark == 'true') {
    themeNotifier.value = ThemeMode.dark;
  }

  final String? token = await storage.read(key: 'jwt_token');
  final Widget pantallaInicial = (token != null && token.isNotEmpty) 
      ? const MainScreen() 
      : const LoginScreen();

  runApp(MiRedSocialApp(pantallaInicial: pantallaInicial));
}

class MiRedSocialApp extends StatelessWidget {
  final Widget pantallaInicial;

  const MiRedSocialApp({super.key, required this.pantallaInicial});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Zync',
          debugShowCheckedModeBanner: false,

          themeMode: currentMode,

          builder: (context, child) {
            return Container(
              color: currentMode == ThemeMode.dark ? Colors.black : Colors.grey[200],
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    boxShadow: kIsWeb 
                        ? [const BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)] 
                        : null,
                  ),
                  child: ClipRect(child: child),
                ),
              ),
            );
          },
          
          // TEMA CLARO
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1DA1F2),
              surface: const Color(0xFFF8F9FA),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
          ),

          // TEMA OSCURO
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black, 
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1DA1F2),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.grey[900], 
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
          ),

          home: pantallaInicial,
        );
      },
    );
  }
}