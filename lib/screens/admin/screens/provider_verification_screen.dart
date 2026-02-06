import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../admin_dashboard.dart';
import '../../../models/worker_model.dart';
import '../../../utils/api_endpoints.dart';

const Color kGreen = Color(0xFF16A34A);
const Color kRed = Color(0xFFFF1E2D);

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  late Future<List<Worker>> pendingWorkersFuture;

  @override
  void initState() {
    super.initState();
    pendingWorkersFuture = _fetchPendingWorkers();
  }

  Future<void> _toggleAvailability(int id, bool value) async {
    await http.patch(
      Uri.parse(
        "${ApiEndpoints.baseUrl}/workers/$id/availability?available=$value",
      ),
    );

    setState(() {
      pendingWorkersFuture = _fetchPendingWorkers();
    });
  }

  Future<List<Worker>> _fetchPendingWorkers() async {
    final res = await http.get(Uri.parse(ApiEndpoints.pendingWorkers));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Worker.fromJson(e)).toList();
    }
    throw Exception("Failed to load workers");
  }

  Future<void> _verify(int id) async {
    final res = await http.put(Uri.parse("${ApiEndpoints.approveWorker}/$id"));

    if (res.statusCode == 200) {
      setState(() {
        pendingWorkersFuture = _fetchPendingWorkers();
      });
    } else {
      debugPrint("WORKER APPROVE FAILED: ${res.body}");
    }
  }

  Future<void> _reject(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiEndpoints.deleteWorker}/$id"),
    );

    if (res.statusCode == 200) {
      setState(() {
        pendingWorkersFuture = _fetchPendingWorkers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Verification"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          },
        ),
      ),
      body: FutureBuilder<List<Worker>>(
        future: pendingWorkersFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final workers = snapshot.data!;
          if (workers.isEmpty) {
            return const Center(child: Text("No pending workers 🎉"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: workers.length,
            itemBuilder: (_, i) {
              final w = workers[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${w.role} • ${w.location}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text("📞 ${w.phone}"),
                      Text("🧰 ${w.experience} years experience"),

                      if (w.isVerified) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text("Available"),
                            const SizedBox(width: 8),
                            Switch(
                              value: w.isAvailable,
                              onChanged: (value) =>
                                  _toggleAvailability(w.id, value),
                              activeThumbColor: kGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                              ),
                              onPressed: () => _verify(w.id),
                              child: const Text("Verify"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => _reject(w.id),
                              child: const Text("Reject"),
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
    );
  }
}
