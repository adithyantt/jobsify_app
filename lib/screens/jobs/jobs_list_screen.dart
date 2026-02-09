import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import 'job_detail_screen.dart';

/// COLORS (UI ONLY)
const Color kRed = Color(0xFFFF1E2D);

class JobsListScreen extends StatelessWidget {
  final String category;

  const JobsListScreen({super.key, required this.category});

  /// 🔹 BACKEND-SAFE FALLBACK JOBS
  List<Map<String, dynamic>> get jobs => [
    {
      "category": "Plumber",
      "title": "Need Plumber for Kitchen Repair",
      "desc": "Kitchen sink and pipe repair needed urgently.",
      "location": "Sector 15, Delhi",
      "time": "Posted 2 hours ago",
      "salary": "₹800-1000/day",
      "urgent": true,
      "verified": true,
      "phone": "+91 98765 43210",
    },
    {
      "category": "Painter",
      "title": "House Painting Work",
      "desc": "3 BHK apartment painting work required.",
      "location": "Green Park, Mumbai",
      "time": "Posted 5 hours ago",
      "salary": "₹15,000 (complete work)",
      "urgent": false,
      "verified": true,
      "phone": "+91 99887 66554",
    },
  ];

  List<Map<String, dynamic>> get filteredJobs {
    if (category == "All") return jobs;
    return jobs.where((j) => j["category"] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔴 APP BAR (SIMPLE & CLEAN)
      appBar: AppBar(
        backgroundColor: kRed,
        elevation: 0,
        title: Text(category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: filteredJobs.isEmpty
          ? const Center(
              child: Text(
                "No jobs found",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredJobs.length,
              itemBuilder: (_, i) {
                final job = filteredJobs[i];
                return _jobCard(context, job);
              },
            ),
    );
  }

  /// 🧾 JOB CARD (MATCHES BROWSE JOBS)
  Widget _jobCard(BuildContext context, Map<String, dynamic> job) {
    final jobObj = Job.fromJson(job);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailScreen(job: jobObj)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TAGS
            Row(
              children: [
                _tag(job["category"], kRed),
                if (job["urgent"]) _tag("URGENT", Colors.orange),
                if (job["verified"]) _tag("Verified", Colors.green),
              ],
            ),

            const SizedBox(height: 8),

            /// TITLE
            Text(
              job["title"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),

            const SizedBox(height: 6),

            /// DESCRIPTION
            Text(
              job["desc"],
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 153),
              ),
            ),

            const SizedBox(height: 8),

            /// LOCATION
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(job["location"]),
              ],
            ),

            const SizedBox(height: 4),

            /// TIME
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(job["time"]),
              ],
            ),

            const SizedBox(height: 10),

            /// SALARY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job["salary"],
                style: const TextStyle(color: Colors.green),
              ),
            ),

            const SizedBox(height: 12),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kRed),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: jobObj),
                    ),
                  );
                },
                child: const Text("View Contact"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
