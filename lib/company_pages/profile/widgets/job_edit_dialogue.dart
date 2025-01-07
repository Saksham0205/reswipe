import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/job.dart';

class JobEditDialog extends StatefulWidget {
  final Job job;
  final Function(Job, Map<String, dynamic>) onUpdate;

  const JobEditDialog({
    super.key,
    required this.job,
    required this.onUpdate,
  });

  @override
  _JobEditDialogState createState() => _JobEditDialogState();
}

class _JobEditDialogState extends State<JobEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _salaryRangeController;
  String _selectedEmploymentType = 'Full-time';

  final List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(text: widget.job.description);
    _locationController = TextEditingController(text: widget.job.location);
    _salaryRangeController = TextEditingController(text: widget.job.salaryRange);
    _selectedEmploymentType = widget.job.employmentType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Edit Job Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Job Title Field
              _buildTextField(
                controller: _titleController,
                label: 'Job Title',
              ),
              SizedBox(height: 16.h),

              // Employment Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedEmploymentType,
                items: _employmentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmploymentType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Employment Type',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Location',
              ),
              SizedBox(height: 16.h),

              // Salary Range Field with "(per annum)"
              _buildTextField(
                controller: _salaryRangeController,
                label: 'Salary Range (per annum)',
              ),
              SizedBox(height: 16.h),

              // Description Field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),

        // Save Button
        ElevatedButton(
          onPressed: () {
            final updates = {
              'title': _titleController.text,
              'description': _descriptionController.text,
              'location': _locationController.text,
              'salaryRange': _salaryRangeController.text,
              'employmentType': _selectedEmploymentType,
            };
            widget.onUpdate(widget.job, updates);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: const Text('Save',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
      style: TextStyle(fontSize: 14.sp),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryRangeController.dispose();
    super.dispose();
  }
}
