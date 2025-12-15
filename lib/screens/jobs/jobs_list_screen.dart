import 'package:flutter/material.dart';

class JobsListScreen extends StatelessWidget {
  final String category;

  const JobsListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dummyJobs.length,
        itemBuilder: (context, index) {
          final job = dummyJobs[index];
          return JobCard(job: job);
        },
      ),
    );
  }
}

/* ---------------- DUMMY DATA ---------------- */

final List<Map<String, String>> dummyJobs = [
  {
    "title": "Electrician needed",
    "location": "Thiruvananthapuram",
    "description": "Wiring and switch repair work",
    "category": "Electrician",
  },
  {
    "title": "House wiring work",
    "location": "Kollam",
    "description": "Full house electrical setup",
    "category": "Electrician",
  },
  {
    "title": "AC repair technician",
    "location": "Kochi",
    "description": "Split AC service and repair",
    "category": "Electrician",
  },
];

/* ---------------- JOB CARD ---------------- */

class JobCard extends StatelessWidget {
  final Map<String, String> job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job["title"]!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

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

            const SizedBox(height: 8),

            Text(
              job["description"]!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Later: Navigate to Job Detail Screen
                },
                child: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
