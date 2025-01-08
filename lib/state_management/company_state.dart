import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../company_pages/profile/utils/job_sorter.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';

// Events
abstract class JobEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {}
class Refresh extends JobEvent {}
class SelectJob extends JobEvent {
  final Job job;
  SelectJob(this.job);
  @override
  List<Object?> get props => [job];
}
class DeleteJob extends JobEvent {
  final String jobId;
  DeleteJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
class SortJobs extends JobEvent {
  final SortOrder order;
  SortJobs(this.order);

  @override
  List<Object?> get props => [order];
}
class FilterJobs extends JobEvent {
  final String filter;
  FilterJobs(this.filter);

  @override
  List<Object?> get props => [filter];
}
class UpdateJob extends JobEvent {
  final Job job;
  final Map<String, dynamic> updates;

  UpdateJob(this.job, this.updates);

  @override
  List<Object?> get props => [job, updates];
}

class SwipeApplication extends JobEvent {
  final Application application;
  final bool isRightSwipe;

  SwipeApplication({required this.application, required this.isRightSwipe});
  @override
  List<Object?> get props => [application, isRightSwipe];
}

class FilterApplications extends JobEvent {
  final String? searchQuery;
  final String? location;
  final List<String>? skills;
  final String? experience;
  final String? qualification;
  final String? employmentType;

  FilterApplications({
    this.searchQuery,
    this.location,
    this.skills,
    this.experience,
    this.qualification,
    this.employmentType,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    location,
    skills,
    experience,
    qualification,
    employmentType,
  ];
}

class AddJob extends JobEvent {
  final Job job;
  AddJob(this.job);
  @override
  List<Object?> get props => [job];
}

// States
abstract class JobState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobError extends JobState {
  final String message;
  JobError(this.message);
  @override
  List<Object?> get props => [message];
}

class JobsLoaded extends JobState {
  List<Application> getApplicationsForJob(String jobId) {
    return applicationsByJob[jobId] ?? [];
  }

  // Add a method to get shortlisted applications for a job
  List<Application> getShortlistedForJob(String jobId) {
    return shortlistedByJob[jobId] ?? [];
  }

  // Add a method to get rejected applications for a job
  List<Application> getRejectedForJob(String jobId) {
    return rejectedByJob[jobId] ?? [];
  }
  final List<Job> jobs;
  final Job? selectedJob;
  final Map<String, List<Application>> applicationsByJob;
  final Map<String, List<Application>> shortlistedByJob;
  final Map<String, List<Application>> rejectedByJob;
  final Map<String, Set<String>> swipedApplicationIdsByJob;
  final List<Application> filteredApplications;
  final Map<String, dynamic> filters;
  final Map<String, int> applicationCountByJob;
  final SortOrder sortOrder; // Added
  final String jobFilter;

  JobsLoaded({
    required this.jobs,
    this.selectedJob,
    required this.applicationsByJob,
    required this.shortlistedByJob,
    required this.rejectedByJob,
    required this.swipedApplicationIdsByJob,
    List<Application>? filteredApplications,
    this.filters = const {},
    required this.applicationCountByJob,
    this.sortOrder = SortOrder.newest, // Default value
    this.jobFilter = 'All',
  }) : filteredApplications = filteredApplications ??
      (selectedJob != null ? applicationsByJob[selectedJob.id] ?? [] : []);

  @override
  List<Object?> get props => [
    jobs,
    selectedJob,
    applicationsByJob,
    shortlistedByJob,
    rejectedByJob,
    swipedApplicationIdsByJob,
    filteredApplications,
    filters,
    applicationCountByJob,
    sortOrder,
    jobFilter,
  ];

  JobsLoaded copyWith({
    List<Job>? jobs,
    Job? selectedJob,
    Map<String, List<Application>>? applicationsByJob,
    Map<String, List<Application>>? shortlistedByJob,
    Map<String, List<Application>>? rejectedByJob,
    Map<String, Set<String>>? swipedApplicationIdsByJob,
    List<Application>? filteredApplications,
    Map<String, dynamic>? filters,
    Map<String, int>? applicationCountByJob,
    SortOrder? sortOrder,
    String? jobFilter,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      applicationsByJob: applicationsByJob ?? this.applicationsByJob,
      shortlistedByJob: shortlistedByJob ?? this.shortlistedByJob,
      rejectedByJob: rejectedByJob ?? this.rejectedByJob,
      swipedApplicationIdsByJob: swipedApplicationIdsByJob ?? this.swipedApplicationIdsByJob,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      filters: filters ?? this.filters,
      applicationCountByJob: applicationCountByJob ?? this.applicationCountByJob,
      sortOrder: sortOrder ?? this.sortOrder,
      jobFilter: jobFilter ?? this.jobFilter,
    );
  }

  bool isApplicationSwiped(String jobId, String applicationId) {
    return swipedApplicationIdsByJob[jobId]?.contains(applicationId) ?? false;
  }
}

// BLoC
class JobBloc extends Bloc<JobEvent, JobState> {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  JobBloc({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        super(JobInitial()) {
    on<Refresh>((event, emit) => add(LoadJobs()));
    on<LoadJobs>(_onLoadJobs);
    on<SelectJob>(_onSelectJob);
    on<SwipeApplication>(_onSwipeApplication);
    on<FilterApplications>(_onFilterApplications);
    on<AddJob>(_onAddJob);
    on<DeleteJob>(_onDeleteJob);
    on<SortJobs>(_onSortJobs);
    on<FilterJobs>(_onFilterJobs);
    on<UpdateJob>(_onUpdateJob);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final companyId = userDoc.get('companyId') ?? user.uid;

      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('timestamp', descending: true)
          .get();

      final jobs = jobsSnapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      if (jobs.isEmpty) {
        emit(JobsLoaded(
          jobs: const [],
          applicationsByJob: const {},
          shortlistedByJob: const {},
          rejectedByJob: const {},
          swipedApplicationIdsByJob: const {},
          applicationCountByJob: const {},
        ));
        return;
      }

      Map<String, List<Application>> applicationsByJob = {};
      Map<String, List<Application>> shortlistedByJob = {};
      Map<String, List<Application>> rejectedByJob = {};
      Map<String, Set<String>> swipedApplicationIdsByJob = {};
      Map<String, int> applicationCountByJob = {};

      for (var job in jobs) {
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: job.id)
            .orderBy('timestamp', descending: true)
            .get();

        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();

        applicationsByJob[job.id] = applications;
        applicationCountByJob[job.id] = applications.length;

        shortlistedByJob[job.id] = applications
            .where((app) => app.status == 'shortlisted')
            .toList();

        rejectedByJob[job.id] = applications
            .where((app) => app.status == 'rejected')
            .toList();

        swipedApplicationIdsByJob[job.id] = applications
            .where((app) => app.status != 'pending')
            .map((app) => app.id)
            .toSet();
      }

      emit(JobsLoaded(
        jobs: jobs,
        selectedJob: jobs.first,
        applicationsByJob: applicationsByJob,
        shortlistedByJob: shortlistedByJob,
        rejectedByJob: rejectedByJob,
        swipedApplicationIdsByJob: swipedApplicationIdsByJob,
        applicationCountByJob: applicationCountByJob,
      ));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _onUpdateJob(UpdateJob event, Emitter<JobState> emit) async {
    try {
      await _firestore.collection('jobs').doc(event.job.id).update(event.updates);
      add(LoadJobs()); // Reload jobs after update
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _onDeleteJob(DeleteJob event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      try {
        await _firestore.collection('jobs').doc(event.jobId).delete();
        add(LoadJobs()); // Reload jobs after deletion
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  void _onSortJobs(SortJobs event, Emitter<JobState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final sortedJobs = JobSorter.sortByDate(currentState.jobs, event.order);
      emit(currentState.copyWith(
        jobs: sortedJobs,
        sortOrder: event.order,
      ));
    }
  }
  void _onFilterJobs(FilterJobs event, Emitter<JobState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      emit(currentState.copyWith(jobFilter: event.filter));
    }
  }
  Future<void> _onSelectJob(SelectJob event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        final applications = currentState.applicationsByJob[event.job.id] ?? [];
        final shortlisted = currentState.shortlistedByJob[event.job.id] ?? [];
        final rejected = currentState.rejectedByJob[event.job.id] ?? [];

        emit(currentState.copyWith(
          selectedJob: event.job,
          filteredApplications: applications,
        ));
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  Future<void> _onSwipeApplication(SwipeApplication event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final jobId = event.application.jobId;
      final status = event.isRightSwipe ? 'shortlisted' : 'rejected';

      try {
        // Update Firebase
        await _firestore.collection('applications').doc(event.application.id).update({
          'status': status,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'companyLikesCount': event.isRightSwipe ?
          FieldValue.increment(1) : event.application.companyLikesCount,
        });

        // Update local state
        Map<String, List<Application>> updatedShortlisted = Map.from(currentState.shortlistedByJob);
        Map<String, List<Application>> updatedRejected = Map.from(currentState.rejectedByJob);
        Map<String, List<Application>> updatedApplicationsByJob = Map.from(currentState.applicationsByJob);
        Map<String, Set<String>> updatedSwipedIds = Map.from(currentState.swipedApplicationIdsByJob);

        // Remove from current applications
        updatedApplicationsByJob[jobId] = (updatedApplicationsByJob[jobId] ?? [])
            .where((app) => app.id != event.application.id)
            .toList();

        // Add to appropriate list based on swipe direction
        final updatedApplication = event.application.copyWith(
          status: status,
          statusUpdatedAt: DateTime.now(),
          companyLikesCount: event.isRightSwipe ?
          event.application.companyLikesCount + 1 : event.application.companyLikesCount,
        );

        if (event.isRightSwipe) {
          updatedShortlisted[jobId] = [
            ...updatedShortlisted[jobId] ?? [],
            updatedApplication,
          ];

          // Remove from rejected if it was there
          updatedRejected[jobId] = (updatedRejected[jobId] ?? [])
              .where((app) => app.id != event.application.id)
              .toList();

          await _sendNotificationToApplicant(
            event.application.userId,
            'shortlisted',
            event.application.jobTitle,
          );
        } else {
          updatedRejected[jobId] = [
            ...updatedRejected[jobId] ?? [],
            updatedApplication,
          ];

          // Remove from shortlisted if it was there
          updatedShortlisted[jobId] = (updatedShortlisted[jobId] ?? [])
              .where((app) => app.id != event.application.id)
              .toList();
        }

        // Update swiped IDs
        final swipedIds = Set<String>.from(updatedSwipedIds[jobId] ?? {})..add(event.application.id);
        updatedSwipedIds[jobId] = swipedIds;

        // Check if all applications have been processed
        final noMoreApplications = updatedApplicationsByJob[jobId]?.isEmpty ?? true;

        emit(currentState.copyWith(
          shortlistedByJob: updatedShortlisted,
          rejectedByJob: updatedRejected,
          applicationsByJob: updatedApplicationsByJob,
          swipedApplicationIdsByJob: updatedSwipedIds,
          filteredApplications: noMoreApplications ? [] : updatedApplicationsByJob[jobId],
        ));

      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  void _onFilterApplications(FilterApplications event, Emitter<JobState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final selectedJobId = currentState.selectedJob?.id;

      if (selectedJobId == null) return;

      // Get the applications list for the selected job
      final applications = currentState.applicationsByJob[selectedJobId] ?? [];

      final filters = {
        if (event.searchQuery != null) 'searchQuery': event.searchQuery,
        if (event.location != null) 'location': event.location,
        if (event.skills != null) 'skills': event.skills,
        if (event.experience != null) 'experience': event.experience,
        if (event.qualification != null) 'qualification': event.qualification,
        if (event.employmentType != null) 'employmentType': event.employmentType,
      };

      // Filter the applications list
      final filteredApplications = applications.where((application) {
        bool matchesSearch = true;
        if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
          matchesSearch = application.applicantName.toLowerCase().contains(event.searchQuery!.toLowerCase()) ||
              application.skills.any((skill) => skill.toLowerCase().contains(event.searchQuery!.toLowerCase()));
        }

        bool matchesLocation = true;
        if (event.location != null && event.location!.isNotEmpty) {
          matchesLocation = application.jobLocation.toLowerCase() == event.location!.toLowerCase();
        }

        bool matchesSkills = true;
        if (event.skills != null && event.skills!.isNotEmpty) {
          matchesSkills = event.skills!.every((skill) => application.skills.contains(skill));
        }

        bool matchesExperience = true;
        if (event.experience != null && event.experience!.isNotEmpty) {
          matchesExperience = _matchesExperienceFilter(application.experience.toString(), event.experience!);
        }

        bool matchesQualification = true;
        if (event.qualification != null && event.qualification!.isNotEmpty) {
          matchesQualification = application.qualification == event.qualification;
        }

        return matchesSearch &&
            matchesLocation &&
            matchesSkills &&
            matchesExperience &&
            matchesQualification;
      }).toList();

      emit(currentState.copyWith(
        filteredApplications: filteredApplications,
        filters: filters,
      ));
    }
  }
  bool _matchesExperienceFilter(String applicationExp, String filterExp) {
    final appExp = double.tryParse(applicationExp.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final filterExpValue = double.tryParse(filterExp.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return appExp >= filterExpValue;
  }
  Future<void> _onAddJob(AddJob event, Emitter<JobState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final companyId = userDoc.get('companyId');
      final companyName = userDoc.get('companyName');

      if (companyId == null || companyName == null) {
        throw Exception('Company information is missing. Please update your profile.');
      }

      final job = event.job.copyWith(
        companyId: companyId,
        companyName: companyName,
      );

      await _firestore.collection('jobs').add(job.toMap());
      add(LoadJobs()); // Reload jobs after adding
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _sendNotificationToApplicant(String userId, String status, String jobTitle,) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final tokens = List<String>.from(userDoc.data()?['fcmTokens'] ?? []);

      for (String token in tokens) {
        String title;
        String body;

        switch (status) {
        case 'shortlisted':
        title = 'Application Update';
        body = 'Your application for $jobTitle has been shortlisted!';
        break;
        case 'rejected':
        title = 'Application Status';
        body = 'Thank you for your interest in $jobTitle.';
        break;
          default:
            title = 'Application Update';
            body = 'There has been an update to your application for $jobTitle.';
        }

        await _firestore.collection('notifications').add({
          'userId': userId,
          'token': token,
          'title': title,
          'body': body,
          'jobTitle': jobTitle,
          'status': status,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notification: $e');
      }
    }
  }
  Future<void> _refreshApplications(String jobId) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: jobId)
            .orderBy('timestamp', descending: true)
            .get();

        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();

        final shortlisted = applications
            .where((app) => app.status == 'shortlisted')
            .toList();

        final rejected = applications
            .where((app) => app.status == 'rejected')
            .toList();

        final swiped = applications
            .where((app) => app.status != 'pending')
            .map((app) => app.id)
            .toSet();

        emit(currentState.copyWith(
          applicationsByJob: Map.from(currentState.applicationsByJob)
            ..[jobId] = applications,
          shortlistedByJob: Map.from(currentState.shortlistedByJob)
            ..[jobId] = shortlisted,
          rejectedByJob: Map.from(currentState.rejectedByJob)
            ..[jobId] = rejected,
          swipedApplicationIdsByJob: Map.from(currentState.swipedApplicationIdsByJob)
            ..[jobId] = swiped,
          applicationCountByJob: Map.from(currentState.applicationCountByJob)
            ..[jobId] = applications.length,
          filteredApplications: currentState.selectedJob?.id == jobId ? applications : null,
        ));
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
}