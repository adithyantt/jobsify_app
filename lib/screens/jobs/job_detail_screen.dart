import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_model.dart';

/// UI COLORS
const Color kRed = Color(0xFFFF1E2D);

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  /// 📞 OPEN DIALER
  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri.parse("tel:$phone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open dialer")));
    }
  }

  /// 📍 OPEN GOOGLE MAPS
  Future<void> _openMap(BuildContext context) async {
    final Uri uri;

    if (job.latitude != null && job.longitude != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${job.latitude},${job.longitude}",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(job.location)}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔴 APP BAR
      appBar: AppBar(backgroundColor: kRed, title: const Text("Job Details")),

      body: Column(
        children: [
          /// 🔹 CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tag(job.category),

                  const SizedBox(height: 12),

                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    job.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _infoRow(Icons.location_on, job.location),

                  if (job.latitude != null && job.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "📌 Precise location available",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  _infoRow(
                    Icons.access_time,
                    job.createdAt ?? "Recently posted",
                  ),
                ],
              ),
            ),
          ),

          /// 🔻 BOTTOM ACTION BAR (WITH MARGIN)
          Container(
            margin: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ), // 👈 bottom margin
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                /// 📞 CALL
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
                    onPressed: () => _callNumber(context, job.phone),
                  ),
                ),

                const SizedBox(width: 12),

                /// 📍 MAP
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kRed),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }

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
