import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/company_model/applications.dart';

class DetailedFavoriteCard extends StatelessWidget {
final Application application;
final int index;
final VoidCallback onDelete;
final VoidCallback onViewResume;

const DetailedFavoriteCard({
Key? key,
required this.application,
required this.index,
required this.onDelete,
required this.onViewResume,
}) : super(key: key);

@override
Widget build(BuildContext context) {
return Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12.r),
),
child: Padding(
padding: EdgeInsets.all(16.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildHeader(),
SizedBox(height: 16.h),
_buildActionButtons(context),
SizedBox(height: 16.h),
_buildSection('Skills', application.skills),
SizedBox(height: 12.h),
_buildSection('Experience', application.experience),
SizedBox(height: 12.h),
_buildSection('Projects', application.projects),
],
),
),
).animate()
    .fadeIn(delay: Duration(milliseconds: 100 * index))
    .slideX(begin: 0.2, end: 0);
}

Widget _buildHeader() {
return Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
application.applicantName,
style: TextStyle(
fontSize: 18.sp,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
SizedBox(height: 4.h),
Text(
application.qualification,
style: TextStyle(
fontSize: 14.sp,
color: Colors.grey[600],
),
),
],
),
),
IconButton(
icon: Icon(Icons.close, size: 20.sp),
onPressed: onDelete,
color: Colors.grey[600],
),
],
);
}

Widget _buildActionButtons(BuildContext context) {
return Row(
children: [
Expanded(
child: ElevatedButton.icon(
onPressed: onViewResume,
icon: Icon(Icons.description, size: 18.sp),
label: Text('View Resume'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
padding: EdgeInsets.symmetric(vertical: 12.h),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(8.r),
),
),
),
),
],
);
}

Widget _buildSection(String title, List<String> items) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
fontSize: 16.sp,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
SizedBox(height: 8.h),
Wrap(
spacing: 8.w,
runSpacing: 8.h,
children: items.map((item) => _buildChip(item)).toList(),
),
],
);
}

Widget _buildChip(String text) {
return Container(
padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
decoration: BoxDecoration(
color: Colors.deepPurple.withOpacity(0.1),
borderRadius: BorderRadius.circular(16.r),
border: Border.all(
color: Colors.deepPurple.withOpacity(0.3),
),
),
child: Text(
text,
style: TextStyle(
fontSize: 12.sp,
color: Colors.deepPurple,
),
),
);
}
}
