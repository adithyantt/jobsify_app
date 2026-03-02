import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../models/worker_model.dart';
import 'star_rating.dart';

class AddReviewDialog extends StatefulWidget {
  final String workerName;
  final Worker? worker;
  final Review? existingReview;
  final Function(int rating, String? comment) onSubmit;

  const AddReviewDialog({
    Key? key,
    required this.workerName,
    this.worker,
    this.existingReview,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  late int _rating;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController.text = widget.existingReview?.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getWorkerDisplayName() {
    if (widget.worker != null) {
      final firstName = widget.worker!.firstName;
      final lastName = widget.worker!.lastName;
      if (firstName != null &&
          lastName != null &&
          firstName.isNotEmpty &&
          lastName.isNotEmpty) {
        return "$firstName $lastName";
      }
    }
    return widget.workerName;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Review' : 'Rate & Review',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getWorkerDisplayName(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      StarRatingInput(
                        initialRating: _rating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rating > 0 ? '${_rating} stars' : 'Tap to rate',
                        style: TextStyle(
                          color: _rating > 0 ? Colors.amber[700] : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this worker...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[700]!,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _rating > 0
                        ? () {
                            widget.onSubmit(
                              _rating,
                              _commentController.text.trim(),
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Review' : 'Submit Review',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
