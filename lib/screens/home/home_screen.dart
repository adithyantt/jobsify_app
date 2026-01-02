import 'package:flutter/material.dart';
import '../jobs/jobs_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    Center(child: Text("Jobs Page", style: TextStyle(fontSize: 22))),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const AppDrawer(),

      appBar: AppBar(
        elevation: 0,
        title: const Text("Jobsify"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1B0C6D),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: "Jobs",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Search for jobs or services",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 🚀 PRIMARY ACTIONS (MOST IMPORTANT)
          Row(
            children: const [
              Expanded(
                child: PrimaryActionCard(
                  title: "Find Jobs",
                  subtitle: "Work near you",
                  icon: Icons.work,
                  color: Color(0xFF1B0C6D),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: PrimaryActionCard(
                  title: "Hire Workers",
                  subtitle: "Trusted professionals",
                  icon: Icons.people,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ⚡ Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              QuickAction(icon: Icons.work, label: "Find Jobs"),
              QuickAction(icon: Icons.people, label: "Workers"),
              QuickAction(icon: Icons.bookmark, label: "Saved"),
              QuickAction(icon: Icons.history, label: "Recent"),
            ],
          ),

          const SizedBox(height: 32),

          // 🧩 Categories
          const Text(
            "Popular Categories",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              CategoryTile(icon: Icons.flash_on, label: "Electrician"),
              CategoryTile(icon: Icons.plumbing, label: "Plumber"),
              CategoryTile(icon: Icons.construction, label: "Carpenter"),
              CategoryTile(icon: Icons.local_shipping, label: "Driver"),
              CategoryTile(icon: Icons.build, label: "Technician"),
              CategoryTile(icon: Icons.home_repair_service, label: "Mechanic"),
              CategoryTile(icon: Icons.more_horiz, label: "Others"),
            ],
          ),

          const SizedBox(height: 32),

          // ⭐ Popular Jobs
          const Text(
            "Popular Jobs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const JobCard(
            title: "Electrician Needed",
            subtitle: "Fan & wiring repair",
            icon: Icons.flash_on,
          ),
          const JobCard(
            title: "Plumber Required",
            subtitle: "Bathroom pipe fixing",
            icon: Icons.plumbing,
          ),

          const SizedBox(height: 32),

          // 📍 Nearby Workers
          const Text(
            "Nearby Workers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const WorkerCard(name: "Rahul", skill: "Electrician"),
          const WorkerCard(name: "Suresh", skill: "Plumber"),

          const SizedBox(height: 32),

          // 🕒 Recently Posted
          const Text(
            "Recently Posted Jobs",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const JobCard(
            title: "Temporary Driver",
            subtitle: "3 days local travel",
            icon: Icons.local_shipping,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobsListScreen(category: label)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: label == "Others"
                  ? Colors.grey.shade200
                  : const Color(0xFF1B0C6D).withOpacity(0.1),
              child: Icon(
                icon,
                color: label == "Others"
                    ? Colors.black54
                    : const Color(0xFF1B0C6D),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              "Find now",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickAction({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B0C6D).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1B0C6D)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const JobCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1B0C6D).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF1B0C6D)),
          ),

          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String name;
  final String skill;

  const WorkerCard({super.key, required this.name, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(skill, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const PrimaryActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🔹 PROFILE HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1B0C6D)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 36, color: Color(0xFF1B0C6D)),
            ),
            accountName: const Text(
              "Guest User",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("guest@jobsify.app"),
          ),

          // 🔹 MENU ITEMS
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("My Profile"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help & Support"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Spacer(),
          const Divider(),

          // 🔹 LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

//this is the home screen
