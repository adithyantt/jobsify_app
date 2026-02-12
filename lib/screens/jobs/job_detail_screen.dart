import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/user_session.dart';

/// UI COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kGreen = Color(0xFF16A34A);

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final email = UserSession.email;
    if (email == null) return;

    try {
      final isSaved = await JobService.checkJobSaved(
        jobId: widget.job.id,
        userEmail: email,
      );
      setState(() {
        _isSaved = isSaved;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

    final email = UserSession.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to save jobs")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        await JobService.unsaveJob(jobId: widget.job.id, userEmail: email);
        setState(() {
          _isSaved = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Job removed from saved items")),
          );
        }
      } else {
        await JobService.saveJob(userEmail: email, jobId: widget.job.id);
        setState(() {
          _isSaved = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Job saved successfully")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save job: $e")));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 📞 OPEN DIALER
  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri.parse("tel:$phone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open dialer")));
    }
  }

  /// 📍 OPEN GOOGLE MAPS
  Future<void> _openMap(BuildContext context) async {
    final Uri uri;

    if (widget.job.latitude != null && widget.job.longitude != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.job.latitude},${widget.job.longitude}",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.job.location)}",
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    "Report Job",
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
                      groupValue: selectedReason,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedReason = value;
                          });
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await JobService.reportJob(
                        jobId: widget.job.id,
                        reason: selectedReason,
                        description: descCtrl.text.trim(),
                        reporterEmail: UserSession.email ?? '',
                      );

                      if (!context.mounted) return;
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// 🔴 APP BAR
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        title: const Text("Job Details"),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? Colors.amber : Colors.white,
                  ),
            onPressed: _toggleSave,
            tooltip: _isSaved ? "Remove from saved" : "Save job",
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "report") {
                _openReportModal(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "report", child: Text("Report Job")),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          /// 🔹 CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tag(widget.job.category),

                  const SizedBox(height: 12),

                  Text(
                    widget.job.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.job.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _infoRow(Icons.location_on, widget.job.location),

                  if (widget.job.latitude != null &&
                      widget.job.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "📌 Precise location available",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  _infoRow(Icons.access_time, "Recently posted"),
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0x4D000000)
                      : Colors.black12,
                  blurRadius: 8,
                ),
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
                    onPressed: () => _callNumber(context, widget.job.phone),
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
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kRed.withValues(alpha: 0.1),
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
