import 'package:flutter/material.dart';

import '../../../../controller/profile_controller.dart';
import '../../shared/profile_text_field.dart';


class ProfileHeader extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(context),
            const SizedBox(width: 16),
            Expanded(child: _buildPersonalInfo()),
          ],
        ),
        if (controller.hasUnsavedChanges)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.discardChanges(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Discard Changes'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => controller.saveChanges(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: controller.isImageLoading ? null : () => controller.uploadProfileImage(context),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple, width: 3),
                ),
                child: controller.isImageLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CircleAvatar(
                  radius: 58,
                  backgroundImage: controller.profileData.profileImageUrl.isNotEmpty
                      ? NetworkImage(controller.profileData.profileImageUrl)
                      : null,
                  child: controller.profileData.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLikesCounter(),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          controller: controller.nameController,
          labelText: 'Full Name',
          icon: Icons.person,
        ),
        const SizedBox(height: 8),
        ProfileTextField(
          controller: controller.emailController,
          labelText: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        ProfileTextField(
          controller: controller.collegeController,
          labelText: 'College',
          icon: Icons.school,
        ),
        const SizedBox(height: 8),
        ProfileTextField(
          controller: controller.collegeSessionController,
          labelText: 'College Session (YYYY-YYYY)',
          icon: Icons.date_range,
          keyboardType: TextInputType.datetime,
        ),
      ],
    );
  }

  Widget _buildLikesCounter() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: Colors.deepPurple, size: 20),
              SizedBox(width: 4),
              Text(
                'Company Likes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${controller.profileData.companyLikesCount}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const Text(
            'Total Likes',
            style: TextStyle(fontSize: 12, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}