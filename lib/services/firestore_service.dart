import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_model/job.dart';
import '../models/user_model/applicant.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Applicant-related methods

  Stream<List<Applicant>> getFavoriteApplicants() {
    return _firestore.collection('favorites').snapshots().asyncMap((snapshot) async {
      List<Applicant> applicants = [];
      for (var doc in snapshot.docs) {
        DocumentSnapshot applicantDoc = await _firestore.collection('applicants').doc(doc.id).get();
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
    return _firestore.collection('applicants').snapshots().map((snapshot) {
      print('Received ${snapshot.docs.length} applicants');
      return snapshot.docs.map((doc) {
        try {
          return Applicant.fromFirestore(doc);
        } catch (e) {
          print('Error parsing applicant: $e');
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