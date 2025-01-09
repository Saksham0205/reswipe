import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/applications.dart';
import '../favourites/components/application_details.dart';
import '../widgets/application_card.dart';

class ApplicationList extends StatefulWidget {
  final List<Application> applications;
  final CardSwiperController controller;
  final Animation<double> animation;
  final Function(Application, bool) onSwipe;
  final VoidCallback? onReset;
  final Application? lastSwipedApplication;
  final bool isLoading;
  final int totalApplications;
  final int swipedLeft;
  final int swipedRight;

  const ApplicationList({
    super.key,
    required this.applications,
    required this.controller,
    required this.animation,
    required this.onSwipe,
    this.onReset,
    this.lastSwipedApplication,
    this.isLoading = false,
    required this.totalApplications,
    required this.swipedLeft,
    required this.swipedRight,
  });

  @override
  State<ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {

  @override
  void initState() {
    super.initState();
    widget.controller.currentIndex = 0;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.totalApplications == 0) {
      return _buildNoApplicationsState();
    }

    // Check if there are any remaining applications to review
    if (widget.applications.isEmpty ||
        widget.swipedLeft + widget.swipedRight >= widget.totalApplications) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildApplicationStats(),
        Expanded(
          child: FadeTransition(
            opacity: widget.animation,
            child: CardSwiper(
              controller: widget.controller,
              cardsCount: widget.applications.length,
              numberOfCardsDisplayed: widget.applications.length >= 2 ? 2 : 1,
              backCardOffset: Offset(0, 40.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              onSwipe: (previousIndex, currentIndex, direction) {
                // Validate index before accessing the applications list
                if (previousIndex >= widget.applications.length) {
                  return false;
                }

                final isRightSwipe = direction == CardSwiperDirection.right;
                widget.controller.currentIndex = currentIndex ?? widget.controller.currentIndex;
                widget.onSwipe(widget.applications[previousIndex], isRightSwipe);
                return true;
              },
              cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                // Validate index before accessing the applications list
                if (index >= widget.applications.length) {
                  return const SizedBox.shrink();
                }
                return ApplicationCard(
                  application: widget.applications[index],
                  onDetailsPressed: () => _showApplicationDetails(
                    context,
                    widget.applications[index],
                  ),
                );
              },
            ),
          ),
        ),
        _SwipeButtons(
          controller: widget.controller,
          onSwipeLeft: () {
            final currentIndex = widget.controller.currentIndex;
            if (currentIndex < widget.applications.length) {
              widget.onSwipe(widget.applications[currentIndex], false);
              widget.controller.swipe(CardSwiperDirection.left);
            }
          },
          onSwipeRight: () {
            final currentIndex = widget.controller.currentIndex;
            if (currentIndex < widget.applications.length) {
              widget.onSwipe(widget.applications[currentIndex], true);
              widget.controller.swipe(CardSwiperDirection.right);
            }
          },
        ),
      ],
    );
  }

  Widget _buildApplicationStats() {
    return Padding(
      padding: EdgeInsets.all(16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            'Total',
            widget.totalApplications,
            Colors.blue,
            Icons.people_outline,
          ),
          _buildStatCard(
            'Shortlisted',
            widget.swipedRight,
            Colors.green,
            Icons.thumb_up_outlined,
          ),
          _buildStatCard(
            'Rejected',
            widget.swipedLeft,
            Colors.red,
            Icons.thumb_down_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApplicationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 44.sp, color: Colors.grey),
          SizedBox(height: 14.h),
          Text(
            'No Applications Yet',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Wait for candidates to apply for this position',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildApplicationStats(),
          SizedBox(height: 24.h),
          Icon(Icons.file_copy_outlined, size: 44.sp, color: Colors.grey),
          SizedBox(height: 14.h),
          Text(
            'All Applications Reviewed',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Would you like to review them again?',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          if (widget.onReset != null)
            ElevatedButton.icon(
              onPressed: widget.onReset,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Reset Applications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showApplicationDetails(BuildContext context, Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailsSheet(application: application),
    );
  }
}

extension CardSwiperControllerExtension on CardSwiperController {
  static final Map<CardSwiperController, int> _currentIndices = {};

  int get currentIndex {
    return _currentIndices[this] ?? 0;
  }

  set currentIndex(int value) {
    _currentIndices[this] = value;
  }

  void dispose() {
    _currentIndices.remove(this);
  }
}

class _SwipeButtons extends StatelessWidget {
  final CardSwiperController controller;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const _SwipeButtons({
    required this.controller,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SwipeButton(
            onPressed: onSwipeLeft,
            icon: Icons.close,
            label: 'Reject',
            color: Colors.red,
          ),
          _SwipeButton(
            onPressed: onSwipeRight,
            icon: Icons.check,
            label: 'Shortlist',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 16.sp),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
    );
  }
}