import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jobsify/models/job_model.dart';
import '../../../services/theme_service.dart';
import '../admin_dashboard.dart';
import '../../../utils/api_endpoints.dart';
import '../../../services/user_session.dart';

/// 🎨 COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kGreen = Color(0xFF16A34A);

class JobVerificationScreen extends StatefulWidget {
  const JobVerificationScreen({super.key});

  @override
  State<JobVerificationScreen> createState() => _JobVerificationScreenState();
}

class _JobVerificationScreenState extends State<JobVerificationScreen> {
  late Future<List<Job>> pendingJobsFuture;

  @override
  void initState() {
    super.initState();
    _reloadJobs();
  }

  /// 🔄 RELOAD JOBS (SYNC)
  void _reloadJobs() {
    pendingJobsFuture = _fetchPendingJobs();
    if (mounted) setState(() {});
  }

  /// 📡 FETCH PENDING JOBS
  Future<List<Job>> _fetchPendingJobs() async {
    final res = await http.get(
      Uri.parse(ApiEndpoints.pendingJobs),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Job.fromJson(e)).toList();
    }

    throw Exception("Failed to load jobs");
  }

  /// ✅ VERIFY JOB
  Future<void> _verify(int id) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.approveJob}/$id"),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      _reloadJobs();
    } else {
      debugPrint("JOB APPROVE FAILED: ${res.body}");
    }
  }

  /// ❌ REJECT JOB
  Future<void> _reject(int id) async {
    final res = await http.put(
      Uri.parse("${ApiEndpoints.rejectJob}/$id"),
      headers: {
        "Authorization": "Bearer ${UserSession.token}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      _reloadJobs();
    } else {
      debugPrint("JOB REJECT FAILED: ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : Colors.grey.shade100,

          appBar: AppBar(
            title: const Text("Job Verification"),
            backgroundColor: isDark
                ? ThemeService.darkTheme.appBarTheme.backgroundColor
                : kRed,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              },
            ),
          ),

          /// 🔁 PULL TO REFRESH (FIXED)
          body: RefreshIndicator(
            onRefresh: () async {
              _reloadJobs(); // ✅ MUST be async wrapper
            },
            child: FutureBuilder<List<Job>>(
              future: pendingJobsFuture,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      "No pending jobs 🎉",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: jobs.length,
                  itemBuilder: (_, i) {
                    final job = jobs[i];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              job.location,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              job.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kGreen,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () => _verify(job.id),
                                    label: const Text("Verify"),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.close),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () => _reject(job.id),
                                    label: const Text("Reject"),
                                  ),
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
          ),
        );
      },
    );
  }
}
