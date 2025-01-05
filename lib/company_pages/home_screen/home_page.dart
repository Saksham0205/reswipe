import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reswipe/company_pages/home_screen/shortlisted_screen.dart';
import '../../state_management/company_state.dart';
import 'components/applications_list.dart';
import 'widgets/app_bar.dart';
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
  int _currentJobIndex = 0;

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
            appBar: HomeAppBar(
              favoriteApplications: state.shortlistedApplications,
              onFavoritesTap: () => {},
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple.shade50, Colors.white],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Text(
                        'Jobs Dashboard',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  _buildJobList(state),
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
            ),
          );
        }

        // For empty state
        return Scaffold(
          appBar: HomeAppBar(
            favoriteApplications: const [], // Empty list for empty state
            onFavoritesTap: () {}, // Empty callback for empty state
          ),
          body: EmptyState(
            onRefresh: () => context.read<JobBloc>().add(LoadJobs()),
          ),
        );
      },
    );
  }
  Widget _buildJobList(JobsLoaded state) {
    return SizedBox(
      height: 130.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.jobs.length,
        itemBuilder: (context, index) {
          final job = state.jobs[index];
          final shortlistedCount = state.shortlistedApplications
              .where((app) => app.jobId == job.id)
              .length;

          return Container(
            width: 200.w,
            margin: EdgeInsets.all(4.w),
            child: Card(
              elevation: _currentJobIndex == index ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: _currentJobIndex == index
                      ? Colors.deepPurple
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() => _currentJobIndex = index);
                  context.read<JobBloc>().add(SelectJob(job));
                },
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$shortlistedCount shortlisted',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.deepPurple,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToShortlisted(
                              context,
                              job.id,
                              job.title,
                            ),
                            child: Text(
                              'View',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  void _navigateToShortlisted(BuildContext context, String jobId, String jobTitle) {
    try {
      final jobBloc = context.read<JobBloc>();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: jobBloc,
            child: ShortlistedScreen(
              jobId: jobId,
              jobTitle: jobTitle,
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error accessing JobBloc: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
        ),
      );
    }
  }
}