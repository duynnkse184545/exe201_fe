import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../service/api/review_service.dart';
import '../../../model/review/review.dart';
import '../../extra/theme_extensions.dart';

class MyReviewsWidget extends ConsumerStatefulWidget {
  final VoidCallback? onWriteReviewTap;
  final VoidCallback? onReviewUpdated;
  
  const MyReviewsWidget({super.key, this.onWriteReviewTap, this.onReviewUpdated});

  @override
  MyReviewsWidgetState createState() => MyReviewsWidgetState();
}

class MyReviewsWidgetState extends ConsumerState<MyReviewsWidget> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _userReviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadUserReviews();
  }

  Future<void> loadUserReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final reviews = await _reviewService.getUserReviews();
      setState(() {
        _userReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      await loadUserReviews();
      widget.onReviewUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.primaryColor,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load your reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadUserReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Share your experience with the app!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (widget.onWriteReviewTap != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onWriteReviewTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: Icon(Icons.add),
                label: Text('Write a Review'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadUserReviews,
      color: context.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _userReviews.length,
        itemBuilder: (context, index) {
          final review = _userReviews[index];
          return _buildMyReviewCard(review);
        },
      ),
    );
  }

  Widget _buildMyReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.primaryColorLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rating and actions
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryColorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${review.rating}/5',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog(review);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(review);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: context.primaryColor),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Rating stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 20,
                color: index < review.rating
                    ? Colors.amber
                    : Colors.grey[300],
              );
            }),
          ),
          
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
          
          SizedBox(height: 12),
          
          // Date info
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey[500],
              ),
              SizedBox(width: 4),
              Text(
                'Created: ${_formatDate(review.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (review.updatedAt != review.createdAt) ...[
                SizedBox(width: 12),
                Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 4),
                Text(
                  'Updated: ${_formatDate(review.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Review review) {
    final commentController = TextEditingController(text: review.comment);
    int selectedRating = review.rating;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit Review',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.star,
                        size: 32,
                        color: index < selectedRating
                            ? Colors.amber
                            : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 16),
              Text(
                'Comment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final reviewRequest = ReviewRequest(
                    rating: selectedRating,
                    comment: commentController.text.trim(),
                  );
                  
                  await _reviewService.updateReview(review.reviewId, reviewRequest);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Review updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    loadUserReviews();
                    widget.onReviewUpdated?.call();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update review: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete Review',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(review.reviewId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Convert UTC to Vietnamese time (UTC+7)
    final vietnamTime = date.toUtc().add(Duration(hours: 7));
    return '${vietnamTime.day.toString().padLeft(2, '0')}/${vietnamTime.month.toString().padLeft(2, '0')}/${vietnamTime.year}';
  }
}