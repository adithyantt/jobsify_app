import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/theme_service.dart';
import '../../widgets/confirm_dialog.dart';
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
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                AdminConstants.appTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
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
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.themeNotifier,
              builder: (context, themeMode, _) {
                final isDark = themeMode == ThemeMode.dark;
                return ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () => ThemeService.toggleTheme(),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                final confirmed = await showConfirmDialog(
                  context: context,
                  title: 'Confirm Logout',
                  message: 'Are you sure you want to logout?',
                  confirmText: 'Logout',
                  cancelText: 'Cancel',
                );
                if (confirmed == true && context.mounted) {
                  Navigator.of(context).pop();
                  UserSession.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
