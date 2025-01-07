import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/job_sorter.dart';

class SortButton extends StatelessWidget {
  final SortOrder currentOrder;
  final ValueChanged<SortOrder> onSortChanged;

  const SortButton({
    Key? key,
    required this.currentOrder,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      initialValue: currentOrder,
      onSelected: onSortChanged,
      position: PopupMenuPosition.under,
      offset: Offset(0, 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem(
          SortOrder.newest,
          'Oldest First',
          Icons.arrow_downward,
        ),
        _buildPopupMenuItem(
          SortOrder.oldest,
          'Newest First',
          Icons.arrow_upward,
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.deepPurple,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16.sp,
              color: Colors.deepPurple,
            ),
            SizedBox(width: 4.w),
            Text(
              currentOrder == SortOrder.newest ? 'Oldest First' : 'Newest First',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SortOrder> _buildPopupMenuItem(
      SortOrder value,
      String text,
      IconData icon,
      ) {
    return PopupMenuItem<SortOrder>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: currentOrder == value ? Colors.deepPurple : Colors.grey,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: currentOrder == value ? Colors.deepPurple : Colors.black87,
              fontWeight:
              currentOrder == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}