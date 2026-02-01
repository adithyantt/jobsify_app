import 'package:flutter/material.dart';

// admin screens
import 'screens/dashboard_screen.dart';
import 'screens/job_verifiication_screen.dart';
import 'screens/provider_verification_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/users_screen.dart';

class AdminDrawer extends StatelessWidget {
  final Function(Widget) onItemSelected;

  const AdminDrawer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              "Admin Panel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _drawerItem(
            context: context,
            icon: Icons.dashboard,
            title: "Dashboard",
            screen: const DashboardScreen(),
          ),

          _drawerItem(
            context: context,
            icon: Icons.verified,
            title: "Job Verification",
            screen: const JobVerificationScreen(),
          ),

          _drawerItem(
            context: context,
            icon: Icons.badge,
            title: "Provider Verification",
            screen: const ProviderVerificationScreen(),
          ),

          _drawerItem(
            context: context,
            icon: Icons.report,
            title: "Reports",
            screen: const ReportsScreen(),
          ),

          _drawerItem(
            context: context,
            icon: Icons.people,
            title: "Users",
            screen: const UsersScreen(),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              // later: clear token and navigate to login
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onItemSelected(screen);
      },
    );
  }
}
