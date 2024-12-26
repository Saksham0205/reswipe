import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import '../../../models/company_model/applications.dart';

class HomeAppBar extends StatelessWidget {
  final List<Application> favoriteApplications;
  final VoidCallback onFavoritesTap;

  const HomeAppBar({
    Key? key,
    required this.favoriteApplications,
    required this.onFavoritesTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(8.w),
          child: Icon(Icons.work_outline, color: Colors.white, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          'Reswipe',
          style: GoogleFonts.pacifico(
            fontSize: 28.sp,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 28.sp),
          color: Colors.deepPurple,
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
        _buildFavoritesButton(),
      ],
    );
  }

  Widget _buildFavoritesButton() {
    return GestureDetector(
      onTap: onFavoritesTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.all(8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
             Icon(Icons.favorite, color: Colors.deepPurple, size: 28.sp),
            if (favoriteApplications.isNotEmpty)
              Positioned(
                right: -2.w,
                top: -2.h,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18.w,
                    minHeight: 18.h,
                  ),
                  child: Text(
                    '${favoriteApplications.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
