import 'package:flutter/material.dart';
import 'job_detail_screen.dart';

class JobsListScreen extends StatelessWidget {
  final String category;

  const JobsListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // later: filters
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              "${dummyJobs.length} jobs available",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),

          // Job list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dummyJobs.length,
              itemBuilder: (context, index) {
                return JobCard(job: dummyJobs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- DUMMY DATA ---------------- */

final List<Map<String, String>> dummyJobs = [
  {
    "title": "Electrician needed for house wiring",
    "location": "Thiruvananthapuram",
    "description":
        "Complete wiring work for a 2BHK house. Immediate requirement.",
    "category": "Electrician",
  },
  {
    "title": "AC service & repair technician",
    "location": "Kochi",
    "description": "Split AC servicing and gas refill required.",
    "category": "Electrician",
  },
  {
    "title": "Office electrical maintenance",
    "location": "Kollam",
    "description": "Routine electrical maintenance for small office setup.",
    "category": "Electrician",
  },
];

/* ---------------- JOB CARD ---------------- */

class JobCard extends StatelessWidget {
  final Map<String, String> job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title
          Text(
            job["title"]!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              job["category"]!,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),

          const SizedBox(height: 10),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                job["location"]!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            job["description"]!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          // Action button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                );
              },

              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("View Details"),
            ),
          ),
        ],
      ),
    );
  }
}
