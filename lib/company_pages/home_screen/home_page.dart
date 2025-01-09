import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reswipe/company_pages/home_screen/rejected_screen.dart';
import 'package:reswipe/company_pages/home_screen/shortlisted_screen.dart';
import '../../State_management/company_backend.dart';
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

  Future<void> _handleRefresh() async {
    context.read<JobBloc>().add(Refresh());
    return Future.delayed(const Duration(seconds: 1)); // Minimum refresh time
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
            body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: Stack(
                children: [
                  _buildMainContent(state),
                  if (_showJobFilter)
                    _buildJobFilterOverlay(context, state),
                  if (state.lastSwipedApplication != null)
                    _buildFloatingUndoButton(context, state),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: _buildAppBar(context, null),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child: EmptyState(
              onRefresh: () => context.read<JobBloc>().add(Refresh()),
            ),
          ),
        );
      },
    );
  }
  Widget _buildFloatingUndoButton(BuildContext context, JobsLoaded state) {
    if (state.lastSwipedApplication == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 100.h,
      right: 16.w,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.withOpacity(0.9),
        onPressed: () {
          context.read<JobBloc>().add(UndoSwipe(state.lastSwipedApplication!));
        },
        icon: const Icon(Icons.undo, color: Colors.white),
        label: const Text(
          'Undo',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
                        final totalApplications = state.applicationCountByJob[job.id] ?? 0;
                        final shortlistedCount = state.shortlistedByJob[job.id]?.length ?? 0;
                        final rejectedCount = state.rejectedByJob[job.id]?.length ?? 0;
                        final pendingCount = state.applicationsByJob[job.id]?.length ?? 0;
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
                                      if (shortlistedCount > 0)
                                        _buildStatChip(
                                          Icons.thumb_up_outlined,
                                          '$shortlistedCount shortlisted',
                                          Colors.green,
                                        ),
                                      if (rejectedCount > 0)
                                        _buildStatChip(
                                          Icons.thumb_down_outlined,
                                          '$rejectedCount rejected',
                                          Colors.red,
                                        ),
                                      if (pendingCount > 0)
                                        _buildStatChip(
                                          Icons.pending_outlined,
                                          '$pendingCount pending',
                                          Colors.orange,
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
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider.value(
                                          value: BlocProvider.of<JobBloc>(context),
                                          child: ShortlistedScreen(
                                            jobId: job.id,
                                            jobTitle: job.title,
                                          ),
                                        ),
                                      ),
                                    ),
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
    final selectedJob = state.selectedJob;
    if (selectedJob == null) {
      return const Center(
        child: Text('Please select a job to view applications'),
      );
    }

    final jobId = selectedJob.id;
    final totalApplications = state.applicationCountByJob[jobId] ?? 0;
    final shortlisted = state.shortlistedByJob[jobId]?.length ?? 0;
    final rejected = state.rejectedByJob[jobId]?.length ?? 0;

    // Get only pending applications (not filtered)
    final currentApplications = state.applicationsByJob[jobId] ?? [];

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
              applications: currentApplications,
              controller: _cardController,
              animation: _animation,
              onSwipe: (application, isRightSwipe) {
                context.read<JobBloc>().add(
                  SwipeApplication(
                    application: application,
                    isRightSwipe: isRightSwipe,
                  ),
                );
              },
              onReset: () {
                context.read<JobBloc>().add(
                  ResetJobApplications(selectedJob.id),
                );
              },
              lastSwipedApplication: state.lastSwipedApplication,
              totalApplications: totalApplications,
              swipedLeft: rejected,
              swipedRight: shortlisted,
            ),
          ),
        ],
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

    final jobBloc = BlocProvider.of<JobBloc>(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: jobBloc),
          ],
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
    // Get the current JobBloc instance
    final jobBloc = BlocProvider.of<JobBloc>(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: jobBloc),
          ],
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
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Use BlocProvider.value to maintain the same bloc instance
    return BlocProvider.value(
      value: BlocProvider.of<JobBloc>(context),
      child: child,
    );
  }
}