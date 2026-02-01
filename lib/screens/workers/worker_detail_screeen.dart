import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  static const Color primaryColor = Color(0xFF1B0C6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Worker Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [_profileCard(), const SizedBox(height: 20), _infoCard()],
        ),
      ),

      bottomNavigationBar: _actionBar(context),
    );
  }

  /// 👤 PROFILE
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: primaryColor,
            child: Text(
              worker.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            worker.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(worker.role, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text("${worker.rating} (${worker.reviews} reviews)"),
            ],
          ),
        ],
      ),
    );
  }

  /// 📋 DETAILS
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(Icons.work, "${worker.experience} years experience"),
          _row(Icons.location_on, worker.location),
          _row(Icons.phone, worker.phone),
          if (worker.isVerified)
            _row(Icons.verified, "Verified Worker", color: Colors.green),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  /// 🔥 ACTION BAR
  Widget _actionBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.call),
                label: const Text("Call"),
                onPressed: () => _callWorker(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.map),
                label: const Text("Map"),
                onPressed: () => _openMap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📞 CALL
  Future<void> _callWorker() async {
    final uri = Uri.parse("tel:${worker.phone}");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open dialer");
    }
  }

  /// 📍 MAP
  Future<void> _openMap() async {
    final query = Uri.encodeComponent(worker.location);
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open map");
    }
  }
}
