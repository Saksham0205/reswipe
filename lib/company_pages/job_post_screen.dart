import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_model/job.dart';
import '../services/firestore_service.dart';

class JobPostsScreen extends StatefulWidget {
  @override
  _JobPostsScreenState createState() => _JobPostsScreenState();
}

class _JobPostsScreenState extends State<JobPostsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _salaryRangeController = TextEditingController();
  final _locationController = TextEditingController();
  String _employmentType = 'Full-time';

  // Helper function to show error messages
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper function to validate form
  bool _validateForm(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter a job title');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter a job description');
      return false;
    }
    if (_responsibilitiesController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter at least one responsibility');
      return false;
    }
    if (_qualificationsController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter at least one qualification');
      return false;
    }
    if (_salaryRangeController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter a salary range');
      return false;
    }
    if (_locationController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter a location');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Job title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Job Description *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Job description is required';
                    }
                    return null;
                  },
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Responsibilities *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _responsibilitiesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter key responsibilities (one per line) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'At least one responsibility is required';
                    }
                    return null;
                  },
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Qualifications *',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _qualificationsController,
                  decoration: const InputDecoration(
                    hintText: 'Enter required qualifications (one per line) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'At least one qualification is required';
                    }
                    return null;
                  },
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _salaryRangeController,
                        decoration: const InputDecoration(
                          labelText: 'Salary Range *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Salary range is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  decoration: const InputDecoration(
                    labelText: 'Employment Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Full-time', 'Part-time', 'Contract', 'Internship']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _employmentType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  child: const Text('Post Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _validateForm(context)) {
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        try {
                          DocumentSnapshot userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get();

                          String companyId = userDoc.get('companyId') ?? '';
                          String companyName = userDoc.get('companyName') ?? '';

                          if (companyId.isEmpty || companyName.isEmpty) {
                            _showErrorSnackBar(context, 'Company information is missing. Please update your profile.');
                            return;
                          }

                          Job newJob = Job(
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            responsibilities: _responsibilitiesController.text.split('\n')
                                .where((line) => line.trim().isNotEmpty)
                                .toList(),
                            qualifications: _qualificationsController.text.split('\n')
                                .where((line) => line.trim().isNotEmpty)
                                .toList(),
                            salaryRange: _salaryRangeController.text.trim(),
                            location: _locationController.text.trim(),
                            employmentType: _employmentType,
                            companyId: companyId,
                            companyName: companyName,
                          );

                          await AuthService().addJob(newJob);

                          _formKey.currentState!.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Job posted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          _showErrorSnackBar(context, 'Error posting job: ${e.toString()}');
                        }
                      } else {
                        _showErrorSnackBar(context, 'Please log in to post a job');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}