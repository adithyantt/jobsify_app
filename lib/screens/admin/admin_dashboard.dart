import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_drawer.dart';
import '../../utils/api_endpoints.dart';
import '../../services/user_session.dart';
import '../../services/theme_service.dart';
import 'screens/job_verification_screen.dart';
import 'screens/provider_verification_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/users_screen.dart';

const Color kPrimary = Color(0xFF1B0C6D);
const Color kAccent = Color(0xFFFF1E2D);
const Color kSurface = Color(0xFFF7F7FB);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int pendingJobs = 0;
  int providers = 0;
  int users = 0;
  int reports = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // 🔐 Helper method to get auth headers safely
  Map<String, String> _getAuthHeaders() {
    final token = UserSession.token;
    if (token == null || token.isEmpty) {
      throw Exception("Authentication required. Please login.");
    }
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  Future<void> _loadStats() async {
    try {
      final res = await http.get(
        Uri.parse(ApiEndpoints.adminStats),
        headers: _getAuthHeaders(),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          pendingJobs = data['pending_jobs'] ?? 0;
          providers = data['providers'] ?? 0;
          users = data['users'] ?? 0;
          reports = data['reports'] ?? 0;
          isLoadingStats = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      isLoadingStats = false;
    });
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        title: "Pending Jobs",
        value: isLoadingStats ? "..." : pendingJobs.toString(),
        icon: Icons.pending_actions,
        color: kAccent,
        subtitle: "Awaiting review",
      ),
      _StatItem(
        title: "Providers",
        value: isLoadingStats ? "..." : providers.toString(),
        icon: Icons.badge,
        color: const Color(0xFF0EA5E9),
        subtitle: "Verification queue",
      ),
      _StatItem(
        title: "Users",
        value: isLoadingStats ? "..." : users.toString(),
        icon: Icons.people,
        color: const Color(0xFF22C55E),
        subtitle: "Active accounts",
      ),
      _StatItem(
        title: "Reports",
        value: isLoadingStats ? "..." : reports.toString(),
        icon: Icons.report,
        color: const Color(0xFFF59E0B),
        subtitle: "Open tickets",
      ),
    ];

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return Scaffold(
          drawer: const AdminDrawer(),
          appBar: AppBar(
            backgroundColor: isDark
                ? ThemeService.darkTheme.appBarTheme.backgroundColor
                : kPrimary,
            title: const Text("Admin Dashboard"),
            centerTitle: true,
            foregroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                    : [const Color(0xFFF3F4FF), kSurface],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(context, isDark),
                    const SizedBox(height: 20),
                    _sectionTitle(
                      title: "Overview",
                      subtitle: "Key signals at a glance",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = 2;
                        final spacing = 12.0;
                        final cardWidth =
                            (width - (columns - 1) * spacing) / columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final item in stats)
                              SizedBox(
                                width: cardWidth,
                                child: _statCard(item, isDark),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(
                      title: "Quick Actions",
                      subtitle: "Jump into the most used admin tasks",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      title: "Review Pending Jobs",
                      subtitle: "Approve or reject new job posts",
                      icon: Icons.verified,
                      color: kAccent,
                      onTap: () =>
                          _open(context, const JobVerificationScreen()),
                      isDark: isDark,
                    ),
                    _actionCard(
                      title: "Verify Job Providers",
                      subtitle: "Check new provider applications",
                      icon: Icons.badge,
                      color: const Color(0xFF0EA5E9),
                      onTap: () =>
                          _open(context, const ProviderVerificationScreen()),
                      isDark: isDark,
                    ),
                    _actionCard(
                      title: "Review Reports",
                      subtitle: "Handle user complaints and fraud flags",
                      icon: Icons.report,
                      color: const Color(0xFFF59E0B),
                      onTap: () => _open(context, const ReportsScreen()),
                      isDark: isDark,
                    ),
                    _actionCard(
                      title: "Manage Users",
                      subtitle: "Monitor user status and access",
                      icon: Icons.people,
                      color: const Color(0xFF22C55E),
                      onTap: () => _open(context, const UsersScreen()),
                      isDark: isDark,
                    ),
                    _actionCard(
                      title: "Verify Workers",
                      subtitle: "Approve or reject worker registrations",
                      icon: Icons.engineering,
                      color: const Color(0xFF10B981),
                      onTap: () =>
                          _open(context, const ProviderVerificationScreen()),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _heroCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x4D000000) : const Color(0x22000000),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Keep the marketplace clean and trusted with fast reviews.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: kPrimary),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }

  Widget _statCard(_StatItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x4D000000) : const Color(0x14000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x4D000000) : const Color(0x14000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
