import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_text_field.dart';

class FormSections extends StatelessWidget {
  final int currentStep;
  final Map<String, TextEditingController> controllers;
  final String employmentType;
  final Function(String) onEmploymentTypeChanged;
  final Function() onFieldChanged;

  const FormSections({
    Key? key,
    required this.currentStep,
    required this.controllers,
    required this.employmentType,
    required this.onEmploymentTypeChanged,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _buildCurrentSection(),
    );
  }

  Widget _buildCurrentSection() {
    switch (currentStep) {
      case 0:
        return _buildBasicInfoSection();
      case 1:
        return _buildDetailsSection();
      case 2:
        return _buildRequirementsSection();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controllers['title']!,
          label: 'Job Title',
          icon: Icons.work,
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controllers['description']!,
          label: 'Job Description',
          icon: Icons.description,
          maxLines: 5,
          onChanged: (_) => onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controllers['responsibilities']!,
          label: 'Responsibilities',
          icon: Icons.list,
          maxLines: 5,
          hint: 'Enter key responsibilities (one per line)',
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controllers['qualifications']!,
          label: 'Qualifications',
          icon: Icons.school,
          maxLines: 5,
          hint: 'Enter required qualifications (one per line)',
          onChanged: (_) => onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controllers['salaryRange']!,
                label: 'Salary Range',
                icon: Icons.currency_rupee,
                onChanged: (_) => onFieldChanged(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomTextField(
                controller: controllers['location']!,
                label: 'Location',
                icon: Icons.location_on,
                onChanged: (_) => onFieldChanged(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildEmploymentTypeDropdown(),
      ],
    );
  }

  Widget _buildEmploymentTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: employmentType,
        decoration: InputDecoration(
          labelText: 'Employment Type',
          prefixIcon: Icon(Icons.business_center),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        items: ['Full-time', 'Part-time', 'Contract', 'Internship']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onEmploymentTypeChanged(newValue);
            onFieldChanged();
          }
        },
      ),
    );
  }
}