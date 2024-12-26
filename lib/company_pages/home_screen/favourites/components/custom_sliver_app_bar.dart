import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/app_class.dart';

class CustomSliverAppBar extends StatelessWidget {
  final bool hasItems;
  final Function(BuildContext) onClearAll;

  const CustomSliverAppBar({
    Key? key,
    required this.hasItems,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
        ),
        title: Text(
          'Matched Profiles',
          style: AppTypography.appBarTitle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16.h),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (hasItems)
          IconButton(
            tooltip: 'Clear all matches',
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: () => onClearAll(context),
          ),
      ],
    );
  }
}