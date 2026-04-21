import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';
import '../../models/review_model.dart';
import '../../services/worker_service.dart';
import '../../services/review_service.dart';
import '../../services/user_session.dart';
import '../../services/messaging_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/add_review_dialog.dart';
import '../messages/message_chat_screen.dart';
import '../../../utils/offline_handler.dart';

/// 🎨 COLORS
const Color kPrimary = Color(0xFF4F46E5);
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kYellowDark = Color(0xFFB45309);
const Color kGreen = Color(0xFF16A34A);
const Color kOrange = Color(0xFFF97316);
const Color kDark = Color(0xFF1E293B);
const Color kGray = Color(0xFF64748B);
const Color kLight = Color(0xFFF1F5F9);
const Color kWhite = Color(0xFFFFFFFF);
const Color kSurface = Color(0xFFF8FAFC);

class WorkerRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  WorkerRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  Worker? _worker;
  List<Review> _reviews = [];
  WorkerRatingSummary? _ratingSummary;
  Review? _myReview;
  bool _isLoadingReviews = true;
  Worker get currentWorker => _worker ?? widget.worker;

  @override
  void initState() {
    super.initState();
    _worker = widget.worker;
    _loadWorkerDetails();
    _loadReviews();
  }

  Future<void> _loadWorkerDetails() async {
    final latestWorker = await WorkerService.fetchWorkerById(widget.worker.id);
    if (!mounted || latestWorker == null) return;
    setState(() => _worker = latestWorker);
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    final reviews = await ReviewService.getWorkerReviews(widget.worker.id);
    final myReview = await _loadMyReview();

    // Compute summary locally
    final totalReviews = reviews.length;
    final averageRating = totalReviews > 0
        ? reviews.map((r) => r.rating.toDouble()).reduce((a, b) => a + b) /
              totalReviews
        : 0.0;
    final summary = WorkerRatingSummary(
      averageRating: averageRating,
      totalReviews: totalReviews,
      ratingDistribution: {},
    );

    setState(() {
      _reviews = reviews;
      _ratingSummary = summary;
      _myReview = myReview;
      _isLoadingReviews = false;
    });
  }

  Future<Review?> _loadMyReview() async {
    try {
      debugPrint('🔍 Loading my review for worker ${widget.worker.id}');
      debugPrint('👤 Current UserSession.email: ${UserSession.email}');
      final myReview = await ReviewService.getUserReviewForWorker(
        widget.worker.id,
      );
      debugPrint('✅ _myReview: ${myReview?.id ?? "null"}');
      return myReview;
    } catch (e) {
      debugPrint('❌ _loadMyReview error: $e');
      return null;
    }
  }

  Future<void> _addOrUpdateReview() async {
    if (!UserSession.isLoggedIn) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('Please login to write a review'),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        workerName: currentWorker.name,
        worker: currentWorker,
        existingReview: _myReview,
        onSubmit: (rating, comment) async {
          try {
            if (_myReview != null) {
              await ReviewService.updateReview(_myReview!.id, rating, comment);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              await ReviewService.addReview(widget.worker.id, rating, comment);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
            if (mounted) _loadReviews();
          } catch (e) {
            if (mounted) {
              OfflineHandler.showErrorSnackBar(context, e);
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
    if (!UserSession.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to delete review')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReviewService.deleteReview(review.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) _loadReviews();
      } catch (e) {
        String errorMsg = 'Failed to delete review';
        if (e.toString().contains('own reviews')) {
          errorMsg = "You can only delete your own reviews";
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      }
    }
  }

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
    if (currentWorker.latitude != null && currentWorker.longitude != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${currentWorker.latitude},${currentWorker.longitude}",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(currentWorker.location)}",
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

  Future<void> _openMessageScreen() async {
    if (!UserSession.isLoggedIn) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('Please login to message this worker'),
      );
      return;
    }

    final senderEmail = UserSession.email;
    final recipientEmail = currentWorker.userEmail;
    if (senderEmail == null ||
        recipientEmail == null ||
        recipientEmail.isEmpty) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('Worker messaging is not available for this profile'),
      );
      return;
    }
    if (senderEmail.trim().toLowerCase() ==
        recipientEmail.trim().toLowerCase()) {
      OfflineHandler.showErrorSnackBar(
        context,
        Exception('You cannot message your own worker profile'),
      );
      return;
    }

    try {
      final conversation = await MessagingService.createOrGetConversation(
        senderEmail: senderEmail,
        recipientEmail: recipientEmail,
        workerId: currentWorker.id,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MessageChatScreen(
            conversationId: conversation.id,
            initialTitle: _getWorkerDisplayName(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      OfflineHandler.showErrorSnackBar(context, e);
    }
  }

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
                      groupValue: selectedReason,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedReason = value);
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
                        workerId: currentWorker.id,
                        reason: selectedReason,
                        description: descCtrl.text.trim(),
                        reporterEmail: UserSession.email ?? '',
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserEmail = UserSession.email?.trim().toLowerCase();
    final workerOwnerEmail = currentWorker.userEmail?.trim().toLowerCase();
    final canMessageWorker =
        currentUserEmail != null &&
        workerOwnerEmail != null &&
        workerOwnerEmail.isNotEmpty &&
        currentUserEmail != workerOwnerEmail;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: kPrimary,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.flag, color: Colors.red),
                          title: const Text('Report Worker'),
                          onTap: () {
                            Navigator.pop(context);
                            _openReportModal(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
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
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                      ),
                    ),
                  ),
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Profile Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              _getWorkerDisplayName()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getWorkerDisplayName(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentWorker.role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Body Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row Card
                  Transform.translate(
                    offset: const Offset(0, -40), // Pull up overlap
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildStatItem(
                            isDark,
                            "${currentWorker.rating ?? 0.0}",
                            "Rating",
                            Icons.star_rounded,
                            kYellowDark,
                          ),
                          _buildDivider(isDark),
                          _buildStatItem(
                            isDark,
                            "${currentWorker.experience} Yrs",
                            "Experience",
                            Icons.work_outline_rounded,
                            kPrimary,
                          ),
                          _buildDivider(isDark),
                          _buildStatItem(
                            isDark,
                            currentWorker.isVerified
                                ? "Verified"
                                : "Unverified",
                            "Status",
                            currentWorker.isVerified
                                ? Icons.verified_rounded
                                : Icons.info_outline,
                            currentWorker.isVerified ? kGreen : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contact Info
                  const Text(
                    "Contact Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(cardColor, textColor, isDark),

                  const SizedBox(height: 24),

                  // Reviews Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _addOrUpdateReview,
                        child: Text(
                          _myReview != null ? "Edit Review" : "Write Review",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildOverallReviewCard(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3. Reviews List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _isLoadingReviews
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : _reviews.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "No reviews yet",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildReviewCard(
                        _reviews[index],
                        isDark,
                        currentUserEmail: UserSession.email,
                      );
                    }, childCount: _reviews.length),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canMessageWorker) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text(
                      "Message Worker",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _openMessageScreen,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.location_on_outlined,
                          color: kPrimary,
                        ),
                        label: const Text("Location"),
                        onPressed: () => _openMap(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text("Call"),
                        onPressed: () =>
                            _callNumber(context, currentWorker.phone),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New helper methods
  Widget _buildStatItem(
    bool isDark,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kDark,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white10 : Colors.grey[200],
    );
  }

  Widget _buildContactCard(Color cardColor, Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          _contactTile(
            Icons.phone_outlined,
            "Phone",
            currentWorker.phone,
            textColor,
            isLast: false,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          _contactTile(
            Icons.location_on_outlined,
            "Location",
            currentWorker.location,
            textColor,
            isLast: false,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
          _contactTile(
            Icons.calendar_today_outlined,
            "Availability",
            _availabilityLabel(),
            textColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _contactTile(
    IconData icon,
    String label,
    String value,
    Color textColor, {
    required bool isLast,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: kPrimary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildOverallReviewCard(bool isDark) {
    final totalReviews = _ratingSummary?.totalReviews ?? 0;
    final averageRating =
        _ratingSummary?.averageRating ?? currentWorker.rating ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  totalReviews > 0 ? averageRating.toStringAsFixed(1) : "N/A",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: totalReviews > 0 ? kYellowDark : kGray,
                  ),
                ),
                if (totalReviews > 0)
                  StarRating(rating: averageRating, size: 16, showValue: false)
                else
                  const Text(
                    'No ratings yet',
                    style: TextStyle(fontSize: 12, color: kGray),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[200] : kDark,
                  ),
                ),
                Text(
                  'Based on $totalReviews reviews',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : kGray,
                  ),
                ),
                if (_myReview != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'You rated ${_myReview!.rating} stars',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _availabilityLabel() {
    if (currentWorker.isAvailable == false ||
        currentWorker.availabilityType == 'not_available') {
      return 'Currently unavailable';
    }

    final days = currentWorker.availableDays
        ?.split(',')
        .map((day) => day.trim())
        .where((day) => day.isNotEmpty)
        .toList();

    if (days != null && days.isNotEmpty) {
      return 'Available on ${days.join(', ')}';
    }

    if (currentWorker.availabilityType == 'selected_days') {
      return 'Available on selected days';
    }

    return 'Available every day';
  }

  Widget _buildReviewCard(
    Review review,
    bool isDark, {
    String? currentUserEmail,
  }) {
    final isMyReview =
        currentUserEmail != null && review.reviewerEmail == currentUserEmail;
    debugPrint(
      '📋 Review ${review.id}: reviewerEmail="${review.reviewerEmail}" vs user="$currentUserEmail" → isMyReview=$isMyReview',
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Date, Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: isMyReview
                    ? kPrimary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                child: Text(
                  review.reviewerInitials,
                  style: TextStyle(
                    color: isMyReview ? kPrimary : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName ?? review.reviewerEmail.split('@')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? kWhite : kDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.formattedDate,
                      style: TextStyle(color: kGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 18, color: kYellowDark),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}.0',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kYellowDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit/Delete menu for my reviews
              if (isMyReview) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: kGray),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _addOrUpdateReview();
                    } else if (value == 'delete') {
                      _deleteReview(review);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey[300] : kGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getWorkerDisplayName() {
    final firstName = currentWorker.firstName;
    final lastName = currentWorker.lastName;
    if (firstName != null &&
        lastName != null &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty) {
      return "$firstName $lastName";
    }
    return currentWorker.name;
  }
}
