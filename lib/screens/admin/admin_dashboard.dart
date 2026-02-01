import 'package:flutter/material.dart';
import 'admin_drawer.dart';
import 'screens/dashboard_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _selectedScreen = const DashboardScreen();

  void _changeScreen(Widget screen) {
    setState(() {
      _selectedScreen = screen;
    });
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobsify Admin"),
        backgroundColor: Colors.black,
      ),
      drawer: AdminDrawer(onItemSelected: _changeScreen),
      body: _selectedScreen,
    );
  }
}
