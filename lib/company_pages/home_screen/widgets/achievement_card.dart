import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AchievementCard extends StatelessWidget {
  final String achievement;
  final int index;

  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.amber.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIconSection(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Container(
      width: 64.w,
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events,
                size: 18.sp,
                color: Colors.amber.shade700,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '#$index',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Text(
        achievement,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}