import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class JobPostsScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Posts')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? 'Enter a job title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Job Description'),
                validator: (value) => value!.isEmpty ? 'Enter a job description' : null,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                  child: Text('Post Job'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Get the current user ID
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        // Fetch the user's document from Firestore
                        DocumentSnapshot userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .get();

                        // Extract the companyId if it exists, otherwise use an empty string
                        String companyId = userDoc.get('companyId') ?? '';

                        // Call addJob with title, description, and companyId as separate arguments
                        FirestoreService().addJob(
                          _titleController.text,
                          _descriptionController.text,
                          companyId,  // Pass the companyId directly
                        );

                        // Reset the form after submission
                        _formKey.currentState!.reset();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to post job. Please log in.')),
                        );
                      }
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
