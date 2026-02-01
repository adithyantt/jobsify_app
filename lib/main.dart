import 'package:flutter/material.dart';

// Splash Screen
import 'screens/splash/splash_screen.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// Home Screen
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobsify',
      debugShowCheckedModeBanner: false,

      // Entry point of the app
      home: const SplashScreen(),
      // Centralized route management
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
