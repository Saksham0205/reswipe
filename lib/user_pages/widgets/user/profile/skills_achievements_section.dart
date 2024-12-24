import 'package:flutter/material.dart';
import '../../../../controller/profile_controller.dart';
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
              onChanged: (value) => controller.updateLocalField('skills', value),
            ),
            const SizedBox(height: 16),
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
            const Icon(Icons.emoji_events, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () => _showEditAchievementsDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No achievements added yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
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
                padding: const EdgeInsets.only(right: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.removeAchievement(index),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    achievements[index],
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddAchievementDialog(BuildContext context) async {
    final achievementController = TextEditingController();

    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Achievement'),
          content: TextField(
            controller: achievementController,
            decoration: const InputDecoration(
              hintText: 'Enter your achievement',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (achievementController.text.trim().isNotEmpty) {
                  controller.addAchievement(achievementController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } finally {
      achievementController.dispose();
    }
  }

  Future<void> _showEditAchievementsDialog(BuildContext context) async {
    final tempController = TextEditingController(
      text: controller.profileData.achievements.join('\n'),
    );

    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Achievements'),
          content: TextField(
            controller: tempController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Enter your achievements (one per line)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      tempController.dispose();
    }
  }
}