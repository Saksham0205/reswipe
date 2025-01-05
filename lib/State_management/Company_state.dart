import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';

// job_state.dart
abstract class JobState extends Equatable {
  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}
class JobLoading extends JobState {}
class JobsLoaded extends JobState {
  final List<Job> jobs;
  final Job? selectedJob;
  final List<Application> applications;
  final List<Application> shortlistedApplications;
  final List<Application> rejectedApplications;
  final List<Application> filteredApplications;  // Added this property
  final Map<String, dynamic> filters;

  JobsLoaded({
    required this.jobs,
    this.selectedJob,
    required this.applications,
    required this.shortlistedApplications,
    required this.rejectedApplications,
    List<Application>? filteredApplications,  // Made optional with default
    this.filters = const {},
  }) : this.filteredApplications = filteredApplications ?? applications;  // Initialize with applications if not provided

  @override
  List<Object?> get props => [
    jobs,
    selectedJob,
    applications,
    shortlistedApplications,
    rejectedApplications,
    filteredApplications,
    filters,
  ];

  JobsLoaded copyWith({
    List<Job>? jobs,
    Job? selectedJob,
    List<Application>? applications,
    List<Application>? shortlistedApplications,
    List<Application>? rejectedApplications,
    List<Application>? filteredApplications,
    Map<String, dynamic>? filters,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      selectedJob: selectedJob ?? this.selectedJob,
      applications: applications ?? this.applications,
      shortlistedApplications: shortlistedApplications ?? this.shortlistedApplications,
      rejectedApplications: rejectedApplications ?? this.rejectedApplications,
      filteredApplications: filteredApplications ?? this.filteredApplications,
      filters: filters ?? this.filters,
    );
  }
}
class AddJob extends JobEvent {
  final Job job;

  AddJob(this.job);

  @override
  List<Object?> get props => [job];
}

class JobError extends JobState {
  final String message;
  JobError(this.message);

  @override
  List<Object?> get props => [message];
}

// job_event.dart
abstract class JobEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {}
class SelectJob extends JobEvent {
  final Job job;
  SelectJob(this.job);

  @override
  List<Object?> get props => [job];
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
  final String? qualification;  // Added qualification parameter

  FilterApplications({
    this.searchQuery,
    this.location,
    this.skills,
    this.experience,
    this.qualification,  // Added to constructor
  });

  @override
  List<Object?> get props => [searchQuery, location, skills, experience, qualification];
}

class RemoveFromShortlistEvent extends JobEvent {
  final Application application;
  final String jobId;

  RemoveFromShortlistEvent({
    required this.application,
    required this.jobId,
  });
}

class AddToShortlistEvent extends JobEvent {
  final Application application;
  final String jobId;

  AddToShortlistEvent({
    required this.application,
    required this.jobId,
  });
}

class SendNotifications extends JobEvent {}

// job_bloc.dart
class JobBloc extends Bloc<JobEvent, JobState> {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  JobBloc({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        super(JobInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<SelectJob>(_onSelectJob);
    on<SwipeApplication>(_onSwipeApplication);
    on<FilterApplications>(_onFilterApplications);
    on<SendNotifications>(_onSendNotifications);
    on<AddJob>(_onAddJob);
    on<RemoveFromShortlistEvent>(_onRemoveFromShortlist);
    on<AddToShortlistEvent>(_onAddToShortlist);
  }

  Future<void> _onRemoveFromShortlist(
      RemoveFromShortlistEvent event,
      Emitter<JobState> emit,
      ) async {if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        // Update status in Firestore
        await _firestore
            .collection('applications')
            .doc(event.application.id)
            .update({
          'status': 'removed',
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });

        // Remove from shortlisted applications list
        final updatedShortlisted = currentState.shortlistedApplications
            .where((app) => app.id != event.application.id)
            .toList();

        // Emit new state with updated shortlisted applications
        emit(currentState.copyWith(
          shortlistedApplications: updatedShortlisted,
        ));

        // Optionally notify the applicant
        await _sendNotificationToApplicant(
          event.application.userId,
          'removed',
          event.application.jobTitle,
        );
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }}
  Future<void> _onAddToShortlist(
      AddToShortlistEvent event,
      Emitter<JobState> emit,
      ) async {if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        // Update status in Firestore
        await _firestore
            .collection('applications')
            .doc(event.application.id)
            .update({
          'status': 'shortlisted',
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });

        // Add back to shortlisted applications list if not already present
        if (!currentState.shortlistedApplications
            .any((app) => app.id == event.application.id)) {
          final updatedShortlisted = List<Application>.from(
            currentState.shortlistedApplications,
          )..add(event.application);

          // Emit new state with updated shortlisted applications
          emit(currentState.copyWith(
            shortlistedApplications: updatedShortlisted,
          ));

          // Notify the applicant of being shortlisted again
          await _sendNotificationToApplicant(
            event.application.userId,
            'shortlistPending',
            event.application.jobTitle,
          );
        }
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }}
  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(JobError('User not authenticated'));
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      final companyId = userDoc.get('companyId') ?? user.uid;

      // Fetch jobs
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
          applications: const [],
          shortlistedApplications: const [],
          rejectedApplications: const [],
        ));
        return;
      }

      final selectedJob = jobs.first;

      // Load all applications for each job
      Map<String, List<Application>> allApplications = {};
      Map<String, List<Application>> shortlistedApplications = {};
      Map<String, List<Application>> rejectedApplications = {};

      for (var job in jobs) {
        // Get all applications for this job
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: job.id)
            .get();

        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();

        allApplications[job.id] = applications;

        // Filter shortlisted and rejected applications
        shortlistedApplications[job.id] = applications
            .where((app) => app.status == 'shortlisted')
            .toList();

        rejectedApplications[job.id] = applications
            .where((app) => app.status == 'rejected')
            .toList();
      }

      // Get applications for selected job
      final currentApplications = allApplications[selectedJob.id] ?? [];
      final currentShortlisted = shortlistedApplications[selectedJob.id] ?? [];
      final currentRejected = rejectedApplications[selectedJob.id] ?? [];

      emit(JobsLoaded(
        jobs: jobs,
        selectedJob: selectedJob,
        applications: currentApplications,
        shortlistedApplications: currentShortlisted,
        rejectedApplications: currentRejected,
      ));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _onSelectJob(SelectJob event, Emitter<JobState> emit) async {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      emit(JobLoading());

      try {
        // Load all applications for the selected job
        final applicationsSnapshot = await _firestore
            .collection('applications')
            .where('jobId', isEqualTo: event.job.id)
            .get();

        final applications = applicationsSnapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList();

        // Filter shortlisted and rejected applications
        final shortlistedApplications = applications
            .where((app) => app.status == 'shortlisted')
            .toList();

        final rejectedApplications = applications
            .where((app) => app.status == 'rejected')
            .toList();

        emit(currentState.copyWith(
          selectedJob: event.job,
          applications: applications,
          shortlistedApplications: shortlistedApplications,
          rejectedApplications: rejectedApplications,
        ));
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }
  }
  Future<List<Application>> _loadApplicationsForJob(String jobId) async {
    final snapshot = await _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Application.fromFirestore(doc))
        .toList();
  }
  Future<void> _onAddJob(AddJob event, Emitter<JobState> emit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(JobError('User not authenticated'));
        return;
      }

      // Get company info
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      String companyId = userDoc.get('companyId') ?? '';
      String companyName = userDoc.get('companyName') ?? '';

      if (companyId.isEmpty || companyName.isEmpty) {
        emit(JobError('Company information is missing. Please update your profile.'));
        return;
      }

      // Create job with company info
      final job = Job(
        title: event.job.title,
        description: event.job.description,
        responsibilities: event.job.responsibilities,
        qualifications: event.job.qualifications,
        salaryRange: event.job.salaryRange,
        location: event.job.location,
        employmentType: event.job.employmentType,
        companyId: companyId,
        companyName: companyName,
      );

      // Add to Firestore
      await _firestore.collection('jobs').add(job.toMap());

      // Reload jobs after adding
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('timestamp', descending: true)
          .get();

      final jobs = jobsSnapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .toList();

      emit(JobsLoaded(
        jobs: jobs,
        applications: const [],
        shortlistedApplications: const [],
        rejectedApplications: const [],
      ));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }
  Future<void> _onSwipeApplication(
      SwipeApplication event,
      Emitter<JobState> emit,
      ) async {if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final status = event.isRightSwipe ? 'shortlisted' : 'rejected';
      try {
        await _firestore
            .collection('applications')
            .doc(event.application.id)
            .update({
          'status': status,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });

        if (event.isRightSwipe) {
          final shortlisted = List<Application>.from(currentState.shortlistedApplications)
            ..add(event.application);
          emit(currentState.copyWith(shortlistedApplications: shortlisted));

          // Send immediate notification for right swipe
          await _sendNotificationToApplicant(
            event.application.userId,
            'shortlistPending',
            event.application.jobTitle,
          );
        } else {
          final rejected = List<Application>.from(currentState.rejectedApplications)
            ..add(event.application);
          emit(currentState.copyWith(rejectedApplications: rejected));
        }
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }}
  void _onFilterApplications(FilterApplications event, Emitter<JobState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final filters = {
        if (event.searchQuery != null) 'searchQuery': event.searchQuery,
        if (event.location != null) 'location': event.location,
        if (event.skills != null) 'skills': event.skills,
        if (event.experience != null) 'experience': event.experience,
        if (event.qualification != null) 'qualification': event.qualification,  // Added qualification
      };

      final filteredApplications = currentState.applications.where((application) {
        bool matchesSearch = event.searchQuery?.isEmpty ?? true ||
            application.applicantName.toLowerCase().contains(event.searchQuery!.toLowerCase()) ||
            application.skills.any((skill) =>
                skill.toLowerCase().contains(event.searchQuery!.toLowerCase()));

        bool matchesLocation = event.location?.isEmpty ?? true ||
            application.jobLocation.toLowerCase() == event.location!.toLowerCase();

        bool matchesSkills = event.skills?.isEmpty ?? true ||
            event.skills!.every((skill) => application.skills.contains(skill));

        bool matchesExperience = event.experience?.isEmpty ?? true ||
            _matchesExperienceFilter(application.experience as String, event.experience!);

        bool matchesQualification = event.qualification?.isEmpty ?? true ||
            application.qualification == event.qualification;  // Added qualification check

        return matchesSearch &&
            matchesLocation &&
            matchesSkills &&
            matchesExperience &&
            matchesQualification;  // Include qualification in filtering
      }).toList();

      emit(currentState.copyWith(
        filteredApplications: filteredApplications,
        filters: filters,
      ));
    }
  }
  bool _matchesExperienceFilter(String applicationExp, String filterExp) {
    // Convert experience strings to comparable values
    final appExp = double.tryParse(applicationExp.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final filterExpValue = double.tryParse(filterExp.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return appExp >= filterExpValue;
  }
  Future<void> _onSendNotifications(
      SendNotifications event,
      Emitter<JobState> emit,
      ) async {if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      try {
        // Send notifications to shortlisted applications
        for (var application in currentState.shortlistedApplications) {
          await _sendNotificationToApplicant(
            application.userId,
            'selected',
            application.jobTitle,
          );
        }

        // Send notifications to rejected applications
        for (var application in currentState.rejectedApplications) {
          await _sendNotificationToApplicant(
            application.userId,
            'rejected',
            application.jobTitle,
          );
        }

        // Clear the lists after sending notifications
        emit(currentState.copyWith(
          shortlistedApplications: [],
          rejectedApplications: [],
        ));
      } catch (e) {
        emit(JobError(e.toString()));
      }
    }}
  Future<void> _sendNotificationToApplicant(
      String userId,
      String status,
      String jobTitle,
      ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final tokens = userDoc.data()?['fcmTokens'] as List<dynamic>? ?? [];

      for (String token in tokens.cast<String>()) {
        String title;
        String body;

        switch (status) {
          case 'removed':
            title = 'Application Update';
            body = 'Your application status for $jobTitle has been updated.';
            break;
          case 'shortlistPending':
            title = 'Application Update';
            body = 'Your application for $jobTitle has caught our attention! We\'re reviewing it further.';
            break;
          case 'selected':
            title = 'Congratulations!';
            body = 'You have been selected for the position of $jobTitle!';
            break;
          case 'rejected':
            title = 'Application Update';
            body = 'Thank you for applying to $jobTitle. Unfortunately, we have decided to move forward with other candidates.';
            break;
          default:
            title = 'Application Status';
            body = 'There has been an update to your application for $jobTitle.';
        }

        await _firestore.collection('notifications').add({
          'token': token,
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId,
          'status': status,
          'jobTitle': jobTitle,
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}