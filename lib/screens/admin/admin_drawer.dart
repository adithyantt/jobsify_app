import 'package:flutter/material.dart';
import 'admin_constants.dart';
import 'admin_dashboard.dart';
import 'screens/job_verification_screen.dart';
import 'screens/provider_verification_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/users_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              child: const Text(
                AdminConstants.appTitle,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text(AdminConstants.dashboard),
              onTap: () => _openDashboard(context),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text(AdminConstants.jobVerification),
              onTap: () => _open(context, JobVerificationScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text(AdminConstants.providerVerification),
              onTap: () => _open(context, const ProviderVerificationScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text(AdminConstants.reports),
              onTap: () => _open(context, const ReportsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text(AdminConstants.users),
              onTap: () => _open(context, const UsersScreen()),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // later: implement logout
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
