import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../admin_dashboard.dart';
import '../../../utils/api_endpoints.dart';
import '../../../services/user_session.dart';

const Color kPrimary = Color(0xFF1B0C6D);
const Color kSurface = Color(0xFFF7F7FB);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<dynamic>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = _fetchReports();
  }

  Future<List<dynamic>> _fetchReports() async {
    final res = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/admin/reports/pending"),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception("Failed to load reports");
  }

  Future<void> _takeAction(int reportId, String action) async {
    await http.put(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/admin/reports/$reportId/action?action=$action",
      ),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );

    setState(() {
      reportsFuture = _fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: reportsFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(child: Text("No pending reports 🎉"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (_, i) {
              final r = reports[i];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Worker ID: ${r['worker_id']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Reason: ${r['reason']}"),
                      if (r['description'] != null &&
                          r['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            r['description'],
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _takeAction(r['id'], "ignore"),
                            child: const Text("Ignore"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _takeAction(r['id'], "warn"),
                            child: const Text("Warn"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => _takeAction(r['id'], "ban"),
                            child: const Text("Ban"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
