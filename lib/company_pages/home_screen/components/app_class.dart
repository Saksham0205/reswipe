import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF6A40E6);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color textDark = Color(0xFF333333);
}

class AppTypography {
  static final TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}