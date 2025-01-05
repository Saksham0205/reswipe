import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/applications.dart';
import 'filter_option.dart';

class FilterSection {
  final String id;
  final String title;
  final Set<String> values;
  final Set<String> selectedValues;
  final Function(String, bool) onSelected;
  final IconData icon;

  FilterSection({
    required this.id,
    required this.title,
    required this.values,
    required this.selectedValues,
    required this.onSelected,
    required this.icon,
  });
}

class FilterSectionWidget extends StatelessWidget {
  final FilterSection section;
  final bool isExpanded;
  final VoidCallback onToggle;

  const FilterSectionWidget({
    Key? key,
    required this.section,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: isExpanded ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(section.icon, color: Colors.deepPurple),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (section.selectedValues.isNotEmpty)
                          Text(
                            '${section.selectedValues.length} selected',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.deepPurple,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondChild: _buildExpandedContent(),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (section.values.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 8.h),
              Text(
                'No ${section.title.toLowerCase()} available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.selectedValues.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: section.selectedValues.map((value) {
                return Chip(
                  label: Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  backgroundColor: Colors.deepPurple,
                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                  onDeleted: () => section.onSelected(value, false),
                );
              }).toList(),
            ),
            SizedBox(height: 12.h),
          ],
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: section.values.map((value) {
              final isSelected = section.selectedValues.contains(value);
              return FilterChip(
                label: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : Colors.grey[800],
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) => section.onSelected(value, selected),
                selectedColor: Colors.deepPurple,
                backgroundColor: Colors.grey[50],
                checkmarkColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final List<Application> applications;
  final FilterOptions filterOptions;
  final Function(FilterOptions) onApplyFilters;

  const FilterDialog({
    Key? key,
    required this.applications,
    required this.filterOptions,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _currentFilters;
  String? _expandedSectionId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentFilters = FilterOptions.from(widget.filterOptions);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FilterSection> _buildFilterSections() {
    final applications = widget.applications;

    Set<String> getAllSkills() {
      final Set<String> skills = {};
      for (var app in applications) {
        for (var skill in app.skills) {
          skills.add(StringUtils.toTitleCase(skill.trim()));
        }
      }
      return skills;
    }

    return [
      FilterSection(
        id: 'skills',
        title: 'Skills',
        icon: Icons.code,
        values: _filterValues(getAllSkills()),
        selectedValues: _currentFilters.selectedSkills,
        onSelected: (skill, selected) {
          setState(() {
            _updateFilter(selected, skill, _currentFilters.selectedSkills);
          });
        },
      ),
      FilterSection(
        id: 'locations',
        title: 'Locations',
        icon: Icons.location_on,
        values: _filterValues(
          applications
              .map((app) => StringUtils.toTitleCase(app.jobLocation))
              .where((location) => location.isNotEmpty)
              .toSet(),
        ),
        selectedValues: _currentFilters.selectedLocations,
        onSelected: (location, selected) {
          setState(() {
            _updateFilter(selected, location, _currentFilters.selectedLocations);
          });
        },
      ),
      FilterSection(
        id: 'qualifications',
        title: 'Qualifications',
        icon: Icons.school,
        values: _filterValues(
          applications
              .map((app) => StringUtils.toTitleCase(app.qualification))
              .where((qual) => qual.isNotEmpty)
              .toSet(),
        ),
        selectedValues: _currentFilters.selectedQualifications,
        onSelected: (qual, selected) {
          setState(() {
            _updateFilter(
                selected, qual, _currentFilters.selectedQualifications);
          });
        },
      ),
      FilterSection(
        id: 'employment_types',
        title: 'Employment Types',
        icon: Icons.work,
        values: _filterValues(
          applications
              .map((app) => StringUtils.toTitleCase(app.jobEmploymentType))
              .where((type) => type.isNotEmpty)
              .toSet(),
        ),
        selectedValues: _currentFilters.selectedEmploymentTypes,
        onSelected: (type, selected) {
          setState(() {
            _updateFilter(
                selected, type, _currentFilters.selectedEmploymentTypes);
          });
        },
      ),
      FilterSection(
        id: 'colleges',
        title: 'Colleges',
        icon: Icons.account_balance,
        values: _filterValues(
          applications
              .map((app) => StringUtils.toTitleCase(app.college))
              .where((college) => college.isNotEmpty)
              .toSet(),
        ),
        selectedValues: _currentFilters.selectedColleges,
        onSelected: (college, selected) {
          setState(() {
            _updateFilter(selected, college, _currentFilters.selectedColleges);
          });
        },
      ),
      FilterSection(
        id: 'job_profiles',
        title: 'Job Profiles',
        icon: Icons.business_center,
        values: _filterValues(
          applications
              .map((app) => StringUtils.toTitleCase(app.jobProfile))
              .where((profile) => profile.isNotEmpty)
              .toSet(),
        ),
        selectedValues: _currentFilters.selectedJobProfiles,
        onSelected: (profile, selected) {
          setState(() {
            _updateFilter(
                selected, profile, _currentFilters.selectedJobProfiles);
          });
        },
      ),
    ];
  }
  Set<String> _filterValues(Set<String> values) {
    if (_searchQuery.isEmpty) return values;
    return values
        .where((value) => value.toLowerCase().contains(_searchQuery))
        .toSet();
  }
  void _updateFilter(bool selected, String value, Set<String> filterSet) {
    if (selected) {
      filterSet.add(value);
    } else {
      filterSet.remove(value);
    }
  }

  int get _totalSelectedFilters =>
      _currentFilters.selectedSkills.length +
          _currentFilters.selectedLocations.length +
          _currentFilters.selectedQualifications.length +
          _currentFilters.selectedEmploymentTypes.length +
          _currentFilters.selectedColleges.length +
          _currentFilters.selectedJobProfiles.length;

  @override
  Widget build(BuildContext context) {
    final filterSections = _buildFilterSections();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: filterSections.length,
                itemBuilder: (context, index) {
                  final section = filterSections[index];
                  return FilterSectionWidget(
                    section: section,
                    isExpanded: _expandedSectionId == section.id,
                    onToggle: () {
                      setState(() {
                        _expandedSectionId =
                        _expandedSectionId == section.id ? null : section.id;
                      });
                    },
                  );
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Applications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          if (_totalSelectedFilters > 0)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilters.reset();
                });
              },
              icon: Icon(
                Icons.refresh,
                size: 16.sp,
                color: Colors.red[400],
              ),
              label: Text(
                'Reset All',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red[400],
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search filters...',
          prefixIcon: Icon(Icons.search, size: 20.sp),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, size: 20.sp),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(_currentFilters);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                _totalSelectedFilters > 0
                    ? 'Apply ($_totalSelectedFilters)'
                    : 'Apply',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StringUtils {
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}