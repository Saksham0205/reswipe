import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/company_state.dart';
import 'components/applications_list.dart';
import 'widgets/loading_shimmer.dart';
import 'widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobBloc()..add(LoadJobs()),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with SingleTickerProviderStateMixin {
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
            onRefresh: () => context.read<JobBloc>().add(LoadJobs()),
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
        icon: Icon(Icons.work, size: 20.sp,color: Colors.white,),
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
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                Container(
                  constraints: BoxConstraints(maxHeight: 300.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.jobs.length,
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return ListTile(
                        title: Text(job.title),
                        subtitle: Text(job.companyName),
                        trailing: Text(
                          '${state.shortlistedApplications.where((app) => app.jobId == job.id).length} candidates',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 12.sp,
                          ),
                        ),
                        onTap: () {
                          context.read<JobBloc>().add(SelectJob(job));
                          setState(() => _showJobFilter = false);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
              applications: state.applications,
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
}