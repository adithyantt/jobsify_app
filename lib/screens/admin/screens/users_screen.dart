import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/theme_service.dart';
import '../../../services/user_session.dart';
import '../admin_dashboard.dart';
import '../../../utils/api_endpoints.dart';

const Color kPrimary = Color(0xFF1B0C6D);
const Color kSurface = Color(0xFFF7F7FB);

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<AdminUser>> usersFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    usersFuture = _fetchUsers();
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<AdminUser>> _fetchUsers() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.users),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AdminUser.fromJson(e)).toList();
    }
    throw Exception("Failed to load users");
  }

  Future<void> _blockUser(AdminUser user) async {
    final res = await http.put(
      Uri.parse(ApiEndpoints.blockUser),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": user.id}),
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      if (!mounted) return;
      _reload();
      return;
    }

    if (!mounted) return;
    final message = res.body.isNotEmpty ? res.body : "Unable to block user";
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<AdminUser>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final statusLabel = user.isBlocked ? "Blocked" : "Active";
                final statusColor = user.isBlocked ? Colors.red : Colors.green;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const SizedBox(height: 4),
                        Text(statusLabel, style: TextStyle(color: statusColor)),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(
                        user.isBlocked ? Icons.lock_open : Icons.block,
                        color: user.isBlocked ? Colors.grey : Colors.red,
                      ),
                      onPressed: user.isBlocked ? null : () => _blockUser(user),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isBlocked;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isBlocked,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? 'No email',
      role: json['role'] ?? 'user',
      isBlocked: json['is_blocked'] ?? json['blocked'] ?? false,
    );
  }
}
