import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/applications.dart';
import '../favourites/components/application_details.dart';
import '../widgets/application_card.dart';

class ApplicationList extends StatelessWidget {
  final List<Application> applications;
  final CardSwiperController controller;
  final Animation<double> animation;
  final Function(Application) onSwipe;

  const ApplicationList({
    Key? key,
    required this.applications,
    required this.controller,
    required this.animation,
    required this.onSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_copy_outlined, size: 44.sp, color: Colors.grey),
            SizedBox(height: 14.h),
            Text(
              'No applications yet',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: animation,
            child: CardSwiper(
              controller: controller,
              cardsCount: applications.length,
              numberOfCardsDisplayed: 1,
              backCardOffset: Offset(0, 40.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              onSwipe: (previousIndex, _, direction) {
                onSwipe(applications[previousIndex]);
                return true;
              },
              cardBuilder: (context, index, _, __) {
                return ApplicationCard(
                  application: applications[index],
                  onDetailsPressed: () => _showApplicationDetails(
                    context,
                    applications[index],
                  ),
                );
              },
            ),
          ),
        ),
        _SwipeButtons(controller: controller),
      ],
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

class _SwipeButtons extends StatelessWidget {
  final CardSwiperController controller;

  const _SwipeButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SwipeButton(
            onPressed: () => controller.swipe(CardSwiperDirection.left),
            icon: Icons.close,
            label: 'Reject',
            color: Colors.red,
          ),
          _SwipeButton(
            onPressed: () => controller.swipe(CardSwiperDirection.right),
            icon: Icons.check,
            label: 'Accept',
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
