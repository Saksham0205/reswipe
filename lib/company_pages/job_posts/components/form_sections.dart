import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_text_field.dart';

class FormSections extends StatelessWidget {
  final int currentStep;
  final Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> focusNodes;
  final String employmentType;
  final Function(String) onEmploymentTypeChanged;
  final Function() onFieldChanged;

  const FormSections({
    super.key,
    required this.currentStep,
    required this.controllers,
    required this.focusNodes,
    required this.employmentType,
    required this.onEmploymentTypeChanged,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
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
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controllers['title']!,
          focusNode: focusNodes['title']!,
          label: 'Job Title',
          icon: Icons.work,
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controllers['description']!,
          focusNode: focusNodes['description']!,
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
          focusNode: focusNodes['responsibilities']!,
          label: 'Responsibilities',
          icon: Icons.list,
          maxLines: 5,
          hint: 'Enter key responsibilities (one per line)',
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controllers['qualifications']!,
          focusNode: focusNodes['qualifications']!,
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
        SalaryInputField(
          controller: controllers['salaryRange']!,
          focusNode: focusNodes['salaryRange']!,
          onFieldChanged: onFieldChanged,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controllers['location']!,
          focusNode: focusNodes['location']!,
          label: 'Location',
          icon: Icons.location_on,
          onChanged: (_) => onFieldChanged(),
        ),
        SizedBox(height: 16.h),
        _buildEmploymentTypeDropdown(),
      ],
    );
  }

  Widget _buildEmploymentTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
        color: Colors.deepPurple.shade50,
      ),
      child: DropdownButtonFormField<String>(
        value: employmentType,
        decoration: InputDecoration(
          labelText: 'Employment Type',
          labelStyle: TextStyle(
            color: Colors.deepPurple.shade700,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.business_center_rounded,
            color: Colors.deepPurple.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          color: Colors.deepPurple,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.deepPurple.shade900,
          fontSize: 16,
        ),
        items: [
          'Full-time',
          'Part-time',
          'Contract',
          'Internship',
          'Freelance',
          'Remote'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
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

enum PaymentFrequency {
  perMonth('per month'),
  perYear('per year');

  final String label;
  const PaymentFrequency(this.label);
}
class SalaryData {
  final String amount;
  final PaymentFrequency frequency;

  SalaryData({
    required this.amount,
    required this.frequency,
  });

  @override
  String toString() => '$amount ${frequency.label}';
}
class SalaryInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function() onFieldChanged;

  const SalaryInputField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  State<SalaryInputField> createState() => _SalaryInputFieldState();
}
class _SalaryInputFieldState extends State<SalaryInputField> {
  PaymentFrequency _frequency = PaymentFrequency.perYear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.deepPurple.shade200),
              color: Colors.deepPurple.shade50,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.deepPurple.shade900,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Salary Range',
                labelStyle: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  color: Colors.deepPurple.shade400,
                  size: 20.w,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.w),
                ),
              ),
              onChanged: (_) => widget.onFieldChanged(),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.deepPurple.shade200),
              color: Colors.deepPurple.shade50,
            ),
            child: DropdownButtonFormField<PaymentFrequency>(
              value: _frequency,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.w),
                ),
              ),
              style: TextStyle(
                color: Colors.deepPurple.shade900,
                fontSize: 16.sp,
              ),
              dropdownColor: Colors.white,
              items: PaymentFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(
                    frequency.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _frequency = newValue;
                  });
                  widget.onFieldChanged();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}