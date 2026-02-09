import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

import '../../services/user_session.dart';

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
  late int? userId;
  late String? userName;
  late String? email;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    userName = widget.userName;
    email = widget.email;
  }

  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
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
                "Verify your email",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              const Text(
                "Enter the 6-digit OTP sent to your email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),

              _inputField(
                label: "Enter 6-digit OTP",
                controller: otpController,
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
                  onPressed: isLoading ? null : _verifyOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "VERIFY OTP",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Go back to register
                  },
                  child: const Text(
                    "Back to Register",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔐 VERIFY OTP
  Future<void> _verifyOtp() async {
    if (otpController.text.length != 6) {
      _showSnack("Please enter a valid 6-digit OTP");
      return;
    }

    if (userId == null) {
      _showSnack("Invalid user session. Please try again.");
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
        _showSnack(message);
        // Navigate to home screen after verification
        if (UserSession.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showSnack(message);
      }
    } catch (e) {
      _showSnack("Unable to connect to server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            counterText: "",
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
