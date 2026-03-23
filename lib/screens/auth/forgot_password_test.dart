import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsify/screens/auth/forgot_password_screen.dart';

void main() {
  testWidgets('Forgot Password Screen - UI and Validation Test', (
    WidgetTester tester,
  ) async {
    // Build the widget wrapped in MaterialApp
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    // Verify Screen Title
    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('SEND RESET OTP'), findsOneWidget);

    // Find the Email Input Field (First TextFormField)
    final emailField = find.byType(TextFormField).first;

    // --- TEST 1: Submit Empty ---
    // Tap send without entering text
    await tester.tap(find.text('SEND RESET OTP'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 100)); // Wait for validator

    // Expect validation error
    expect(find.text('Email is required'), findsOneWidget);

    // --- TEST 2: Submit Invalid Email ---
    // Enter invalid text
    await tester.enterText(emailField, 'not-an-email');
    await tester.pump();

    await tester.tap(find.text('SEND RESET OTP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Expect invalid email error
    expect(find.text('Enter a valid email address'), findsOneWidget);

    // --- TEST 3: Submit Valid Email ---
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    // Verify validation errors are gone
    expect(find.text('Enter a valid email address'), findsNothing);
  });
}
