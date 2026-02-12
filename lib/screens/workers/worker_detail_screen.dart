import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/worker_model.dart';
import '../../models/review_model.dart';
import '../../services/worker_service.dart';
import '../../services/review_service.dart';
import '../../services/user_session.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/review_list.dart';
import '../../widgets/add_review_dialog.dart';

/// 🎨 COLORS
const Color kRed = Color(0xFFFF1E2D);
const Color kBlue = Color(0xFF6B7280);
const Color kYellow = Color(0xFFFFC107);
const Color kGreen = Color(0xFF16A34A);
const Color kLightBlue = Color(0xFF87CEEB);

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
  int _selectedTab = 0; // 0 = Info, 1 = Reviews

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
      // Load reviews and summary in parallel
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
        existingReview: _myReview,
        onSubmit: (rating, comment) async {
          try {
            if (_myReview != null) {
              // Update existing review
              await ReviewService.updateReview(_myReview!.id, rating, comment);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review updated successfully')),
              );
            } else {
              // Add new review
              await ReviewService.addReview(widget.worker.id, rating, comment);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review added successfully')),
              );
            }
            // Reload reviews
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
          // Tab Selector
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton("Info", 0)),
                Expanded(child: _buildTabButton("Reviews", 1)),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0 ? _buildInfoTab() : _buildReviewsTab(),
          ),

          // Bottom Action Buttons (only show in Info tab)
          if (_selectedTab == 0)
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.call, size: 20),
                        label: const Text(
                          "Call",
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () =>
                            _callNumber(context, widget.worker.phone),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.location_on, size: 20),
                        label: const Text(
                          "View Location",
                          style: TextStyle(fontSize: 14),
                        ),
                        onPressed: () => _openMap(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? kLightBlue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? kLightBlue : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (_ratingSummary?.averageRating ??
                                widget.worker.rating ??
                                4.0)
                            .toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      StarRating(
                        rating:
                            _ratingSummary?.averageRating ??
                            widget.worker.rating ??
                            4.0,
                        size: 16,
                        showValue: false,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'Based on customer experiences',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          const SizedBox(height: 20),

          _tag(context, widget.worker.role),
          const SizedBox(height: 12),
          Text(
            widget.worker.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),

          const SizedBox(height: 16),
          _infoRow(
            context,
            Icons.work,
            "${widget.worker.experience} years experience",
          ),
          _infoRow(context, Icons.location_on, widget.worker.location),
          _infoRow(context, Icons.phone, widget.worker.phone),
          if (widget.worker.isVerified)
            _infoRow(
              context,
              Icons.verified,
              "Verified worker",
              color: Theme.of(context).primaryColor,
            ),
          if (widget.worker.latitude != null && widget.worker.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Precise location available",
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Add Review Button
        if (UserSession.isLoggedIn)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addOrUpdateReview,
              icon: Icon(_myReview != null ? Icons.edit : Icons.rate_review),
              label: Text(
                _myReview != null ? 'Edit Your Review' : 'Write a Review',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kLightBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Rating Distribution (if available)
        if (_ratingSummary != null && _ratingSummary!.totalReviews > 0)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: RatingBar(
              distribution: _ratingSummary!.ratingDistribution,
              totalReviews: _ratingSummary!.totalReviews,
            ),
          ),

        const SizedBox(height: 16),

        // Reviews List
        Expanded(
          child: ReviewList(
            reviews: _reviews,
            isLoading: _isLoadingReviews,
            error: _reviewsError,
            onRetry: _loadReviews,
            currentUserEmail: UserSession.email,
            onEdit: (review) {
              if (review.reviewerEmail == UserSession.email) {
                _addOrUpdateReview();
              }
            },
            onDelete: (review) {
              if (review.reviewerEmail == UserSession.email) {
                _deleteReview(review);
              }
            },
          ),
        ),
      ],
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
        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
