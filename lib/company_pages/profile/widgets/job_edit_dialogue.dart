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
  late TextEditingController _newResponsibilityController;
  late TextEditingController _newQualificationController;
  String _selectedEmploymentType = 'Full-time';
  late List<String> _responsibilities;
  late List<String> _qualifications;

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
    _newResponsibilityController = TextEditingController();
    _newQualificationController = TextEditingController();
    _selectedEmploymentType = widget.job.employmentType;
    _responsibilities = List<String>.from(widget.job.responsibilities);
    _qualifications = List<String>.from(widget.job.qualifications);
  }

  Widget _buildListEditor({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required Function(String) onAdd,
    required Function(int) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 120.h),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  items[index],
                  style: TextStyle(fontSize: 14.sp),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(index),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add new ${title.toLowerCase()}',
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                style: TextStyle(fontSize: 14.sp),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    onAdd(value);
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.deepPurple),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Edit Job Details',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Job Title',
                      ),
                      SizedBox(height: 16.h),

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

                      _buildTextField(
                        controller: _locationController,
                        label: 'Location',
                      ),
                      SizedBox(height: 16.h),

                      _buildTextField(
                        controller: _salaryRangeController,
                        label: 'Salary Range (per annum)',
                      ),
                      SizedBox(height: 16.h),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),

                      _buildListEditor(
                        title: 'Responsibilities',
                        items: _responsibilities,
                        controller: _newResponsibilityController,
                        onAdd: (value) {
                          setState(() {
                            _responsibilities.add(value);
                          });
                        },
                        onDelete: (index) {
                          setState(() {
                            _responsibilities.removeAt(index);
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      _buildListEditor(
                        title: 'Qualifications',
                        items: _qualifications,
                        controller: _newQualificationController,
                        onAdd: (value) {
                          setState(() {
                            _qualifications.add(value);
                          });
                        },
                        onDelete: (index) {
                          setState(() {
                            _qualifications.removeAt(index);
                          });
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      final updates = {
                        'title': _titleController.text,
                        'description': _descriptionController.text,
                        'location': _locationController.text,
                        'salaryRange': _salaryRangeController.text,
                        'employmentType': _selectedEmploymentType,
                        'responsibilities': _responsibilities,
                        'qualifications': _qualifications,
                      };
                      widget.onUpdate(widget.job, updates);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    _newResponsibilityController.dispose();
    _newQualificationController.dispose();
    super.dispose();
  }
}