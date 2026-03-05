import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';
import '../../models/review_model.dart';
import '../../services/worker_service.dart';
import '../../services/review_service.dart';
import '../../services/user_session.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/add_review_dialog.dart';

/// 🎨 COLORS
const Color kPrimary = Color(0xFF4F46E5);
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kYellowDark = Color(0xFFB45309);
const Color kGreen = Color(0xFF16A34A);
const Color kLightBlue = Color(0xFF87CEEB);
const Color kOrange = Color(0xFFF59E0B);
const Color kDark = Color(0xFF1E293B);
const Color kGray = Color(0xFF64748B);
const Color kLight = Color(0xFFF1F5F9);
const Color kWhite = Color(0xFFFFFFFF);

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({super.key, required this.worker});

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  List<Review> _reviews = [];
  WorkerRatingSummary? _ratingSummary;
  Review? _myReview;
  bool _isLoadingReviews = true;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final results = await Future.wait([
        ReviewService.getWorkerReviews(widget.worker.id),
        ReviewService.getWorkerRatingSummary(widget.worker.id),
        _loadMyReview(),
      ]);

      setState(() {
        _reviews = results[0] as List<Review>;
        _ratingSummary = results[1] as WorkerRatingSummary;
        _myReview = results[2] as Review?;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewsError = e.toString();
        _isLoadingReviews = false;
      });
    }
  }

  Future<Review?> _loadMyReview() async {
    try {
      if (!UserSession.isLoggedIn) return null;
      return await ReviewService.getUserReviewForWorker(widget.worker.id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _addOrUpdateReview() async {
    if (!UserSession.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a review')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        workerName: widget.worker.name,
        worker: widget.worker,
        existingReview: _myReview,
        onSubmit: (rating, comment) async {
          try {
            if (_myReview != null) {
              await ReviewService.updateReview(_myReview!.id, rating, comment);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review updated successfully')),
              );
            } else {
              await ReviewService.addReview(widget.worker.id, rating, comment);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review added successfully')),
              );
            }
            _loadReviews();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }

  Future<void> _deleteReview(Review review) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
        _loadReviews();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    if (widget.worker.latitude != null && widget.worker.longitude != null) {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.worker.latitude},${widget.worker.longitude}",
      );
    } else {
      uri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.worker.location)}",
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
                        workerId: widget.worker.id,
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : kLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        title: const Text("Worker Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "report") _openReportModal(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "report", child: Text("Report Worker")),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category/Role Chip
            Wrap(
              spacing: 8,
              children: [
                _chip(widget.worker.role, kPrimary),
                if (widget.worker.isVerified) _chip("Verified", kGreen),
              ],
            ),
            const SizedBox(height: 16),

            // Worker Name
            Text(
              _getWorkerDisplayName(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? kWhite : kDark,
              ),
            ),
            const SizedBox(height: 16),

            // Rating Card - Similar to Job Detail
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : kWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  // Rating Number
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          (_ratingSummary?.totalReviews ?? 0) > 0
                              ? (_ratingSummary?.averageRating ??
                                        widget.worker.rating ??
                                        0.0)
                                    .toStringAsFixed(1)
                              : "N/A",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: (_ratingSummary?.totalReviews ?? 0) > 0
                                ? kYellowDark
                                : kGray,
                          ),
                        ),
                        if ((_ratingSummary?.totalReviews ?? 0) > 0)
                          StarRating(
                            rating:
                                _ratingSummary?.averageRating ??
                                widget.worker.rating ??
                                0.0,
                            size: 16,
                            showValue: false,
                          )
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
                          '${_ratingSummary?.totalReviews ?? 0} Reviews',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : kDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on customer experiences',
                          style: TextStyle(fontSize: 12, color: kGray),
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
            ),
            const SizedBox(height: 16),

            // Worker Info Card
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
                  _infoRow(
                    context,
                    Icons.work,
                    "${widget.worker.experience} years experience",
                    isDark,
                  ),
                  _infoRow(
                    context,
                    Icons.location_on,
                    widget.worker.location,
                    isDark,
                  ),
                  _infoRow(context, Icons.phone, widget.worker.phone, isDark),
                  if (widget.worker.isVerified)
                    _infoRow(
                      context,
                      Icons.verified,
                      "Verified worker",
                      isDark,
                      color: kPrimary,
                    ),
                  if (widget.worker.latitude != null &&
                      widget.worker.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 26),
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
            const SizedBox(height: 24),

            // Reviews Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? kWhite : kDark,
                  ),
                ),
                if (UserSession.isLoggedIn)
                  TextButton.icon(
                    onPressed: _addOrUpdateReview,
                    icon: Icon(
                      _myReview != null ? Icons.edit : Icons.rate_review,
                      size: 18,
                    ),
                    label: Text(
                      _myReview != null ? 'Edit' : 'Write',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Add Review Button (full width)
            if (UserSession.isLoggedIn)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: _addOrUpdateReview,
                  icon: Icon(
                    _myReview != null ? Icons.edit : Icons.rate_review,
                  ),
                  label: Text(
                    _myReview != null ? 'Edit Your Review' : 'Write a Review',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Reviews List - With larger cards
            if (_isLoadingReviews)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_reviewsError != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _reviewsError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadReviews,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : kWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to review this worker',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                _reviews.length,
                (index) => _buildReviewCard(
                  _reviews[index],
                  isDark,
                  currentUserEmail: UserSession.email,
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
                      side: const BorderSide(color: kPrimary),
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
                      backgroundColor: kGreen,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text("Call Now"),
                    onPressed: () => _callNumber(context, widget.worker.phone),
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

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[300] : kGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    Review review,
    bool isDark, {
    String? currentUserEmail,
  }) {
    final isMyReview =
        currentUserEmail != null && review.reviewerEmail == currentUserEmail;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyReview
              ? kPrimary.withValues(alpha: 0.3)
              : Colors.grey[200]!,
        ),
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
                backgroundColor: kPrimary.withValues(alpha: 0.15),
                child: Text(
                  review.reviewerInitials,
                  style: const TextStyle(
                    color: kPrimary,
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
                      review.reviewerName ?? review.reviewerEmail,
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
                  color: kYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
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
    final firstName = widget.worker.firstName;
    final lastName = widget.worker.lastName;
    if (firstName != null &&
        lastName != null &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty) {
      return "$firstName $lastName";
    }
    return widget.worker.name;
  }
}
