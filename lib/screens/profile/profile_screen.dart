import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserSession.role ?? "user";

    // Use ValueListenableBuilder to reflect live changes to the logged-in user
    return ValueListenableBuilder<String?>(
      valueListenable: UserSession.userNameNotifier,
      builder: (context, nameValue, _) {
        final name = nameValue ?? "User";
        final email = UserSession.email ?? "";

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 🔵 PROFILE HEADER (Justdial style)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(color: Color(0xFF1B0C6D)),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFF1B0C6D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        role == "admin" ? "Administrator" : "Jobsify User",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 PROFILE OPTIONS
                _ProfileCard(icon: Icons.edit, title: "Edit Profile", onTap: () {}),
                _ProfileCard(
                  icon: Icons.history,
                  title: "My Activity",
                  onTap: () {},
                ),
                _ProfileCard(icon: Icons.settings, title: "Settings", onTap: () {}),
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
                    // Clear session and cached name
                    UserSession.clear();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_name');

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

    // ValueListenableBuilder returns the scaffold above; no fallback needed here.
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
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.red : const Color(0xFF1B0C6D),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isLogout ? Colors.red : Colors.black,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
