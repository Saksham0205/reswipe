import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/company_model/applications.dart';
import 'favorite_card_content.dart';

class AnimatedFavoriteCard extends StatelessWidget {
  final Application application;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final int index;

  const AnimatedFavoriteCard({
    Key? key,
    required this.application,
    required this.onDelete,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 100),
        ),
        SlideEffect(
          begin: Offset(0, 0.1),
          end: Offset.zero,
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 100),
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Dismissible(
        key: Key(application.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        confirmDismiss: (_) async {
          onDelete();
          return true;
        },
        child: FavoriteCardContent(
          application: application,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete_forever_rounded,
            color: Colors.red.shade700,
            size: 32.r,
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }
}