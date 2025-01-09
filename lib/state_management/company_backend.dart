import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../company_pages/profile/utils/job_sorter.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';

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
class AcceptShortlistedApplications extends JobEvent {
  final String jobId;
  final List<Application> applications;

  AcceptShortlistedApplications(this.jobId, this.applications);

  @override
  List<Object?> get props => [jobId, applications];
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
class UndoSwipe extends JobEvent {
  final Application application;
  UndoSwipe(this.application);

  @override
  List<Object?> get props => [application];
}
class ResetJobApplications extends JobEvent {
  final String jobId;
  ResetJobApplications(this.jobId);

  @override
  List<Object?> get props => [jobId];
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
  final Application? lastSwipedApplication;
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
    this.lastSwipedApplication,
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
    Application? lastSwipedApplication,
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
      lastSwipedApplication: lastSwipedApplication ?? this.lastSwipedApplication,
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
  Job? _lastSelectedJob;
  final SharedPreferences _prefs;
  static const String _lastSelectedJobKey = 'last_selected_job';
  static const String _shortlistedKey = 'shortlisted_applications';

  JobBloc({
    required SharedPreferences prefs,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _prefs = prefs,
        super(JobInitial()) {
    on<Refresh>((event, emit) => add(LoadJobs()));
    on<LoadJobs>(_onLoadJobs);
    on<SelectJob>(_onSelectJob);
    on<SwipeApplication>(_onSwipeApplication);
    on<FilterApplications>(_onFilterApplications);
    on<AcceptShortlistedApplications>(_onAcceptShortlistedApplications);
    on<AddJob>(_onAddJob);
    on<DeleteJob>(_onDeleteJob);
    on<SortJobs>(_onSortJobs);
    on<FilterJobs>(_onFilterJobs);
    on<UpdateJob>(_onUpdateJob);
    on<UndoSwipe>(_onUndoSwipe);
    on<ResetJobApplications>(_onResetJobApplications);
    _loadLastSelectedJob();
  }

  Map<String, int> _calculateJobStats(
      String jobId,
      Map<String, List<Application>> applicationsByJob,
      Map<String, List<Application>> shortlistedByJob,
      Map<String, List<Application>> rejectedByJob,
      ) {
    final applications = applicationsByJob[jobId] ?? [];
    final shortlisted = shortlistedByJob[jobId] ?? [];
    final rejected = rejectedByJob[jobId] ?? [];

    return {
      'total': applications.length,
      'shortlisted': shortlisted.length,
      'rejected': rejected.length,
      'pending': applications.length - (shortlisted.length + rejected.length),
    };
  }
  Future<void> _loadLastSelectedJob() async {
    final jobJson = _prefs.getString(_lastSelectedJobKey);
    if (jobJson != null) {
      try {
        final jobMap = json.decode(jobJson);
        _lastSelectedJob = Job.fromMap(jobMap, jobMap['id']);
      } catch (e) {
        print('Error loading last selected job: $e');
      }
    }
  }
  Future<void> _saveLastSelectedJob(Job job) async {
    try {
      final jobJson = json.encode(job.toMap());
      await _prefs.setString(_lastSelectedJobKey, jobJson);
      _lastSelectedJob = job;
    } catch (e) {
      print('Error saving last selected job: $e');
    }
  }
  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get company ID from user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final companyId = userDoc.get('companyId');

      // Fetch jobs with proper ordering by timestamp
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('timestamp', descending: true)
          .get();

      final jobs = jobsSnapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      // Initialize maps
      Map<String, List<Application>> applicationsByJob = {};
      Map<String, List<Application>> shortlistedByJob = {};
      Map<String, List<Application>> rejectedByJob = {};
      Map<String, Set<String>> swipedApplicationIdsByJob = {};
      Map<String, int> applicationCountByJob = {};

      // Fetch and process applications for each job
      for (var job in jobs) {
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: job.id)
            .get();

        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();

        // Separate applications based on status
        final pendingApplications = applications
            .where((app) => app.status == 'pending')
            .toList();

        final shortlistedApps = applications
            .where((app) => app.status == 'shortlisted')
            .toList();

        final rejectedApps = applications
            .where((app) => app.status == 'rejected')
            .toList();

        // Store applications by their status
        applicationsByJob[job.id] = pendingApplications;
        shortlistedByJob[job.id] = shortlistedApps;
        rejectedByJob[job.id] = rejectedApps;

        // Create set of swiped application IDs
        swipedApplicationIdsByJob[job.id] = applications
            .where((app) => app.status != 'pending')
            .map((app) => app.id)
            .toSet();

        // Store total count of all applications
        applicationCountByJob[job.id] = applications.length;

      }

      emit(JobsLoaded(
        jobs: jobs,
        applicationsByJob: applicationsByJob,
        shortlistedByJob: shortlistedByJob,
        rejectedByJob: rejectedByJob,
        swipedApplicationIdsByJob: swipedApplicationIdsByJob,
        applicationCountByJob: applicationCountByJob,
        sortOrder: SortOrder.newest,
        jobFilter: 'All',
      ));

      if (_lastSelectedJob != null) {
        final jobStillExists = jobs.any((job) => job.id == _lastSelectedJob!.id);
        if (jobStillExists) {
          emit(JobsLoaded(
            jobs: jobs,
            selectedJob: _lastSelectedJob,
            applicationsByJob: applicationsByJob,
            shortlistedByJob: shortlistedByJob,
            rejectedByJob: rejectedByJob,
            swipedApplicationIdsByJob: swipedApplicationIdsByJob,
            applicationCountByJob: applicationCountByJob,
            sortOrder: SortOrder.newest,
            jobFilter: 'All',
          ));
          return;
        }
      }

    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _onUndoSwipe(UndoSwipe event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final jobId = event.application.jobId;

      try {
        // Get the previous status
        final wasShortlisted = currentState.shortlistedByJob[jobId]?.contains(event.application) ?? false;

        // Update Firebase
        await _firestore.collection('applications').doc(event.application.id).update({
          'status': 'pending',
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'companyLikesCount': wasShortlisted ? FieldValue.increment(-1) : event.application.companyLikesCount,
        });

        // Update local state
        Map<String, List<Application>> updatedShortlisted = Map.from(currentState.shortlistedByJob);
        Map<String, List<Application>> updatedRejected = Map.from(currentState.rejectedByJob);
        Map<String, List<Application>> updatedApplicationsByJob = Map.from(currentState.applicationsByJob);
        Map<String, Set<String>> updatedSwipedIds = Map.from(currentState.swipedApplicationIdsByJob);

        // Remove from shortlisted/rejected lists
        updatedShortlisted[jobId] = (updatedShortlisted[jobId] ?? [])
            .where((app) => app.id != event.application.id)
            .toList();
        updatedRejected[jobId] = (updatedRejected[jobId] ?? [])
            .where((app) => app.id != event.application.id)
            .toList();

        // Add back to applications
        final updatedApplication = event.application.copyWith(
          status: 'pending',
          statusUpdatedAt: DateTime.now(),
        );

        updatedApplicationsByJob[jobId] = [
          updatedApplication,
          ...(updatedApplicationsByJob[jobId] ?? []),
        ];

        // Remove from swiped IDs
        updatedSwipedIds[jobId] = Set<String>.from(updatedSwipedIds[jobId] ?? {})
          ..remove(event.application.id);

        emit(currentState.copyWith(
          shortlistedByJob: updatedShortlisted,
          rejectedByJob: updatedRejected,
          applicationsByJob: updatedApplicationsByJob,
          swipedApplicationIdsByJob: updatedSwipedIds,
          filteredApplications: updatedApplicationsByJob[jobId],
          lastSwipedApplication: null,
        ));

      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  Future<void> _onResetJobApplications(ResetJobApplications event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        // Get all applications for the job
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: event.jobId)
            .get();

        // Create a batch operation
        final batch = _firestore.batch();

        // Reset all applications to pending
        for (var doc in applicationsSnapshot.docs) {
          batch.update(doc.reference, {
            'status': 'pending',
            'statusUpdatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Commit the batch
        await batch.commit();

        // Update local state immediately
        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .map((app) => app.copyWith(status: 'pending'))
            .toList();

        final updatedApplicationsByJob = Map<String, List<Application>>.from(currentState.applicationsByJob)
          ..[event.jobId] = applications;

        final updatedShortlistedByJob = Map<String, List<Application>>.from(currentState.shortlistedByJob)
          ..[event.jobId] = [];

        final updatedRejectedByJob = Map<String, List<Application>>.from(currentState.rejectedByJob)
          ..[event.jobId] = [];

        final updatedSwipedIds = Map<String, Set<String>>.from(currentState.swipedApplicationIdsByJob)
          ..[event.jobId] = {};

        // Recalculate stats
        final stats = _calculateJobStats(
          event.jobId,
          updatedApplicationsByJob,
          updatedShortlistedByJob,
          updatedRejectedByJob,
        );

        emit(currentState.copyWith(
          applicationsByJob: updatedApplicationsByJob,
          shortlistedByJob: updatedShortlistedByJob,
          rejectedByJob: updatedRejectedByJob,
          swipedApplicationIdsByJob: updatedSwipedIds,
          applicationCountByJob: Map.from(currentState.applicationCountByJob)
            ..[event.jobId] = stats['total']!,
          filteredApplications: currentState.selectedJob?.id == event.jobId ? applications : null,
          lastSwipedApplication: null,
        ));

      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  Future<void> _onUpdateJob(UpdateJob event, Emitter<JobState> emit) async {
    try {
      // Create a new Job instance with the updates
      final updatedJob = event.job.copyWith(
        title: event.updates['title'],
        description: event.updates['description'],
        responsibilities: event.updates['responsibilities'],
        qualifications: event.updates['qualifications'],
        salaryRange: event.updates['salaryRange'],
        location: event.updates['location'],
        employmentType: event.updates['employmentType'],
      );

      await _firestore.collection('jobs').doc(event.job.id).update(
          updatedJob.toMap());
      add(LoadJobs());
    } catch (e) {
      emit(JobError(e.toString()));
    }}
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
        await _saveLastSelectedJob(event.job);
        final pending = currentState.applicationsByJob[event.job.id] ?? [];
        final shortlisted = currentState.shortlistedByJob[event.job.id] ?? [];
        final rejected = currentState.rejectedByJob[event.job.id] ?? [];
        final totalApplications = currentState.applicationCountByJob[event.job.id] ?? 0;

        emit(currentState.copyWith(
          selectedJob: event.job,
          filteredApplications: pending,  // Show only pending applications
          applicationCountByJob: Map.from(currentState.applicationCountByJob)
            ..[event.job.id] = totalApplications,
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

      try {
        if (event.isRightSwipe) {
          // Right swipe - Add to shortlisted
          await _firestore.collection('applications').doc(event.application.id).update({
            'status': 'shortlisted',
            'statusUpdatedAt': FieldValue.serverTimestamp(),
            'companyLikesCount': FieldValue.increment(1),
          });

          // Update local state for shortlisted applications
          final updatedShortlisted = Map<String, List<Application>>.from(currentState.shortlistedByJob);
          updatedShortlisted[jobId] = [
            ...updatedShortlisted[jobId] ?? [],
            event.application.copyWith(
              status: 'shortlisted',
              statusUpdatedAt: DateTime.now(),
              companyLikesCount: (event.application.companyLikesCount ?? 0) + 1,
            ),
          ];

          // Remove from rejected if it was there
          final updatedRejected = Map<String, List<Application>>.from(currentState.rejectedByJob);
          updatedRejected[jobId] = (updatedRejected[jobId] ?? [])
              .where((app) => app.id != event.application.id)
              .toList();

          emit(currentState.copyWith(
            shortlistedByJob: updatedShortlisted,
            rejectedByJob: updatedRejected,
            lastSwipedApplication: event.application,
          ));

        } else {
          // Left swipe - reject and remove from shortlisted
          await _firestore.collection('applications').doc(event.application.id).update({
            'status': 'rejected',
            'statusUpdatedAt': FieldValue.serverTimestamp(),
          });

          // Update local state for rejected applications
          final updatedRejected = Map<String, List<Application>>.from(currentState.rejectedByJob);
          updatedRejected[jobId] = [
            ...updatedRejected[jobId] ?? [],
            event.application.copyWith(
              status: 'rejected',
              statusUpdatedAt: DateTime.now(),
            ),
          ];

          // Remove from shortlisted
          final updatedShortlisted = Map<String, List<Application>>.from(currentState.shortlistedByJob);
          updatedShortlisted[jobId] = (updatedShortlisted[jobId] ?? [])
              .where((app) => app.id != event.application.id)
              .toList();

          emit(currentState.copyWith(
            rejectedByJob: updatedRejected,
            shortlistedByJob: updatedShortlisted,
            lastSwipedApplication: event.application,
          ));

          // Send rejection notification
          await _sendNotificationToApplicant(
            event.application.userId,
            'rejected',
            event.application.jobTitle,
          );
        }

      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  Future<void> _onAcceptShortlistedApplications(
      AcceptShortlistedApplications event,
      Emitter<JobState> emit,
      ) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      try {
        // Update Firestore status for all applications
        final batch = _firestore.batch();
        for (var application in event.applications) {
          final docRef = _firestore.collection('applications').doc(application.id);
          batch.update(docRef, {
            'status': 'shortlisted',
            'statusUpdatedAt': FieldValue.serverTimestamp(),
            'companyLikesCount': FieldValue.increment(1),
          });
        }
        await batch.commit();

        // Remove accepted applications from local storage
        final shortlistedData = _prefs.getStringList(_shortlistedKey) ?? [];
        final updatedShortlistedData = shortlistedData
            .where((data) => !event.applications
            .any((app) => app.toJson() == data))
            .toList();
        await _prefs.setStringList(_shortlistedKey, updatedShortlistedData);

        // Update state
        final updatedShortlisted = Map<String, List<Application>>.from(currentState.shortlistedByJob);
        updatedShortlisted[event.jobId] = [];

        emit(currentState.copyWith(
          shortlistedByJob: updatedShortlisted,
        ));

        // Send notifications
        for (var application in event.applications) {
          await _sendNotificationToApplicant(
            application.userId,
            'shortlisted',
            application.jobTitle,
          );
        }

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

      // Use the Job model's copyWith to create a new job with company info
      final job = event.job.copyWith(
        companyId: companyId,
        companyName: companyName,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('jobs').add(job.toMap());
      add(LoadJobs());
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
// Future<void> _refreshApplications(String jobId) async {
//   if (state is JobsLoaded) {
//     final currentState = state as JobsLoaded;
//
//     try {
//       final stats = _getJobStats(jobId);
//       final applicationsSnapshot = await _firestore
//           .collection('applications')
//           .where('jobId', isEqualTo: jobId)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       final applications = applicationsSnapshot.docs
//           .map((doc) => Application.fromFirestore(doc))
//           .toList();
//
//       final shortlisted = applications
//           .where((app) => app.status == 'shortlisted')
//           .toList();
//
//       final rejected = applications
//           .where((app) => app.status == 'rejected')
//           .toList();
//
//       final swiped = applications
//           .where((app) => app.status != 'pending')
//           .map((app) => app.id)
//           .toSet();
//
//       emit(currentState.copyWith(
//         applicationsByJob: Map.from(currentState.applicationsByJob)
//           ..[jobId] = applications,
//         shortlistedByJob: Map.from(currentState.shortlistedByJob)
//           ..[jobId] = shortlisted,
//         rejectedByJob: Map.from(currentState.rejectedByJob)
//           ..[jobId] = rejected,
//         swipedApplicationIdsByJob: Map.from(currentState.swipedApplicationIdsByJob)
//           ..[jobId] = swiped,
//         applicationCountByJob: Map.from(currentState.applicationCountByJob)
//           ..[jobId] = stats['total']!,
//         filteredApplications: currentState.selectedJob?.id == jobId ? applications : null,
//       ));
//     } catch (e) {
//       emit(JobError(e.toString()));
//     }
//   }
// }
}