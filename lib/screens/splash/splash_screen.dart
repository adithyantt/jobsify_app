import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      try {
        // Check if user is already logged in
        if (UserSession.isLoggedIn) {
          if (UserSession.role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        // In case of any error, navigate to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.work_outline, size: 64, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'Jobsify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Skilled Labour Service Platform',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
