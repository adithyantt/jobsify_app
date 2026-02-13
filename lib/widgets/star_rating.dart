import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? color;
  final bool showValue;

  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.color,
    this.showValue = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (index) {
          final starValue = index + 1;
          IconData icon;

          if (rating >= starValue) {
            icon = Icons.star;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }

          return Icon(icon, color: starColor, size: size);
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }
}

class StarRatingInput extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final double size;

  const StarRatingInput({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  }) : super(key: key);

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late int _rating;
  int _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled =
            (_hoverRating > 0 ? _hoverRating : _rating) >= starValue;

        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starValue;
            });
            widget.onRatingChanged(starValue);
          },
          onTapDown: (_) {
            setState(() {
              _hoverRating = starValue;
            });
          },
          onTapUp: (_) {
            setState(() {
              _hoverRating = 0;
            });
          },
          onTapCancel: () {
            setState(() {
              _hoverRating = 0;
            });
          },
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _hoverRating = starValue;
              });
            },
            onExit: (_) {
              setState(() {
                _hoverRating = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.all(4),
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? Colors.amber : Colors.grey,
                size: widget.size,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class RatingBar extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalReviews;
  final double barHeight;

  const RatingBar({
    Key? key,
    required this.distribution,
    required this.totalReviews,
    this.barHeight = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        final starCount = 5 - index;
        final count = distribution[starCount.toString()] ?? 0;
        final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$starCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber[starCount == 5
                          ? 700
                          : starCount == 4
                          ? 600
                          : starCount == 3
                          ? 500
                          : starCount == 2
                          ? 400
                          : 300]!,
                    ),
                    minHeight: barHeight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }),
    );
  }
}
