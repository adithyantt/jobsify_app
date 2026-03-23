import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _requesting = false;
  bool _resetting = false;
  bool _showResetStep = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Reset your password",
      subtitle: "",
      footer: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Back to Login",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      children: [
        if (!_showResetStep) _buildRequestStep() else _buildResetStep(),
      ],
    );
  }

  Widget _buildRequestStep() {
    return Form(
      key: _requestFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthInputField(
            label: "Email",
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
            onChanged: _normalizeEmail,
            onSubmitted: (_) => _requestResetOtp(),
            autofillHints: const [AutofillHints.email],
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
              onPressed: _requesting ? null : _requestResetOtp,
              child: _requesting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "SEND RESET OTP",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AbsorbPointer(
            child: AuthInputField(
              label: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              onChanged: _normalizeEmail,
            ),
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: "6-digit OTP",
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: _validateOtp,
            onChanged: _normalizeOtp,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _requesting ? null : _requestResetOtp,
              child: const Text(
                "Resend OTP",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: "New Password",
            controller: passwordController,
            isPassword: true,
            showPassword: _showPassword,
            validator: _validatePassword,
            onToggle: () {
              setState(() => _showPassword = !_showPassword);
            },
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: "Confirm Password",
            controller: confirmPasswordController,
            isPassword: true,
            showPassword: _showConfirmPassword,
            validator: _validateConfirmPassword,
            onToggle: () {
              setState(() => _showConfirmPassword = !_showConfirmPassword);
            },
            onSubmitted: (_) => _resetPassword(),
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
              onPressed: _resetting ? null : _resetPassword,
              child: _resetting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "RESET PASSWORD",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestResetOtp() async {
    FocusScope.of(context).unfocus();

    // Strict validation for both initial request and resend
    final emailError = _validateEmail(emailController.text);
    if (emailError != null) {
      _showErrorSnack(emailError);
      return;
    }

    setState(() => _requesting = true);
    final result = await AuthService.requestPasswordReset(
      email: emailController.text.trim().toLowerCase(),
    );
    if (!mounted) return;
    setState(() => _requesting = false);

    if (result["success"] == true) {
      _showSuccessSnack(result["message"] ?? "Reset OTP sent");
      setState(() => _showResetStep = true);
    } else {
      _showErrorSnack(result["message"] ?? "Unable to send reset OTP");
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    if (!_resetFormKey.currentState!.validate()) {
      _showErrorSnack("Please correct the highlighted fields");
      return;
    }

    setState(() => _resetting = true);
    final result = await AuthService.resetPassword(
      email: emailController.text.trim().toLowerCase(),
      otp: otpController.text.trim(),
      newPassword: passwordController.text,
    );
    if (!mounted) return;
    setState(() => _resetting = false);

    if (result["success"] == true) {
      _showSuccessSnack(result["message"] ?? "Password reset successful");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showErrorSnack(result["message"] ?? "Unable to reset password");
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

  void _normalizeOtp(String value) {
    final normalized = value.replaceAll(RegExp(r'\D'), '');
    if (normalized == value) return;
    otpController.value = TextEditingValue(
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

  String? _validateOtp(String? value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')) {
      return "Please enter a valid 6-digit OTP";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8 ||
        !RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$',
        ).hasMatch(password)) {
      return "Password must include uppercase, lowercase, number, and special character";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
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

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
