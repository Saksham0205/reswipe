import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/job_sorter.dart';
import 'sort_button.dart';

class FilterSection extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;


  const FilterSection({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                String filter = filters[index];
                return FilterChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: selectedFilter == filter
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                  selected: selectedFilter == filter,
                  onSelected: (selected) => onFilterSelected(filter),
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: Colors.deepPurple,
                      width: 1.w,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                );
              },
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}