import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controller/profile_controller.dart';
import '../../shared/profile_text_field.dart';

class ProfessionalSection extends StatelessWidget {
  final ProfileController controller;

  const ProfessionalSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Professional Experience',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                if (controller.hasUnsavedChanges)
                  Chip(
                    label: Text(
                      'Unsaved Changes',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildEducationSection(),
            SizedBox(height: 16.h),
            _buildExperienceSection(context),
            SizedBox(height: 16.h),
            _buildProjectsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          controller: controller.qualificationController,
          labelText: 'Education',
          icon: Icons.school,
        ),
        SizedBox(height: 16.h),
        ProfileTextField(
          controller: controller.jobProfileController,
          labelText: 'Current Job Profile',
          icon: Icons.work,
        ),
      ],
    );
  }

  Widget _buildExperienceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_history, size: 20.sp, color: Colors.deepPurple),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Experience',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 20.sp, color: Colors.deepPurple),
              onPressed: () => _showEditDialog(
                context: context,
                title: 'Edit Experience',
                controller: controller.experienceController,
                hint: 'Enter your experience (one per line)',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildList(controller.experienceController.text),
      ],
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.engineering, size: 20.sp, color: Colors.deepPurple),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Projects',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 20.sp, color: Colors.deepPurple),
              onPressed: () => _showEditDialog(
                context: context,
                title: 'Edit Projects',
                controller: controller.projectsController,
                hint: 'Enter your projects (one per line)',
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildList(controller.projectsController.text),
      ],
    );
  }

  Widget _buildList(String text) {
    final items = text.split('\n')..removeWhere((e) => e.isEmpty);

    return items.isEmpty
        ? Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          'No items added yet',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              items[index],
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    final TextEditingController tempController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        content: TextField(
          controller: tempController,
          maxLines: null,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              controller.text = tempController.text;
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    ).then((_) => tempController.dispose());
  }
}
