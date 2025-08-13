import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../extra/theme_extensions.dart';
import 'reviews_list_screen.dart';
import 'my_reviews_screen.dart';
import 'write_review_screen.dart';

class ReviewsMainScreen extends ConsumerStatefulWidget {
  const ReviewsMainScreen({super.key});

  @override
  ConsumerState<ReviewsMainScreen> createState() => _ReviewsMainScreenState();
}

class _ReviewsMainScreenState extends ConsumerState<ReviewsMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ReviewsListWidgetState> _allReviewsKey = GlobalKey();
  final GlobalKey<MyReviewsWidgetState> _myReviewsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onReviewSubmitted() {
    // Refresh both review lists
    _allReviewsKey.currentState?.loadReviews();
    _myReviewsKey.currentState?.loadUserReviews();
    
    // Switch to My Reviews tab to show the new review
    _tabController.animateTo(1);
  }

  void _onReviewUpdated() {
    // Refresh all reviews list when user review is updated/deleted
    _allReviewsKey.currentState?.loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Reviews & Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: context.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.reviews),
              text: 'All Reviews',
            ),
            Tab(
              icon: Icon(Icons.rate_review),
              text: 'My Reviews',
            ),
            Tab(
              icon: Icon(Icons.edit),
              text: 'Write Review',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReviewsListWidget(
            key: _allReviewsKey,
            onWriteReviewTap: () => _tabController.animateTo(2),
          ),
          MyReviewsWidget(
            key: _myReviewsKey,
            onWriteReviewTap: () => _tabController.animateTo(2),
            onReviewUpdated: _onReviewUpdated,
          ),
          WriteReviewWidget(
            onReviewSubmitted: _onReviewSubmitted,
          ),
        ],
      ),
    );
  }
}