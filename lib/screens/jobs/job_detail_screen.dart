import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/user_session.dart';
import '../../utils/offline_handler.dart';
import '../../services/messaging_service.dart';
import '../messages/message_chat_screen.dart';

const Color kPrimary = Color(0xFF4F46E5);
const Color kGreen = Color(0xFF22C55E);
const Color kOrange = Color(0xFFF59E0B);
const Color kYellow = Color(0xFFFFC107);
const Color kDark = Color(0xFF1E293B);
const Color kGray = Color(0xFF94A3B8);
const Color kLight = Color(0xFFF1F5F9);
const Color kWhite = Color(0xFFFFFFFF);
const Color kBlue = Color(0xFF3B82F6);

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isSaved = false;
  bool _isLoading = false;
  bool _isMessaging = false;
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
      OfflineHandler.showErrorSnackBar(
        context,
        Exception("Please login to save jobs"),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isSaved) {
        await JobService.unsaveJob(jobId: _currentJob.id, userEmail: email);
        setState(() => _isSaved = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Job removed"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await JobService.saveJob(userEmail: email, jobId: _currentJob.id);
        setState(() => _isSaved = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Job saved"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _isJobOwner {
    final userPhone = UserSession.phone;
    final userEmail = UserSession.email;
    final isPhoneMatch =
        userPhone != null &&
        userPhone.isNotEmpty &&
        userPhone == _currentJob.phone;
    final isEmailMatch =
        userEmail != null && userEmail == _currentJob.userEmail;
    return isPhoneMatch || isEmailMatch;
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
          userEmail: _currentJob.userEmail,
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job hidden")));
      }
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
          userEmail: _currentJob.userEmail,
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

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Job visible")));
      }
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
                    userEmail: _currentJob.userEmail,
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
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Updated")));
                }
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
            "https://www.google.com/maps/search/?api=1&query=${_currentJob.latitude ?? ''},${_currentJob.longitude ?? ''}",
          )
        : Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_currentJob.location)}",
          );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMessageScreen() async {
    if (!UserSession.isLoggedIn) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('Please login to apply for this job'),
      );
      return;
    }

    final employerEmail = _currentJob.userEmail;
    if (employerEmail == null || employerEmail.isEmpty) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('Cannot contact employer at this time'),
      );
      return;
    }

    setState(() => _isMessaging = true);
    try {
      final conversation = await MessagingService.createOrGetConversation(
        senderEmail: UserSession.email!,
        recipientEmail: employerEmail,
        initialMessage:
            "Hi, I'm interested in your job post: ${_currentJob.title}",
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessageChatScreen(
            conversationId: conversation.id,
            initialTitle: _currentJob.title,
          ),
        ),
      );
    } catch (e) {
      if (mounted) OfflineHandler.showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _isMessaging = false);
    }
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
                    if (!mounted) return;
                    if (ctx.mounted) Navigator.pop(ctx);
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

  String _getTimeAgo(dynamic createdAt) {
    DateTime? dateTime;
    if (createdAt is String) {
      dateTime = DateTime.tryParse(createdAt);
    } else if (createdAt is DateTime) {
      dateTime = createdAt;
    }

    if (dateTime == null) return 'Just now';
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}m ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : kWhite;
    final textColor = isDark ? kWhite : kDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: true,
            backgroundColor: kPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved ? kYellow : Colors.white,
                        ),
                ),
                onPressed: _toggleSave,
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
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
                  const PopupMenuItem(
                    value: "report",
                    child: Text("Report Job"),
                  ),
                  if (_isJobOwner) ...[
                    const PopupMenuDivider(),
                    if (_currentJob.isHidden)
                      const PopupMenuItem(
                        value: "show",
                        child: Text("Show Job"),
                      ),
                    if (!_currentJob.isHidden)
                      const PopupMenuItem(
                        value: "hide",
                        child: Text("Hide Job"),
                      ),
                    const PopupMenuItem(
                      value: "update",
                      child: Text("Update Required Workers"),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                      ),
                    ),
                  ),
                  // Decorative Pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.work_outline_rounded,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            _chip(_currentJob.category, Colors.white, isDark),
                            if (_currentJob.urgent)
                              _chip("Urgent", kOrange, isDark),
                            if (_currentJob.verified)
                              _chip("Verified", kGreen, isDark),
                            if (_currentJob.isHidden)
                              _chip("Hidden", Colors.grey, isDark),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentJob.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentJob.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Salary / Pay",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : kGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentJob.salary ?? "Negotiable",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _detailItem(
                          isDark,
                          icon: Icons.people_outline,
                          label: "Required",
                          value: "${_currentJob.requiredWorkers}",
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _detailItem(
                          isDark,
                          icon: Icons.access_time,
                          label: "Posted",
                          value: _getTimeAgo(
                            _currentJob.createdAt,
                          ).replaceAll(" ago", ""),
                          color: kBlue,
                        ),
                      ),
                      if (_currentJob.urgent) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _detailItem(
                            isDark,
                            icon: Icons.flash_on,
                            label: "Urgency",
                            value: "High",
                            color: kOrange,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    "About this Job",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _currentJob.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: _isJobOwner
                ? _buildOwnerActions()
                : _buildSeekerActions(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOwnerActions() {
    return [
      Expanded(
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Manage Job"),
            onPressed: _updateRequiredWorkers, // Shortcut to update logic
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSeekerActions() {
    return [
      if (_currentJob.userEmail != null &&
          _currentJob.userEmail != UserSession.email) ...[
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
              icon: _isMessaging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              label: const Text("Message"),
              onPressed: _isMessaging ? null : _openMessageScreen,
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimary,
              side: const BorderSide(color: kPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.location_on, size: 20),
            label: const Text("Map"),
            onPressed: () => _openMap(context),
          ),
        ),
      ),
      if (_currentJob.phone.isNotEmpty) ...[
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.call, size: 20),
              label: const Text("Call"),
              onPressed: () => _callNumber(context, _currentJob.phone),
            ),
          ),
        ),
      ],
    ];
  }

  Widget _chip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _detailItem(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    Color color = kPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? kWhite : kDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: kGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
