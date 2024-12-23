import 'package:flutter/material.dart';
import '../../../controller/profile_controller.dart';

class ResumeSection extends StatelessWidget {
  final ProfileController controller;

  const ResumeSection({Key? key, required this.controller}) : super(key: key);

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
              'Resume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildUploadArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            controller.profileData.resumeUrl.isEmpty ? Icons.upload_file : Icons.description,
            size: 48,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 8),
          Text(
            controller.profileData.resumeUrl.isEmpty
                ? 'Upload your resume (PDF)'
                : 'Resume uploaded successfully',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (controller.isParsingResume)
            const CircularProgressIndicator(color: Colors.deepPurple)
          else
            ElevatedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.uploadAndParseResume(context),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                controller.profileData.resumeUrl.isEmpty ? 'Select File' : 'Update Resume',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}