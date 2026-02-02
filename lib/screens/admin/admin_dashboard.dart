import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/job_model.dart';

/// 🎨 COLORS (matching user side)
const Color kRed = Color(0xFFFF1E2D);
const Color kGreen = Color(0xFF16A34A);
const Color kDark = Color(0xFF1B0C6D);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // static const String baseUrl = "http://10.137.141.105:8000";
  static const String baseUrl = "http://172.22.39.105:8000";

  late Future<List<Job>> pendingJobsFuture;

  @override
  void initState() {
    super.initState();
    pendingJobsFuture = fetchPendingJobs();
  }

  Future<List<Job>> fetchPendingJobs() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/jobs/pending"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Job.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load pending jobs");
    }
  }

  Future<void> verifyJob(int jobId) async {
    await http.put(Uri.parse("$baseUrl/admin/jobs/verify/$jobId"));
    _reload();
  }

  Future<void> deleteJob(int jobId) async {
    await http.delete(Uri.parse("$baseUrl/admin/jobs/$jobId"));
    _reload();
  }

  void _reload() {
    setState(() {
      pendingJobsFuture = fetchPendingJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔴 APP BAR
      appBar: AppBar(
        backgroundColor: kDark,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Job>>(
          future: pendingJobsFuture,
          builder: (context, snapshot) {
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
              return const Center(
                child: Text(
                  "No pending jobs 🎉",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// 📊 HEADER INFO
                _infoCard(jobs.length),

                const SizedBox(height: 16),

                /// 🧾 JOB LIST
                ...jobs.map(_jobCard).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 📊 INFO CARD
  Widget _infoCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, color: kRed, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pending Jobs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "$count jobs awaiting verification",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🧾 JOB CARD
  Widget _jobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            job.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          /// CATEGORY + LOCATION
          Row(
            children: [
              _tag(job.category),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87),
          ),

          const SizedBox(height: 14),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => verifyJob(job.id),
                  label: const Text("Verify"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => deleteJob(job.id),
                  label: const Text("Reject"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🏷 TAG
  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kRed,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
