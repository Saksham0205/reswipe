import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static final subtitle1 = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black54,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}