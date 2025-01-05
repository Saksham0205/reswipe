import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../State_management/Company_state.dart';
import '../../models/company_model/applications.dart';
import 'favourites/components/application_details.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> selectedSkills = [];
  String? selectedExperience;
  String? selectedQualification;
  List<String> availableSkills = [];
  bool isLoading = false;

  final List<String> qualifications = [
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Ph.D.',
    'High School Diploma',
    'Associate\'s Degree'
  ];

  final List<String> experienceLevels = [
    '0-2 years',
    '2-5 years',
    '5-8 years',
    '8+ years'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableSkills();
  }

  Future<void> _loadAvailableSkills() async {
    setState(() => isLoading = true);
    try {
      // Fetch skills from applications collection
      final QuerySnapshot applications = await FirebaseFirestore.instance
          .collection('applications')
          .limit(50)
          .get();

      final Set<String> uniqueSkills = {};
      for (var doc in applications.docs) {
        final application = Application.fromFirestore(doc);
        uniqueSkills.addAll(application.skills);
      }

      setState(() {
        availableSkills = uniqueSkills.toList()..sort();
      });
    } catch (e) {
      print('Error loading skills: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    context.read<JobBloc>().add(FilterApplications(
      searchQuery: _searchController.text,
      location: _locationController.text,
      skills: selectedSkills,
      experience: selectedExperience,
      qualification: selectedQualification,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Search Applications'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name or job profile...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Filter by location...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.location_on, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFiltersSection(),
                  BlocBuilder<JobBloc, JobState>(
                    builder: (context, state) {
                      if (state is JobLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is JobsLoaded) {
                        if (state.filteredApplications.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No applications match your filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.filteredApplications.length,
                          itemBuilder: (context, index) {
                            final application = state.filteredApplications[index];
                            return ApplicationListTile(
                              application: application,
                              onTap: () => _showApplicationDetails(application),
                            );
                          },
                        );
                      }

                      return const Center(child: Text('No applications found'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSkills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill);
                    } else {
                      selectedSkills.remove(skill);
                    }
                    _applyFilters();
                  });
                },
                selectedColor: Colors.deepPurple.withOpacity(0.2),
                checkmarkColor: Colors.deepPurple,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qualifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedQualification,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: qualifications.map((qual) {
              return DropdownMenuItem(value: qual, child: Text(qual));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedQualification = value;
                _applyFilters();
              });
            },
            hint: const Text('Select Qualification'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Experience',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedExperience,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: experienceLevels.map((exp) {
              return DropdownMenuItem(value: exp, child: Text(exp));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedExperience = value;
                _applyFilters();
              });
            },
            hint: const Text('Select Experience Level'),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailsSheet(application: application),
    );
  }
}

// Application list tile widget
class ApplicationListTile extends StatelessWidget {
  final Application application;
  final VoidCallback onTap;

  const ApplicationListTile({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: application.profileImageUrl.isNotEmpty
              ? NetworkImage(application.profileImageUrl)
              : null,
          backgroundColor: application.profileImageUrl.isEmpty
              ? Colors.deepPurple.withOpacity(0.1)
              : null,
          child: application.profileImageUrl.isEmpty
              ? Text(
            application.applicantName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        title: Text(
          application.applicantName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(application.jobProfile),
            Text(
              application.experience.isNotEmpty
                  ? application.experience.first
                  : 'Experience not specified',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Skills', application.skills),
                const SizedBox(height: 8),
                _buildInfoSection('Qualifications', [application.qualification]),
                const SizedBox(height: 8),
                _buildInfoSection('Location', [application.jobLocation]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) => Chip(
            label: Text(
              item,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
          )).toList(),
        ),
      ],
    );
  }
}