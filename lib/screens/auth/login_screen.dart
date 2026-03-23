import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../widgets/auth/auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
    return AuthShell(
      title: "Login to Jobsify",
      subtitle: "",
      footer: Row(
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
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthInputField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
                onChanged: _normalizeEmail,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 18),
              AuthInputField(
                label: "Password",
                controller: passwordController,
                isPassword: true,
                showPassword: showPassword,
                textInputAction: TextInputAction.done,
                validator: _validatePassword,
                onSubmitted: (_) => _loginUser(),
                onToggle: () {
                  setState(() => showPassword = !showPassword);
                },
                autofillHints: const [AutofillHints.password],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text("Forgot password?"),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B0C6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loginUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showErrorSnack("Please correct the highlighted fields");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.loginUser(
      email: emailController.text.trim().toLowerCase(),
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result["success"] != true) {
      if (result["unverified"] == true) {
        final userId = result["user_id"];
        final firstName = result["first_name"] ?? "";
        final lastName = result["last_name"] ?? "";
        final fullName = [
          firstName,
          lastName,
        ].where((part) => part.toString().trim().isNotEmpty).join(" ");
        final email = emailController.text.trim().toLowerCase();
        final userName = fullName.isNotEmpty
            ? fullName
            : (email.contains('@') ? email.split('@').first : "User");
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'userId': userId,
            'userName': userName,
            'email': emailController.text.trim().toLowerCase(),
          },
        );
      } else {
        _showErrorSnack(result["message"] ?? "Login failed");
      }
      return;
    }

    if (UserSession.role == 'admin') {
      Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  void _normalizeEmail(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == value) return;
    emailController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$').hasMatch(email)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return "Password is required";
    }
    return null;
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
