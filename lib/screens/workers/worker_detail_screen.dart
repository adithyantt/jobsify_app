import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';

/// 🎨 COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kGreen = Color(0xFF16A34A);
const Color kLightBlue = Color(0xFF87CEEB);

class WorkerDetailScreen extends StatelessWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open dialer")));
    }
  }

  Future<void> _openMap(BuildContext context) async {
    final Uri uri;

    if (worker.latitude != null && worker.longitude != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${worker.latitude},${worker.longitude}",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(worker.location)}",
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open Google Maps")));
    }
  }

  /// 🔴 REPORT MODAL (NEW)
  void _openReportModal(BuildContext context) {
    String selectedReason = "Fraud / Scam";
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Report Worker",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...[
                "Fraud / Scam",
                "Asking advance payment",
                "Fake profile",
                "Bad behavior",
                "Other",
              ].map(
                (reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  selected: selectedReason == reason,
                  onChanged: (value) {
                    if (value != null) {
                      selectedReason = value;
                    }
                  },
                ),
              ),

              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Additional details (optional)",
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () async {
                  await WorkerService.reportWorker(
                    workerId: worker.id,
                    reason: selectedReason,
                    description: descCtrl.text.trim(),
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Report submitted")),
                  );
                },
                child: const Text("Submit Report"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: kLightBlue,
        foregroundColor: Colors.white,
        title: const Text("Worker"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "report") {
                _openReportModal(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "report", child: Text("Report Worker")),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tag(context, worker.role),
                  const SizedBox(height: 12),
                  Text(
                    worker.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    context,
                    Icons.work,
                    "${worker.experience} years experience",
                  ),
                  _infoRow(context, Icons.location_on, worker.location),
                  _infoRow(context, Icons.phone, worker.phone),
                  if (worker.isVerified)
                    _infoRow(
                      context,
                      Icons.verified,
                      "Verified worker",
                      color: Theme.of(context).primaryColor,
                    ),
                  if (worker.latitude != null && worker.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "Precise location available",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
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
                    onPressed: () => _callNumber(context, worker.phone),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text("View Location"),
                    onPressed: () => _openMap(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
