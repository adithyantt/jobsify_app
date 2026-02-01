import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminHomeGuard extends StatelessWidget {
  final bool isAdmin;

  const AdminHomeGuard({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return const AdminDashboard();
    }

    return const Scaffold(body: Center(child: Text("Unauthorized Access")));
  }
}
