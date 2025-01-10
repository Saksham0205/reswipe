import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final bool canProceed;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.isLoading,
    required this.canProceed,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentStep > 0)
            _buildButton(
              icon: Icons.arrow_back,
              label: 'Previous',
              onPressed: onPrevious,
              isPrevious: true,
            )
          else
            const SizedBox(width: 0),
          _buildButton(
            icon: currentStep < 2 ? Icons.arrow_forward : Icons.check,
            label: currentStep < 2 ? 'Next' : (isLoading ? 'Posting...' : 'Post Job'),
            onPressed: currentStep < 2 ? (canProceed ? onNext : null) : onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrevious = false,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrevious ? Colors.grey[300] : Colors.deepPurple,
        foregroundColor: isPrevious ? Colors.black87 : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: isPrevious ? 0 : 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else
            Icon(icon, size: 20.r,color: Colors.white,),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}