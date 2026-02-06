import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../settings/settings_screen.dart';

// 🔹 PLACEHOLDER SCREENS (we will implement later)
class MyWorkerScreen extends StatelessWidget {
  const MyWorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Worker Profile")),
      body: const Center(child: Text("Worker profile will appear here")),
    );
  }
}

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jobs Posted By Me")),
      body: const Center(child: Text("Your jobs will appear here")),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserSession.role ?? "user";

    return ValueListenableBuilder<String?>(
      valueListenable: UserSession.userNameNotifier,
      builder: (context, nameValue, _) {
        final name = nameValue ?? "User";
        final email = UserSession.email ?? "";

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 179),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role == "admin" ? "Administrator" : "Jobsify User",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 MY ACCOUNT SECTION
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "My Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                _ProfileCard(
                  icon: Icons.badge,
                  title: "I am a Worker",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyWorkerScreen()),
                    );
                  },
                ),

                _ProfileCard(
                  icon: Icons.work,
                  title: "Jobs posted by me",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyJobsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 GENERAL OPTIONS
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "General",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                _ProfileCard(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.history,
                  title: "My Activity",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _ProfileCard(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.logout,
                  title: "Logout",
                  isLogout: true,
                  onTap: () async {
                    UserSession.clear();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.red : Theme.of(context).primaryColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isLogout
                  ? Colors.red
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
