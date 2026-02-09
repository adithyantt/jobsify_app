import 'package:flutter/material.dart';
import 'services/user_session.dart';
import 'services/theme_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await UserSession.loadSession();
    await ThemeService.loadTheme();
  } catch (e) {
    // In case of error loading session/theme, continue with defaults
    debugPrint('Error loading session/theme: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Jobsify',
          debugShowCheckedModeBanner: false,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/otp-verification': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              return OtpVerificationScreen(
                userId: args?['userId'],
                userName: args?['userName'],
                email: args?['email'],
              );
            },
            '/home': (context) => const HomeScreen(),
            '/admin': (context) => const AdminDashboard(),
          },
        );
      },
    );
  }
}
