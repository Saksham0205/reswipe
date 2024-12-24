import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final heading1 = GoogleFonts.poppins(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static final subtitle1 = GoogleFonts.poppins(
    fontSize: 16.sp,
    color: Colors.black54,
  );

  static final buttonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}