import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Professional Experience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                if (controller.hasUnsavedChanges)
                  const Chip(
                    label: Text(
                      'Unsaved Changes',
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEducationSection(),
            const SizedBox(height: 16),
            _buildExperienceSection(context),
            const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
            const Icon(Icons.work_history, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () => _showEditDialog(
                context: context,
                title: 'Edit Experience',
                controller: controller.experienceController,
                hint: 'Enter your experience (one per line)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
            const Icon(Icons.engineering, color: Colors.deepPurple),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Projects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepPurple),
              onPressed: () => _showEditDialog(
                context: context,
                title: 'Edit Projects',
                controller: controller.projectsController,
                hint: 'Enter your projects (one per line)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildList(controller.projectsController.text),
      ],
    );
  }

  Widget _buildList(String text) {
    final items = text.split('\n')..removeWhere((e) => e.isEmpty);

    return items.isEmpty
        ? const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
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
              items[index],
              style: const TextStyle(fontSize: 14, height: 1.5),
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
        title: Text(title),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.text = tempController.text;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => tempController.dispose());
  }
}