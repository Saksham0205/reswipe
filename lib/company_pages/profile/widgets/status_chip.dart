import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusChip extends StatelessWidget {
  final String employmentType;

  const StatusChip({
    Key? key,
    required this.employmentType,
  }) : super(key: key);

  Color _getChipColor() {
    switch (employmentType.toLowerCase()) {
      case 'full-time':
        return Colors.green;
      case 'part-time':
        return Colors.orange;
      case 'contract':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: chipColor,
          width: 1.w,
        ),
      ),
      child: Text(
        employmentType,
        style: TextStyle(
          color: chipColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}