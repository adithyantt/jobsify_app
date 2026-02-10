import 'package:flutter/material.dart';
import '../../services/user_session.dart';
import '../../services/worker_service.dart';
import '../../services/job_service.dart';
import '../../models/worker_model.dart';
import '../../models/job_model.dart';
import '../settings/settings_screen.dart';
import '../workers/worker_detail_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../workers/add_worker_screen.dart';
import '../jobs/add_job_screen.dart';
import '../../widgets/confirm_dialog.dart';

// 🔹 MY WORKER SCREEN
class MyWorkerScreen extends StatefulWidget {
  const MyWorkerScreen({super.key});

  @override
  State<MyWorkerScreen> createState() => _MyWorkerScreenState();
}

class _MyWorkerScreenState extends State<MyWorkerScreen> {
  List<Worker> myWorkers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMyWorkers();
  }

  Future<void> _loadMyWorkers() async {
    try {
      final email = UserSession.email;
      if (email == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      final data = await WorkerService.fetchMyWorkers(email);
      if (!mounted) return;
      setState(() {
        myWorkers = data;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Worker Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text("Failed to load workers"))
          : myWorkers.isEmpty
          ? const Center(child: Text("No workers posted yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myWorkers.length,
              itemBuilder: (context, index) {
                final worker = myWorkers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              worker.role,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (worker.isVerified)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Verified",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${worker.experience} years experience • ${worker.role}",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 153),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(worker.location),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.work, size: 14, color: Colors.red),
                          const SizedBox(width: 4),
                          Text("${worker.experience} years"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkerDetailScreen(worker: worker),
                                  ),
                                );
                              },
                              child: const Text("View Details"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddWorkerScreen(workerToEdit: worker),
                                ),
                              );
                              if (result == true) {
                                _loadMyWorkers(); // Refresh list
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showConfirmDialog(
                                context: context,
                                title: "Delete Worker",
                                message:
                                    "Are you sure you want to delete this worker profile?",
                                confirmText: "Delete",
                                cancelText: "Cancel",
                              );
                              if (confirm == true) {
                                try {
                                  await WorkerService.deleteWorker(
                                    workerId: worker.id,
                                    userEmail: UserSession.email ?? '',
                                  );
                                  _loadMyWorkers(); // Refresh list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Worker deleted successfully",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Error deleting worker: $e",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 🔹 MY JOBS SCREEN
class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<Job> myJobs = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadMyJobs();
  }

  Future<void> _loadMyJobs() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = "";
    });

    try {
      final email = UserSession.email;
      if (email == null || email.isEmpty) {
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = "Please log in to view your jobs";
        });
        return;
      }

      final data = await JobService.fetchMyJobs(email);
      if (!mounted) return;
      setState(() {
        myJobs = data;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jobs Posted By Me")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load jobs",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadMyJobs,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : myJobs.isEmpty
          ? const Center(child: Text("No jobs posted by you"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myJobs.length,
              itemBuilder: (context, index) {
                final job = myJobs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.category,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (job.verified)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Verified",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        job.description,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 153),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(job.location),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobDetailScreen(job: job),
                                  ),
                                );
                              },
                              child: const Text("View Details"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddJobScreen(jobToEdit: job),
                                ),
                              );
                              if (result == true) {
                                _loadMyJobs(); // Refresh list
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showConfirmDialog(
                                context: context,
                                title: "Delete Job",
                                message:
                                    "Are you sure you want to delete this job posting?",
                                confirmText: "Delete",
                                cancelText: "Cancel",
                              );
                              if (confirm == true) {
                                try {
                                  await JobService.deleteJob(
                                    jobId: job.id,
                                    userEmail: UserSession.email ?? '',
                                  );
                                  _loadMyJobs(); // Refresh list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Job deleted successfully"),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error deleting job: $e"),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = UserSession.role ?? "user";

    return ValueListenableBuilder<String?>(
      valueListenable: UserSession.userNameNotifier,
      builder: (context, nameValue, _) {
        final name = nameValue ?? "User";
        final email = UserSession.email ?? "";

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(title: const Text("My Profile"), centerTitle: true),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withValues(alpha: 179),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role == "admin" ? "Administrator" : "Jobsify User",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 MY ACCOUNT SECTION
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "My Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                _ProfileCard(
                  icon: Icons.badge,
                  title: "I am a Worker",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyWorkerScreen()),
                    );
                  },
                ),

                _ProfileCard(
                  icon: Icons.work,
                  title: "Jobs posted by me",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyJobsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 GENERAL OPTIONS
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "General",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                _ProfileCard(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.history,
                  title: "My Activity",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _ProfileCard(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
                _ProfileCard(
                  icon: Icons.logout,
                  title: "Logout",
                  isLogout: true,
                  onTap: () async {
                    UserSession.clear();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.red : Theme.of(context).primaryColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isLogout
                  ? Colors.red
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
