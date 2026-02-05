import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_drawer.dart';
import '../../utils/api_endpoints.dart';
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
  bool isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final res = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/admin/jobs/pending"),
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          pendingJobs = data.length;
          isLoadingCounts = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      isLoadingCounts = false;
    });
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        title: "Pending Jobs",
        value: isLoadingCounts ? "..." : pendingJobs.toString(),
        icon: Icons.pending_actions,
        color: kAccent,
        subtitle: "Awaiting review",
      ),
      _StatItem(
        title: "Providers",
        value: "--",
        icon: Icons.badge,
        color: const Color(0xFF0EA5E9),
        subtitle: "Verification queue",
      ),
      _StatItem(
        title: "Users",
        value: "--",
        icon: Icons.people,
        color: const Color(0xFF22C55E),
        subtitle: "Active accounts",
      ),
      _StatItem(
        title: "Reports",
        value: "--",
        icon: Icons.report,
        color: const Color(0xFFF59E0B),
        subtitle: "Open tickets",
      ),
    ];

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3F4FF), kSurface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCard(context),
                const SizedBox(height: 20),
                _sectionTitle(
                  title: "Overview",
                  subtitle: "Key signals at a glance",
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 900
                        ? 4
                        : width >= 650
                        ? 3
                        : width >= 420
                        ? 2
                        : 1;
                    final spacing = 12.0;
                    final cardWidth =
                        (width - (columns - 1) * spacing) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final item in stats)
                          SizedBox(width: cardWidth, child: _statCard(item)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _sectionTitle(
                  title: "Quick Actions",
                  subtitle: "Jump into the most used admin tasks",
                ),
                const SizedBox(height: 12),
                _actionCard(
                  title: "Review Pending Jobs",
                  subtitle: "Approve or reject new job posts",
                  icon: Icons.verified,
                  color: kAccent,
                  onTap: () => _open(context, const JobVerificationScreen()),
                ),
                _actionCard(
                  title: "Verify Job Providers",
                  subtitle: "Check new provider applications",
                  icon: Icons.badge,
                  color: const Color(0xFF0EA5E9),
                  onTap: () =>
                      _open(context, const ProviderVerificationScreen()),
                ),
                _actionCard(
                  title: "Review Reports",
                  subtitle: "Handle user complaints and fraud flags",
                  icon: Icons.report,
                  color: const Color(0xFFF59E0B),
                  onTap: () => _open(context, const ReportsScreen()),
                ),
                _actionCard(
                  title: "Manage Users",
                  subtitle: "Monitor user status and access",
                  icon: Icons.people,
                  color: const Color(0xFF22C55E),
                  onTap: () => _open(context, const UsersScreen()),
                ),
                _actionCard(
                  title: "Verify Workers",
                  subtitle: "Approve or reject worker registrations",
                  icon: Icons.engineering,
                  color: const Color(0xFF10B981),
                  onTap: () =>
                      _open(context, const ProviderVerificationScreen()),
                ),

                const SizedBox(height: 20),
                _sectionTitle(
                  title: "Work Queue",
                  subtitle: "Focused tasks to keep the platform healthy",
                ),
                const SizedBox(height: 12),
                _queueCard(
                  context,
                  title: "Pending Jobs",
                  description: "Review job posts before they go live to users.",
                  buttonText: "Open Verification",
                  onTap: () => _open(context, const JobVerificationScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome back",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Keep the marketplace clean and trusted with fast reviews.",
                  style: TextStyle(color: Colors.black54),
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

  Widget _sectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _statCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(item.title, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 4),
          Text(item.subtitle, style: const TextStyle(color: Colors.black54)),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _queueCard(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment, color: kAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onTap,
            child: Text(buttonText),
          ),
        ],
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
