import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const JobsifyApp());
}

class JobsifyApp extends StatelessWidget {
  const JobsifyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobsify',
      debugShowCheckedModeBanner: false,

      home: const LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
