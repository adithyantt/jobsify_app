import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Jobsify",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B0C6D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Find local jobs and manage work easily",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              _inputField(label: "Email", controller: emailController),
              const SizedBox(height: 20),

              _inputField(
                label: "Password",
                controller: passwordController,
                isPassword: true,
                showPassword: showPassword,
                onToggle: () {
                  setState(() => showPassword = !showPassword);
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B0C6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isLoading ? null : _loginUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "LOGIN",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("You don't have an account yet? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final error = _validateFields();
    if (error != null) {
      _showSnack(error);
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.loginUser(
      email: email,
      password: password,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result["success"] != true) {
      if (result["unverified"] == true) {
        // Navigate to OTP verification
        final userId = result["user_id"];
        final userName = result["name"] ?? "User"; // Backend should return name
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {'userId': userId, 'userName': userName, 'email': email},
        );
      } else {
        _showSnack(result["message"] ?? "Login failed");
      }
      return;
    }

    // Check user role from session
    if (UserSession.role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  String? _validateFields() {
    if (!emailController.text.contains("@")) {
      return "Enter a valid email address";
    }
    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !showPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
