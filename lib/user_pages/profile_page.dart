import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileFormKey = GlobalKey<FormState>();
  String _qualification = '';
  String _jobProfile = '';
  String _resumeUrl = '';
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _qualification = userData['qualification'] ?? 'Please add the data';
        _jobProfile = userData['jobProfile'] ?? 'Please add the data';
        _resumeUrl = userData['resumeUrl'] ?? '';
      });
    } else {
      setState(() {
        _qualification = 'Please add the data';
        _jobProfile = 'Please add the data';
      });
    }
  }


  Future<void> _pickAndUploadResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _resumeFile = File(result.files.single.path!);
        });

        // Upload to Firebase Storage
        String userId = FirebaseAuth.instance.currentUser!.uid;
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('resumes')
            .child('$userId.pdf');

        await storageRef.putFile(_resumeFile!);
        String downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with the URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'resumeUrl': downloadUrl,
        });

        setState(() {
          _resumeUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload resume: $e')),
      );
    }
  }

  void _updateProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!.save();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'qualification': _qualification,
          'jobProfile': _jobProfile,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _profileFormKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _qualification,
                decoration: const InputDecoration(labelText: 'Qualification'),
                validator: (value) => value!.isEmpty || value == 'Please add the data'
                    ? 'Enter your qualification'
                    : null,
                onSaved: (value) => _qualification = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _jobProfile,
                decoration: const InputDecoration(labelText: 'Job Profile'),
                validator: (value) => value!.isEmpty || value == 'Please add the data'
                    ? 'Enter your job profile'
                    : null,
                onSaved: (value) => _jobProfile = value!,
              ),
              const SizedBox(height: 20),
              Text('Resume', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _resumeUrl.isNotEmpty
                  ? const Text('Resume uploaded successfully')
                  : const Text('No resume uploaded'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Resume (PDF)'),
                onPressed: _pickAndUploadResume,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Update Profile'),
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}