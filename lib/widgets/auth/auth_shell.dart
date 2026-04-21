import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B0C6D), Color(0xFF2649C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Jobsify",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFDCE6FF),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B0C6D).withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...children,
                      if (footer != null) ...[
                        const SizedBox(height: 24),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onToggle;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final Widget? helper;

  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.showPassword = false,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.maxLength,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF1C274C),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !showPassword,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          autofillHints: autofillHints,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF5F7FB),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF2649C7), width: 1.4),
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 8),
          helper!,
        ],
      ],
    );
  }
}
