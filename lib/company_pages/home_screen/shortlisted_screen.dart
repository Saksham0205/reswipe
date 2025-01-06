import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../State_management/Company_state.dart';
import '../../models/company_model/applications.dart';
import 'favourites/components/application_details.dart';
import 'filters_shortlist_screen/filter_option.dart';
import 'filters_shortlist_screen/filter_section.dart';

class ShortlistedScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const ShortlistedScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  _ShortlistedScreenState createState() => _ShortlistedScreenState();
}

class _ShortlistedScreenState extends State<ShortlistedScreen> {
  String _searchQuery = '';
  bool _isLoading = true;
  late FilterOptions filterOptions;
  List<Application> filteredApplications = [];
  List<Application> originalApplications = [];

  void _applyFilters() {
    setState(() {
      filteredApplications = originalApplications.where((application) {
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final nameLower = application.applicantName.toLowerCase();
          final skillsLower = application.skills
              .expand((skill) => skill.split(','))
              .map((s) => s.trim().toLowerCase())
              .join(' ');
          matchesSearch = nameLower.contains(searchLower) ||
              skillsLower.contains(searchLower);
        }

        bool matchesFilters = true;

        if (filterOptions.selectedSkills.isNotEmpty) {
          final appSkills = application.skills
              .expand((skill) => skill.split(','))
              .map((s) => StringUtils.toTitleCase(s.trim()))
              .toSet();
          matchesFilters = appSkills
              .any((skill) => filterOptions.selectedSkills.contains(skill));
        }

        if (filterOptions.selectedLocations.isNotEmpty) {
          matchesFilters = matchesFilters &&
              filterOptions.selectedLocations
                  .contains(StringUtils.toTitleCase(application.jobLocation));
        }

        if (filterOptions.selectedQualifications.isNotEmpty) {
          matchesFilters = matchesFilters &&
              filterOptions.selectedQualifications
                  .contains(StringUtils.toTitleCase(application.qualification));
        }

        if (filterOptions.selectedEmploymentTypes.isNotEmpty) {
          matchesFilters = matchesFilters &&
              filterOptions.selectedEmploymentTypes.contains(
                  StringUtils.toTitleCase(application.jobEmploymentType));
        }

        if (filterOptions.selectedColleges.isNotEmpty) {
          matchesFilters = matchesFilters &&
              filterOptions.selectedColleges
                  .contains(StringUtils.toTitleCase(application.college));
        }

        if (filterOptions.selectedJobProfiles.isNotEmpty) {
          matchesFilters = matchesFilters &&
              filterOptions.selectedJobProfiles
                  .contains(StringUtils.toTitleCase(application.jobProfile));
        }

        return matchesSearch && matchesFilters;
      }).toList();
    });
  }
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        applications: originalApplications,
        filterOptions: filterOptions,
        onApplyFilters: (newFilters) {
          setState(() {
            filterOptions = newFilters;
            _applyFilters();
          });
        },
      ),
    );
  }
  void _updateApplicationLists() {
    if (context.read<JobBloc>().state is JobsLoaded) {
      final state = context.read<JobBloc>().state as JobsLoaded;
      originalApplications = state.shortlistedApplications
          .where((app) => app.jobId == widget.jobId)
          .toList();
      _applyFilters();
    }
  }
  void _updateSearchResults(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }
  Future<void> _showRemoveConfirmation(
      Application application,
      JobBloc bloc,
      ) async {
    final result = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
        title: Text(
          'Remove Candidate',
          style: TextStyle(fontSize: 18.sp),
        ),
        content: Text(
          'Are you sure you want to remove ${application.applicantName} from the shortlist?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Remove',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),);if (result ?? false) {
      bloc.add(RemoveFromShortlistEvent(
        application: application,
        jobId: widget.jobId,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${application.applicantName} removed from shortlist'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // Use bloc.add to dispatch the AddToShortlist event
                bloc.add(AddToShortlistEvent(
                  application: application,
                  jobId: widget.jobId,
                ));
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    filterOptions = FilterOptions();
    context.read<JobBloc>().add(LoadJobs());
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateApplicationLists();
        });
      }
    });
  }

  @override
  void didUpdateWidget(ShortlistedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateApplicationLists();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is JobsLoaded) {
          _updateApplicationLists();
        }
      },
      builder: (context, state) {
        if (state is JobInitial || state is JobLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is JobError) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shortlisted Candidates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  widget.jobTitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  size: 24.sp,
                  color: filterOptions.hasActiveFilters
                      ? Colors.amber
                      : Colors.white,
                ),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildStatisticsCards(originalApplications),
              Expanded(
                child: _isLoading
                    ? _buildLoadingShimmer()
                    : _buildApplicationsList(
                  filteredApplications,
                  context.read<JobBloc>(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2.h),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: TextField(
        onChanged: _updateSearchResults,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search by name or skills...',
          hintStyle: TextStyle(fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
  Widget _buildStatisticsCards(List<Application> applications) {
    final newToday = applications
        .where((app) =>
    app.timestamp?.isAfter(DateTime.now().subtract(const Duration(days: 1))) ??
        false)
        .length;

    final pendingReview = applications
        .where((app) => app.status == 'shortlisted')
        .length;

    return Container(
      height: 115.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildStatCard(
            'Total Shortlisted',
            applications.length.toString(),
            Icons.people_outline,
            Colors.blue,
          ),
          _buildStatCard(
            'New Today',
            newToday.toString(),
            Icons.today,
            Colors.green,
          ),
          _buildStatCard(
            'Pending Review',
            pendingReview.toString(),
            Icons.pending_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            offset: Offset(0, 2.h),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 120.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
    );
  }
  Widget _buildApplicationsList(List<Application> applications, JobBloc bloc) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 40.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _searchQuery.isEmpty
                  ? 'No shortlisted candidates yet'
                  : 'No candidates match your search',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: applications.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        final application = applications[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _showRemoveConfirmation(application, bloc),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Remove',
              ),
            ],
          ),
          child: _buildApplicationCard(application, bloc),
        );
      },
    );
  }
  Widget _buildApplicationCard(Application application, JobBloc bloc) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showRemoveConfirmation(application, bloc),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Remove',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          onTap: () => _showApplicationDetails(application),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        application.applicantName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.applicantName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            application.jobTitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeago.format(application.timestamp ?? DateTime.now()),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: application.skills.map((skill) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showApplicationDetails(Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => ApplicationDetailsSheet(
          application: application,
        ),
      ),
    );
  }
}