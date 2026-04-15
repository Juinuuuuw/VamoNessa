import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/join_event_screen.dart'; // ← NOVO IMPORT
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vamo Nessa',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            }
            return const MainScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      onGenerateRoute: (settings) {
        // Rota com argumento (eventId)
        if (settings.name == '/inside_event') {
          final eventId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: eventId),
          );
        }
        // Rota de convite (pode receber código via deep link)
        if (settings.name == '/join') {
          final code = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => JoinEventScreen(initialCode: code),
          );
        }
        // Rotas simples
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
              builder: (_) => const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),
            );
        }
      },
    );
  }
}