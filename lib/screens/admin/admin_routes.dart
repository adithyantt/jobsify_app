import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminRoutes {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      default:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
    }
  }
}
