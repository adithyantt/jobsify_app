import 'package:flutter/material.dart';

import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../utils/salary_utils.dart';
import 'job_detail_screen.dart';

class JobsListScreen extends StatefulWidget {
  final String category;

  const JobsListScreen({super.key, required this.category});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  int? minSalary;
  int? maxSalary;
  late Future<List<Job>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

  Future<List<Job>> _loadJobs() {
    return JobService.fetchJobs(
      category: widget.category == 'All' ? null : widget.category,
      limit: 100,
    );
  }

  List<Job> _applySalaryFilter(List<Job> jobs) {
    if (minSalary == null && maxSalary == null) {
      return jobs;
    }

    return jobs.where((job) {
      return SalaryUtils.isSalaryInRange(job.salary, minSalary, maxSalary);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Text(widget.category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (minSalary != null || maxSalary != null)
                  ? Colors.white
                  : Colors.white70,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Job>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load jobs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _jobsFuture = _loadJobs();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredJobs = _applySalaryFilter(snapshot.data ?? const []);

          if (filteredJobs.isEmpty) {
            return const Center(
              child: Text(
                'no jobs found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredJobs.length,
            itemBuilder: (_, i) => _jobCard(context, filteredJobs[i]),
          );
        },
      ),
    );
  }

  Widget _jobCard(BuildContext context, Job job) {
    final primary = Theme.of(context).primaryColor;
    final salaryText = _salaryLabel(job);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
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
            Row(
              children: [
                _tag(job.category, primary),
                if (job.urgent) _tag('URGENT', Colors.orange),
                if (job.verified) _tag('Verified', Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              job.description,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: primary),
                const SizedBox(width: 4),
                Expanded(child: Text(job.location)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: primary),
                const SizedBox(width: 4),
                Expanded(child: Text(_postedLabel(job))),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                salaryText,
                style: TextStyle(
                  color: salaryText == 'Salary not disclosed'
                      ? Colors.grey
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                  );
                },
                child: const Text('View Contact'),
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

  void _showFilterDialog() {
    final minCtrl = TextEditingController(text: minSalary?.toString());
    final maxCtrl = TextEditingController(text: maxSalary?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Salary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Salary',
                hintText: 'e.g., 500',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maximum Salary',
                hintText: 'e.g., 2000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final min = int.tryParse(minCtrl.text.trim());
              final max = int.tryParse(maxCtrl.text.trim());
              setState(() {
                minSalary = min;
                maxSalary = max;
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _salaryLabel(Job job) {
    final salary = job.salary?.trim();
    if (salary == null || salary.isEmpty) {
      return 'Salary not disclosed';
    }
    return salary;
  }

  String _postedLabel(Job job) {
    final createdAt = job.createdAt?.trim();
    if (createdAt == null || createdAt.isEmpty) {
      return 'Recently posted';
    }

    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return 'Posted: $createdAt';
    }

    final date = parsed.toLocal();
    return 'Posted: ${date.day}/${date.month}/${date.year}';
  }
}
