import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../widgets/auth/auth_shell.dart';

class OtpVerificationScreen extends StatefulWidget {
  final int? userId;
  final String? userName;
  final String? email;

  const OtpVerificationScreen({
    super.key,
    this.userId,
    this.userName,
    this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  late int? userId;
  late String? userName;
  late String? email;
  bool isLoading = false;
  int _remainingSeconds = 300;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    userName = widget.userName;
    email = widget.email;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: "Verify your OTP",
      subtitle: "",
      footer: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Back",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Code expires in ${_formatTimer(_remainingSeconds)}",
                  style: const TextStyle(
                    color: Color(0xFF2649C7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AuthInputField(
                label: "6-digit OTP",
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                validator: _validateOtp,
                onSubmitted: (_) => _verifyOtp(),
                onChanged: _normalizeOtp,
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
                  onPressed: isLoading ? null : _verifyOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "VERIFY OTP",
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

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showErrorSnack("Please enter a valid OTP");
      return;
    }

    if (userId == null) {
      _showErrorSnack("Invalid user session. Please try again.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.verifyOtp(
        userId: userId!,
        otp: otpController.text,
      );

      if (!mounted) return;

      final success = result["success"] == true;
      final message = result["message"] ?? "Verification failed";

      if (success) {
        _showSuccessSnack(message);
        if (UserSession.role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        _showErrorSnack(message);
      }
    } catch (_) {
      _showErrorSnack("Unable to connect to server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _normalizeOtp(String value) {
    final normalized = value.replaceAll(RegExp(r'\D'), '');
    if (normalized == value) return;
    otpController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return "Please enter a valid 6-digit OTP";
    }
    return null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
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
