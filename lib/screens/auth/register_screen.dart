import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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
    return AuthShell(
      title: "Create your account",
      subtitle: "",
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account? "),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              "Log in",
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
                label: "First Name",
                controller: firstNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateName(value, "First name"),
                autofillHints: const [AutofillHints.givenName],
              ),
              const SizedBox(height: 18),
              AuthInputField(
                label: "Last Name",
                controller: lastNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateName(value, "Last name"),
                autofillHints: const [AutofillHints.familyName],
              ),
              const SizedBox(height: 18),
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
                onSubmitted: (_) => _registerUser(),
                onToggle: () {
                  setState(() => showPassword = !showPassword);
                },

                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 28),
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
                  onPressed: isLoading ? null : _registerUser,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SIGN UP",
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

  Future<void> _registerUser() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showErrorSnack("Please correct the highlighted fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.registerUser(
        firstName: _formatName(firstNameController.text),
        lastName: _formatName(lastNameController.text),
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      if (!mounted) return;

      final success = result["success"] == true;
      final message = result["message"] ?? "Registration failed";

      if (success || message.contains("OTP resent")) {
        userId = result["user_id"];
        final fullName =
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/otp-verification',
          (route) => false,
          arguments: {
            'userId': userId,
            'userName': fullName,
            'email': emailController.text.trim().toLowerCase(),
          },
        );
      } else {
        _showErrorSnack(message);
      }
    } catch (_) {
      _showErrorSnack("Unable to connect to server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatName(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final lower = part.toLowerCase();
          return "${lower[0].toUpperCase()}${lower.substring(1)}";
        })
        .join(' ');
  }

  void _normalizeEmail(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == value) return;
    emailController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  String? _validateName(String? value, String fieldName) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return "$fieldName is required";
    }
    if (!RegExp(r"^[A-Za-z]+(?:[ '-][A-Za-z]+)*$").hasMatch(normalized)) {
      return "$fieldName can only contain letters";
    }
    if (normalized.length < 2) {
      return "$fieldName must be at least 2 characters";
    }
    return null;
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
    final password = value ?? '';
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 8 ||
        !RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$',
        ).hasMatch(password)) {
      return "Password must include uppercase, lowercase, number, and special character";
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
