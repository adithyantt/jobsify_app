import 'package:flutter/material.dart';
import '../jobs/post_job_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Temporary role flag (later from backend)
  final bool isProvider = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(title: const Text("Profile")),

      body: Column(
        children: [
          // User header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Adithyan T T",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "adithyan@email.com",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 6),
                Text(
                  "Role: Job Provider",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action list
          Expanded(
            child: ListView(
              children: [
                _ProfileTile(
                  icon: Icons.work_outline,
                  title: "My Jobs",
                  onTap: () {},
                ),

                if (isProvider)
                  _ProfileTile(
                    icon: Icons.add_circle_outline,
                    title: "Post a Job",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      );
                    },
                  ),

                _ProfileTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () {
                    // later: logout logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
