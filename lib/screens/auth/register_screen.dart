import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  int? userId;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
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
                "Create an account to get started",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              _inputField(
                label: "First Name",
                controller: firstNameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              _inputField(
                label: "Last Name",
                controller: lastNameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

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

              const SizedBox(height: 30),

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
                  onPressed: isLoading ? null : _registerUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIGN UP",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Sign in",
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

  /// 🔐 REGISTER USER
  Future<void> _registerUser() async {
    final error = _validateFields();
    if (error != null) {
      _showSnack(error);
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      // AuthService.registerUser returns a Map with `success`, `message`, and `user_id`.
      final success = result["success"] == true;
      final message = result["message"] ?? "Registration failed";

      if (success) {
        userId = result["user_id"];
        final fullName =
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
        // Clear navigation stack and go to OTP
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/otp-verification',
          (route) => false, // This removes all previous routes
          arguments: {
            'userId': userId,
            'userName': fullName,
            'email': emailController.text.trim(),
          },
        );
      } else {
        // Check if it's an OTP resent message for existing unverified user
        if (message.contains("OTP resent")) {
          userId = result["user_id"];
          final fullName =
              "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
          // Clear navigation stack and go to OTP
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/otp-verification',
            (route) => false, // This removes all previous routes
            arguments: {
              'userId': userId,
              'userName': fullName,
              'email': emailController.text.trim(),
            },
          );
        } else {
          _showSnack(message);
        }
      }
    } catch (e) {
      _showSnack("Unable to connect to server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String? _validateFields() {
    if (firstNameController.text.trim().length < 1) {
      return "First name is required";
    }
    if (lastNameController.text.trim().length < 1) {
      return "Last name is required";
    }
    if (!RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    ).hasMatch(emailController.text.trim())) {
      return "Enter a valid email address";
    }
    if (passwordController.text.length < 8 ||
        !RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
        ).hasMatch(passwordController.text)) {
      return "Password must be at least 8 characters with uppercase, lowercase, and number";
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
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !showPassword,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
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
