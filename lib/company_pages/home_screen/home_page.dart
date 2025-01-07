import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reswipe/company_pages/home_screen/rejected_screen.dart';
import 'package:reswipe/company_pages/home_screen/shortlisted_screen.dart';
import '../../State_management/Company_state.dart';
import 'components/applications_list.dart';
import 'widgets/loading_shimmer.dart';
import 'widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state is JobInitial) {
          context.read<JobBloc>().add(LoadJobs());
        }
        return const HomeScreenContent();
      },
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  late CardSwiperController _cardController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showJobFilter = false;

  @override
  void initState() {
    super.initState();
    _cardController = CardSwiperController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is JobLoading) {
          return const LoadingShimmer();
        }
        if (state is JobsLoaded) {
          return Scaffold(
            appBar: _buildAppBar(context, state),
            body: Stack(
              children: [
                _buildMainContent(state),
                if (_showJobFilter)
                  _buildJobFilterOverlay(context, state),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: _buildAppBar(context, null),
          body: EmptyState(
            onRefresh: () => context.read<JobBloc>().add(Refresh()),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, JobsLoaded? state) {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        'Reswipe',
        style: GoogleFonts.pacifico(
          fontSize: 20.sp,
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: 200.w),
            child: _buildJobSelector(context, state),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildJobSelector(BuildContext context, JobsLoaded? state) {
    final selectedJob = state?.selectedJob;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _showJobFilter = !_showJobFilter;
          });
        },
        icon: Icon(Icons.work, size: 20.sp, color: Colors.white,),
        label: Text(
          selectedJob?.title ?? 'Select Job',
          style: TextStyle(fontSize: 14.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildJobFilterOverlay(BuildContext context, JobsLoaded state) {
    return GestureDetector(
      onTap: () => setState(() => _showJobFilter = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Job Position',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.jobs.length,
                      itemBuilder: (context, index) {
                        final job = state.jobs[index];
                        final totalApplications = state.applicationsByJob[job.id]?.length ?? 0;
                        final shortlistedCount = state.shortlistedByJob[job.id]?.length ?? 0;
                        final rejectedCount = state.rejectedByJob[job.id]?.length ?? 0;
                        final pendingCount = totalApplications - shortlistedCount - rejectedCount;

                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.companyName,
                                    style: TextStyle(fontSize: 14.sp),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Wrap(
                                    spacing: 8.w,
                                    runSpacing: 4.h,
                                    children: [
                                      _buildStatChip(
                                        Icons.person_outline,
                                        '$totalApplications total',
                                        Colors.blue,
                                      ),
                                      _buildStatChip(
                                        Icons.thumb_up_outlined,
                                        '$shortlistedCount right',
                                        Colors.green,
                                      ),
                                      _buildStatChip(
                                        Icons.thumb_down_outlined,
                                        '$rejectedCount left',
                                        Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Wrap(
                                spacing: 8.w,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up_outlined, color: Colors.green),
                                    onPressed: () => NavigationHelper.navigateToShortlisted(context, job.id, job.title),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.thumb_down_outlined, color: Colors.red),
                                    onPressed: () => NavigationHelper.navigateToRejected(context, job.id, job.title),
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.read<JobBloc>().add(SelectJob(job));
                                setState(() => _showJobFilter = false);
                              },
                            ),
                            if (index < state.jobs.length - 1)
                              Divider(height: 1, color: Colors.grey.shade300),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(JobsLoaded state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Expanded(
            child: ApplicationList(
              applications: state.filteredApplications,
              controller: _cardController,
              animation: _animation,
              onSwipe: (application) {
                context.read<JobBloc>().add(
                  SwipeApplication(
                    application: application,
                    isRightSwipe: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  void navigateToShortlisted(BuildContext context, String jobId, String jobTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<JobBloc>(),
          child: ShortlistedScreen(
            jobId: jobId,
            jobTitle: jobTitle,
          ),
        ),
      ),
    );
  }
  void navigateToRejected(BuildContext context, String jobId, String jobTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<JobBloc>(),
          child: RejectedScreen(
            jobId: jobId,
            jobTitle: jobTitle,
          ),
        ),
      ),
    );
  }
}

class NavigationHelper {
  static void navigateToShortlisted(
      BuildContext context,
      String jobId,
      String jobTitle,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JobScreenWrapper(
          jobId: jobId,
          jobTitle: jobTitle,
          child: ShortlistedScreen(
            jobId: jobId,
            jobTitle: jobTitle,
          ),
        ),
      ),
    );
  }

  static void navigateToRejected(
      BuildContext context,
      String jobId,
      String jobTitle,
      ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JobScreenWrapper(
          jobId: jobId,
          jobTitle: jobTitle,
          child: RejectedScreen(
            jobId: jobId,
            jobTitle: jobTitle,
          ),
        ),
      ),
    );
  }
}
class JobScreenWrapper extends StatelessWidget {
  final String jobId;
  final String jobTitle;
  final Widget child;

  const JobScreenWrapper({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use BlocProvider.value to maintain the same bloc instance
    return BlocProvider.value(
      value: BlocProvider.of<JobBloc>(context),
      child: child,
    );
  }
}