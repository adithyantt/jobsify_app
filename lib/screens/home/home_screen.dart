import 'package:flutter/material.dart';
import '../jobs/jobs_list_screen.dart';
import '../profile/profile_screen.dart';
import '../jobs/find_job_screen.dart';
import '../workers/find_workers_screen.dart';
import '../jobs/jobs_home_screen.dart';
import '../jobs/post_job_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/user_session.dart';

/// 🎨 PROFESSIONAL COLORS (UI ONLY)
const Color kRed = Color(0xFF1E40AF);
const Color kBlue = Color(0xFF6B7280);
const Color kGreen = Color(0xFF10B981);
const Color kYellow = Color(0xFFD1D5DB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  /// 🔒 BACKEND SCREENS – UNCHANGED
  final List<Widget> _pages = const [
    HomeContent(),
    JobsHomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// ✅ REQUIRED FOR HAMBURGER MENU
      drawer: const AppDrawer(),

      body: _pages[_selectedIndex],

      /// ✅ BOTTOM NAV (UNCHANGED LOGIC)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: "Jobs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🏠 HOME CONTENT
/// =======================
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> categories = const [
    {"name": "Plumber", "icon": Icons.plumbing, "color": Colors.blue},
    {"name": "Painter", "icon": Icons.format_paint, "color": Colors.purple},
    {"name": "Driver", "icon": Icons.local_shipping, "color": Colors.green},
    {"name": "Electrician", "icon": Icons.flash_on, "color": Colors.orange},
    {"name": "Carpenter", "icon": Icons.handyman, "color": Colors.deepOrange},
    {"name": "Mason", "icon": Icons.construction, "color": Colors.red},
    {"name": "Cleaner", "icon": Icons.auto_awesome, "color": Colors.pink},
    {"name": "Gardener", "icon": Icons.grass, "color": Colors.greenAccent},
    {"name": "Cook", "icon": Icons.restaurant, "color": Colors.brown},
    {"name": "Security Guard", "icon": Icons.security, "color": Colors.grey},
    {"name": "Mechanic", "icon": Icons.build, "color": Colors.black},
    {"name": "Other", "icon": Icons.more_horiz, "color": Colors.indigo},
  ];

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: CustomScrollView(
        slivers: [
          /// 🔴 HEADER (☰ + LOCATION + SEARCH)
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) => Container(
                color: kRed,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            _searchFocusNode.unfocus();
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        const Text(
                          "Jobsify",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const Text(
                      "Connect. Work. Grow.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),

                    const SizedBox(height: 12),

                    /// 📍 LOCATION
                    GestureDetector(
                      onTap: () {
                        _searchFocusNode.unfocus();
                        _showLocationBottomSheet(context);
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text("Delhi", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 🔍 SEARCH
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kYellow, width: 2),
                      ),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Search for services or workers...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔵 CTA CARDS
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ctaCards = [
                  {
                    "color": kBlue,
                    "title": "Browse Jobs",
                    "subtitle": "Find available work",
                    "icon": Icons.work_outline,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindJobsScreen()),
                      );
                    },
                  },
                  {
                    "color": kGreen,
                    "title": "Find Workers",
                    "subtitle": "Hire skilled workers",
                    "icon": Icons.people_outline,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindWorkersScreen()),
                      );
                    },
                  },
                  {
                    "color": Colors.orange,
                    "title": "Post a Job",
                    "subtitle": "Create job listings",
                    "icon": Icons.add_circle_outline,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      );
                    },
                  },
                  {
                    "color": Colors.purple,
                    "title": "Plumber",
                    "subtitle": "Find plumbing services",
                    "icon": Icons.plumbing,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobsListScreen(category: "Plumber"),
                        ),
                      );
                    },
                  },
                  {
                    "color": Colors.red,
                    "title": "Electrician",
                    "subtitle": "Electrical work",
                    "icon": Icons.flash_on,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JobsListScreen(category: "Electrician"),
                        ),
                      );
                    },
                  },
                  {
                    "color": Colors.brown,
                    "title": "Carpenter",
                    "subtitle": "Woodwork & repairs",
                    "icon": Icons.handyman,
                    "onTap": () {
                      _searchFocusNode.unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobsListScreen(category: "Carpenter"),
                        ),
                      );
                    },
                  },
                ];
                final card = ctaCards[index];
                return _ctaCard(
                  color: card["color"] as Color,
                  title: card["title"] as String,
                  subtitle: card["subtitle"] as String,
                  icon: card["icon"] as IconData,
                  onTap: card["onTap"] as VoidCallback,
                );
              }, childCount: 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
            ),
          ),

          /// 🧩 CATEGORIES
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = categories[index];
                return InkWell(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobsListScreen(category: c["name"]),
                      ),
                    );
                  },
                  child: Container(
                    decoration: _cardDecoration(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: c["color"],
                          child: Icon(c["icon"], color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(c["name"]),
                        const Text(
                          "Find Now",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: categories.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📍 LOCATION BOTTOM SHEET
  void _showLocationBottomSheet(BuildContext context) {
    final cities = [
      "Delhi",
      "Bangalore",
      "Hyderabad",
      "Chennai",
      "Kolkata",
      "Pune",
      "Ahmedabad",
      "Jaipur",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Location",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search city...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(cities[i]),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaCard({
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// 📂 DRAWER (UNCHANGED LOGIC)
/// =======================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kRed),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: kRed),
            ),
            accountName: ValueListenableBuilder<String?>(
              valueListenable: UserSession.userNameNotifier,
              builder: (_, name, __) => Text(name ?? "User"),
            ),
            accountEmail: ValueListenableBuilder<String?>(
              valueListenable: UserSession.emailNotifier,
              builder: (_, email, __) => Text(email ?? ""),
            ),
          ),

          _drawerItem(context, Icons.home_outlined, "Home"),
          _drawerItem(context, Icons.work_outline, "Jobs"),
          _drawerItem(
            context,
            Icons.person_outline,
            "Profile",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _drawerItem(context, Icons.bookmark_border, "Saved Items"),
          _drawerItem(context, Icons.notifications_none, "Notifications"),
          _drawerItem(
            context,
            Icons.settings_outlined,
            "Settings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _drawerItem(context, Icons.help_outline, "Help & Support"),

          const Spacer(),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade300,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
              if (confirmed == true) {
                UserSession.clear();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
  );
}
