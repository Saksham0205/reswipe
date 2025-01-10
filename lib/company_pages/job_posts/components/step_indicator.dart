import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final Map<int, bool> completedSections;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.completedSections,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Basic Info', 'icon': Icons.description},
      {'label': 'Details', 'icon': Icons.list_alt},
      {'label': 'Requirements', 'icon': Icons.check_circle}
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressBar(steps.length),
          SizedBox(height: 24.h),
          _buildStepIndicators(steps),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalSteps) {
    return Container(
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.centerLeft,
        widthFactor: (currentStep + 1) / totalSteps,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
            ),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicators(List<Map<String, dynamic>> steps) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isCompleted = completedSections[index] ?? false;
        final isActive = index == currentStep;

        return _buildStepIndicator(
          label: steps[index]['label'] as String,
          icon: steps[index]['icon'] as IconData,
          isCompleted: isCompleted,
          isActive: isActive,
        );
      }),
    );
  }

  Widget _buildStepIndicator({
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 1.0, end: isActive ? 1.1 : 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCompleted
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : isActive
                        ? [Colors.deepPurple.shade400, Colors.deepPurple.shade600]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted || isActive)
                          ? Colors.deepPurple.withOpacity(0.3)
                          : Colors.transparent,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : icon,
                    color: Colors.white,
                    size: 24.r,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.deepPurple.shade700 : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}