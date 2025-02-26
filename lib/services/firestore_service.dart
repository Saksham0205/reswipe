import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/company_model/applications.dart';
import '../models/company_model/job.dart';
import '../models/user_model/applicant.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create a new user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': 'job_seeker', // Default role for Google sign-in
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  Future<String?> getCurrentCompanyId() async {
    try {
      String? userId = await getCurrentUserId();
      if (userId == null) {
        print('No user is currently logged in.');
        return null;
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User document does not exist in Firestore.');
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? companyId = userData['companyId'] as String?;

      if (companyId == null) {
        print('Company ID not found for the current user.');
        return null;
      }

      return companyId;
    } catch (e) {
      print('Error getting current company ID: $e');
      return null;
    }
  }
  Stream<User?> get userStream => _auth.authStateChanges();

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Applicant-related methods
  Future<void> saveApplication(Application application, Job job) async {
    // Combine application and job details
    Map<String, dynamic> applicationData = {
      ...application.toMap(),
      ...job.toMap(),  // This will add all job details to the application document
    };

    await FirebaseFirestore.instance
        .collection('applications')
        .add(applicationData);
  }

  Stream<List<Applicant>> getFavoriteApplicants() {
    return _firestore.collection('favorites').snapshots().asyncMap((snapshot) async {
      List<Applicant> applicants = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot applicantDoc = await _firestore.collection('applications').doc(doc.id).get();
        if (applicantDoc.exists) {
          applicants.add(Applicant.fromFirestore(applicantDoc));
        }
      }
      return applicants;
    });
  }

  Future<void> removeFromFavorites(String applicantId) {
    return _firestore.collection('favorites').doc(applicantId).delete();
  }

  Stream<List<Applicant>> getApplicants() {
    print('Fetching applicants...');
    return _firestore.collection('applications').snapshots().map((snapshot) {
      print('Received ${snapshot.docs.length} applications');
      return snapshot.docs.map((doc) {
        try {
          return Applicant.fromFirestore(doc);
        } catch (e) {
          print('Error parsing applications: $e');
          return null;
        }
      }).whereType<Applicant>().toList();
    });
  }

  // Job-related methods

  Future<void> addJob(Job job) async {
    try {
      await _firestore.collection('jobs').add(job.toMap());
      print('Job added successfully');
    } catch (e) {
      print('Error adding job: $e');
      throw e;
    }
  }

  Stream<List<Job>> getJobs() {
    return _firestore.collection('jobs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          print('Error parsing job: $e');
          return null;
        }
      }).whereType<Job>().toList();
    });
  }

  Stream<List<Job>> getJobsByCompany(String companyId) {
    return _firestore
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Job.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          print('Error parsing job: $e');
          return null;
        }
      }).whereType<Job>().toList();
    });
  }

  Future<void> updateJob(Job job) async {
    try {
      await _firestore.collection('jobs').doc(job.id).update(job.toMap());
      print('Job updated successfully');
    } catch (e) {
      print('Error updating job: $e');
      throw e;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
      print('Job deleted successfully');
    } catch (e) {
      print('Error deleting job: $e');
      throw e;
    }
  }

  // Favorite jobs methods

  Stream<List<Job>> getFavoriteJobs(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favoriteJobs')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Job> favoriteJobs = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot jobDoc = await _firestore.collection('jobs').doc(doc.id).get();
        if (jobDoc.exists) {
          favoriteJobs.add(Job.fromMap(jobDoc.data() as Map<String, dynamic>, jobDoc.id));
        }
      }
      return favoriteJobs;
    });
  }

  Future<void> addToFavoriteJobs(String userId, String jobId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoriteJobs')
          .doc(jobId)
          .set({'addedAt': FieldValue.serverTimestamp()});
      print('Job added to favorites successfully');
    } catch (e) {
      print('Error adding job to favorites: $e');
      throw e;
    }
  }

  Future<void> removeFromFavoriteJobs(String userId, String jobId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoriteJobs')
          .doc(jobId)
          .delete();
      print('Job removed from favorites successfully');
    } catch (e) {
      print('Error removing job from favorites: $e');
      throw e;
    }
  }
}