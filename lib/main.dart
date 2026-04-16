import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/join_event_screen.dart';
import 'screens/loading_screen.dart';
import 'services/accessibility_settings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AccessibilitySettings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _defaultTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B80F9),
        secondary: Color(0xFFF9A866),
        surface: Colors.white,
        background: Color(0xFFF7DFCA),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B80F9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  ThemeData _highContrastTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Colors.yellow,
        secondary: Colors.cyan,
        surface: Colors.black,
        background: Colors.black,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.yellow),
        titleTextStyle: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.yellow)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.yellow)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.yellow, width: 2)),
        labelStyle: const TextStyle(color: Colors.yellow),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: Colors.yellow),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AccessibilitySettings.textScaleNotifier,
      builder: (context, scale, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: AccessibilitySettings.highContrastNotifier,
          builder: (context, isHighContrast, child) {
            return MaterialApp(
              title: 'Vamo Nessa',
              theme: isHighContrast ? _highContrastTheme() : _defaultTheme(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                  child: child!,
                );
              },
              debugShowCheckedModeBanner: false,
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingScreen(); // Tela de carregamento inicial
                  }
                  final user = snapshot.data;
                  if (user == null) {
                    return const LoginScreen();
                  }
                  return const MainScreen();
                },
              ),
              onGenerateRoute: (settings) {
                if (settings.name == '/inside_event') {
                  final eventId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(eventId: eventId),
                  );
                }
                if (settings.name == '/join') {
                  final code = settings.arguments as String?;
                  return MaterialPageRoute(
                    builder: (context) => JoinEventScreen(initialCode: code),
                  );
                }
                switch (settings.name) {
                  case '/login':
                    return MaterialPageRoute(builder: (_) => const LoginScreen());
                  case '/signup':
                    return MaterialPageRoute(builder: (_) => const SignUpScreen());
                  case '/main':
                    return MaterialPageRoute(builder: (_) => const MainScreen());
                  case '/create_event':
                    return MaterialPageRoute(builder: (_) => const CreateEventScreen());
                  case '/profile':
                    return MaterialPageRoute(builder: (_) => const ProfileScreen());
                  default:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(body: Center(child: Text('Rota não encontrada'))),
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}