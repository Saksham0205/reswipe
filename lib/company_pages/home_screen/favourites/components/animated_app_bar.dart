import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedAppBar extends StatelessWidget {
  final bool hasItems;
  final VoidCallback onClearAll;
  final VoidCallback onBack;

  const AnimatedAppBar({
    Key? key,
    required this.hasItems,
    required this.onClearAll,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Matched Profiles',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 16.h),
          background: _buildBackground(),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 24.r,
        ),
        onPressed: onBack,
      ),
      actions: [
        if (hasItems)
          IconButton(
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 24.r,
            ),
            tooltip: 'Clear all matches',
            onPressed: onClearAll,
          ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50.r,
            right: -50.r,
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20.r,
            left: -20.r,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}