import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsify/main.dart';
import 'package:jobsify/screens/auth/forgot_password_screen.dart';
import 'package:jobsify/screens/auth/login_screen.dart';
import 'package:jobsify/screens/auth/otp_verification_screen.dart';
import 'package:jobsify/screens/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders and transitions from splash to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Login screen shows validation errors and forgot password link', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    await tester.enterText(find.byType(TextFormField).first, 'bad-email');
    await tester.enterText(find.byType(TextFormField).last, '');
    await tester.ensureVisible(find.text('LOGIN'));
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Register screen auto-capitalizes names and normalizes email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RegisterScreen()),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'john');
    await tester.enterText(fields.at(1), 'doe');
    await tester.enterText(fields.at(2), 'USER@MAIL.COM ');
    await tester.pump();

    final firstNameField = tester.widget<TextFormField>(fields.at(0));
    final lastNameField = tester.widget<TextFormField>(fields.at(1));
    final emailField = tester.widget<TextFormField>(fields.at(2));

    expect(firstNameField.controller?.text, 'John');
    expect(lastNameField.controller?.text, 'Doe');
    expect(emailField.controller?.text, 'user@mail.com');
  });

  testWidgets('Register screen enforces strong password rules', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RegisterScreen()),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'John');
    await tester.enterText(fields.at(1), 'Doe');
    await tester.enterText(fields.at(2), 'john@example.com');
    await tester.enterText(fields.at(3), 'Password1');
    await tester.ensureVisible(find.text('SIGN UP'));
    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Password must include uppercase, lowercase, number, and special character',
      ),
      findsOneWidget,
    );
  });

  testWidgets('OTP screen shows 5 minute expiry message and validates OTP', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationScreen(
          userId: 1,
          userName: 'John Doe',
          email: 'john@example.com',
        ),
      ),
    );

    expect(find.textContaining('Code expires in 05:00'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '12');
    await tester.tap(find.text('VERIFY OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid 6-digit OTP'), findsOneWidget);
  });

  testWidgets('Forgot password screen validates request email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ForgotPasswordScreen()),
    );

    await tester.enterText(find.byType(TextFormField).first, 'wrong-email');
    await tester.tap(find.text('SEND RESET OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
