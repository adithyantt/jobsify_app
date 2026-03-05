import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/user_session.dart';

const Color kPrimary = Color(0xFF4F46E5);
const Color kGreen = Color(0xFF22C55E);
const Color kOrange = Color(0xFFF59E0B);
const Color kDark = Color(0xFF1E293B);
const Color kGray = Color(0xFF64748B);
const Color kLight = Color(0xFFF1F5F9);
const Color kWhite = Color(0xFFFFFFFF);

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isSaved = false;
  bool _isLoading = false;
  late Job _currentJob;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.job;
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final email = UserSession.email;
    if (email == null) return;
    try {
      final isSaved = await JobService.checkJobSaved(
        jobId: _currentJob.id,
        userEmail: email,
      );
      setState(() => _isSaved = isSaved);
    } catch (e) {}
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
    setState(() => _isLoading = true);
    try {
      if (_isSaved) {
        await JobService.unsaveJob(jobId: _currentJob.id, userEmail: email);
        setState(() => _isSaved = false);
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Job removed")));
      } else {
        await JobService.saveJob(userEmail: email, jobId: _currentJob.id);
        setState(() => _isSaved = true);
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Job saved")));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _isJobOwner {
    final userPhone = UserSession.phone;
    return userPhone != null &&
        userPhone.isNotEmpty &&
        userPhone == _currentJob.phone;
  }

  Future<void> _hideJob() async {
    final email = UserSession.email;
    if (email == null) return;
    setState(() => _isLoading = true);
    try {
      await JobService.hideJob(jobId: _currentJob.id, userEmail: email);
      setState(
        () => _currentJob = Job(
          id: _currentJob.id,
          title: _currentJob.title,
          category: _currentJob.category,
          description: _currentJob.description,
          location: _currentJob.location,
          phone: _currentJob.phone,
          latitude: _currentJob.latitude,
          longitude: _currentJob.longitude,
          verified: _currentJob.verified,
          urgent: _currentJob.urgent,
          salary: _currentJob.salary,
          createdAt: _currentJob.createdAt,
          isSaved: _currentJob.isSaved,
          requiredWorkers: _currentJob.requiredWorkers,
          hiredCount: _currentJob.hiredCount,
          isHidden: true,
          vacancies: _currentJob.vacancies,
        ),
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job hidden")));
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showJob() async {
    final email = UserSession.email;
    if (email == null) return;
    setState(() => _isLoading = true);
    try {
      await JobService.showJob(jobId: _currentJob.id, userEmail: email);
      setState(
        () => _currentJob = Job(
          id: _currentJob.id,
          title: _currentJob.title,
          category: _currentJob.category,
          description: _currentJob.description,
          location: _currentJob.location,
          phone: _currentJob.phone,
          latitude: _currentJob.latitude,
          longitude: _currentJob.longitude,
          verified: _currentJob.verified,
          urgent: _currentJob.urgent,
          salary: _currentJob.salary,
          createdAt: _currentJob.createdAt,
          isSaved: _currentJob.isSaved,
          requiredWorkers: _currentJob.requiredWorkers,
          hiredCount: _currentJob.hiredCount,
          isHidden: false,
          vacancies: _currentJob.vacancies,
        ),
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job visible")));
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRequiredWorkers() async {
    final email = UserSession.email;
    if (email == null) return;
    final controller = TextEditingController(
      text: _currentJob.requiredWorkers.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Workers"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Required workers"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(controller.text);
              if (count == null || count < 1) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final result = await JobService.updateRequiredWorkers(
                  jobId: _currentJob.id,
                  userEmail: email,
                  requiredWorkers: count,
                );
                setState(() {
                  final updated = (result['required_workers'] as int?) ?? count;
                  final vac =
                      (result['vacancies'] as int?) ??
                      (updated - _currentJob.hiredCount);
                  _currentJob = Job(
                    id: _currentJob.id,
                    title: _currentJob.title,
                    category: _currentJob.category,
                    description: _currentJob.description,
                    location: _currentJob.location,
                    phone: _currentJob.phone,
                    latitude: _currentJob.latitude,
                    longitude: _currentJob.longitude,
                    verified: _currentJob.verified,
                    urgent: _currentJob.urgent,
                    salary: _currentJob.salary,
                    createdAt: _currentJob.createdAt,
                    isSaved: _currentJob.isSaved,
                    requiredWorkers: updated,
                    hiredCount: _currentJob.hiredCount,
                    isHidden: _currentJob.isHidden,
                    vacancies: vac,
                  );
                });
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Updated")));
              } catch (e) {
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(BuildContext context, String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMap(BuildContext context) async {
    final uri = (_currentJob.latitude != null && _currentJob.longitude != null)
        ? Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${_currentJob.latitude},${_currentJob.longitude}",
          )
        : Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_currentJob.location)}",
          );
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openReportModal(BuildContext context) {
    String reason = "Fraud / Scam";
    final desc = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Report Job",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[
                "Fraud / Scam",
                "Asking advance payment",
                "Fake profile",
                "Bad behavior",
                "Other",
              ].map(
                (r) => RadioListTile<String>(
                  title: Text(r),
                  value: r,
                  groupValue: reason,
                  onChanged: (v) {
                    if (v != null) setState(() => reason = v);
                  },
                ),
              ),
              TextField(
                controller: desc,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Details (optional)",
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await JobService.reportJob(
                      jobId: _currentJob.id,
                      reason: reason,
                      description: desc.text.trim(),
                      reporterEmail: UserSession.email ?? '',
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Report submitted")),
                    );
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : kLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        title: const Text("Job Details"),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(kWhite),
                    ),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? Colors.amber : kWhite,
                  ),
            onPressed: _toggleSave,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == "report") {
                _openReportModal(context);
              } else if (v == "hide") {
                _hideJob();
              } else if (v == "show") {
                _showJob();
              } else if (v == "update") {
                _updateRequiredWorkers();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: "report", child: Text("Report Job")),
              if (_isJobOwner) ...[
                const PopupMenuDivider(),
                if (_currentJob.isHidden)
                  const PopupMenuItem(value: "show", child: Text("Show Job")),
                if (!_currentJob.isHidden)
                  const PopupMenuItem(value: "hide", child: Text("Hide Job")),
                const PopupMenuItem(
                  value: "update",
                  child: Text("Update Required Workers"),
                ),
              ],
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                _chip(_currentJob.category, kPrimary),
                if (_currentJob.urgent) _chip("Urgent", kOrange),
                if (_currentJob.verified) _chip("Verified", kGreen),
                if (_currentJob.isHidden) _chip("Hidden", Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentJob.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? kWhite : kDark,
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.location_on, _currentJob.location, kPrimary, isDark),
            if (_currentJob.latitude != null)
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 4),
                child: Text(
                  "Precise location",
                  style: TextStyle(fontSize: 12, color: kGray),
                ),
              ),
            if (_currentJob.salary != null &&
                _currentJob.salary!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.currency_rupee,
                _currentJob.salary!,
                kGreen,
                isDark,
              ),
            ],
            const SizedBox(height: 8),
            _infoRow(Icons.access_time, "Recently posted", kGray, isDark),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    "Required: ",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[300] : kGray,
                    ),
                  ),
                  Text(
                    _currentJob.requiredWorkers.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                  Text(
                    "  (${_currentJob.requiredWorkers == 1 ? 'person' : 'persons'})",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : kGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? kWhite : kDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentJob.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : kGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : kWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: kGreen),
                  const SizedBox(width: 12),
                  Text(
                    _currentJob.phone,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? kWhite : kDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : kWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: BorderSide(color: kPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.location_on, size: 20),
                    label: const Text("Location"),
                    onPressed: () => _openMap(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text("Call Now"),
                    onPressed: () => _callNumber(context, _currentJob.phone),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );

  Widget _infoRow(IconData icon, String text, Color color, bool isDark) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : kGray,
          ),
        ),
      ),
    ],
  );
}
