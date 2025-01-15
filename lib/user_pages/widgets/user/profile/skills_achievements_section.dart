import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controller/profile_controller.dart';
import '../../shared/profile_text_field.dart';

class SkillsAchievementsSection extends StatelessWidget {
  final ProfileController controller;

  const SkillsAchievementsSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills & Achievements',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16.h),
            ProfileTextField(
              controller: controller.skillsController,
              labelText: 'Skills (comma separated)',
              icon: Icons.star,
              onChanged: (value) => controller.updateLocalField('skills', value),
            ),
            SizedBox(height: 16.h),
            _buildAchievementsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.deepPurple, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.deepPurple, size: 20.sp),
              onPressed: () => _showEditAchievementsDialog(context),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildAchievementsList(),
      ],
    );
  }

  Widget _buildAchievementsList() {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final achievements = controller.profileData.achievements;

        if (achievements.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No achievements added yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(achievements[index]),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16.w),
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white, size: 20.sp),
              ),
              onDismissed: (_) => controller.removeAchievement(index),
              child: Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  title: Text(
                    achievements[index],
                    style: TextStyle(fontSize: 14.sp, height: 1.5.h),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditAchievementsDialog(BuildContext context) async {
    final tempController = TextEditingController(
      text: controller.profileData.achievements.join('\n'),
    );

    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit Achievements', style: TextStyle(fontSize: 18.sp)),
          content: TextField(
            controller: tempController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Enter your achievements (one per line)',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(fontSize: 14.sp),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () {
                final achievements = tempController.text
                    .split('\n')
                    .where((e) => e.trim().isNotEmpty)
                    .toList();
                controller.updateLocalField('achievements', achievements);
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      );
    } finally {
      tempController.dispose();
    }
  }
}
