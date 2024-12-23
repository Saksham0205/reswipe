import 'package:flutter/material.dart';
import '../../../controller/profile_controller.dart';
import '../../shared/expandable_text_field.dart';
import '../../shared/profile_text_field.dart';


class SkillsAchievementsSection extends StatelessWidget {
  final ProfileController controller;

  const SkillsAchievementsSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills & Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              controller: controller.skillsController,
              labelText: 'Skills (comma separated)',
              icon: Icons.star,
            ),
            const SizedBox(height: 16),
            ExpandableTextField(
              title: 'Achievements',
              icon: Icons.emoji_events,
              initialValue: controller.profileData.achievements,
              onChanged: (value) => controller.profileData.achievements = value,
              hint: 'Enter your achievements (one per line)',
            ),
          ],
        ),
      ),
    );
  }
}