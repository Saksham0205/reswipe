import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_model/job.dart';
import '../models/user_model/applicant.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Applicant>> getApplicants() {
    print('Fetching applicants...'); // Log when the method is called
    return _firestore.collection('applicants').snapshots().map((snapshot) {
      print('Received ${snapshot.docs.length} applicants'); // Log the number of documents
      return snapshot.docs.map((doc) {
        try {
          return Applicant.fromMap(doc.data(), doc.id);
        } catch (e) {
          print('Error parsing applicant: $e'); // Log any parsing errors
          return null;
        }
      }).whereType<Applicant>().toList(); // Filter out any null values
    });
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void addJob(String title, String description, String companyId) async {
    // Create a Job with the companyId
    Job newJob = Job(
      title: title,
      description: description,
      companyId: companyId,  // companyId is passed in
    );

    // Save the job in Firestore
    await FirebaseFirestore.instance.collection('jobs').add(newJob.toMap());
  }


  Stream<List<Job>> getFavoriteJobs() {
    // Implement logic to get favorite jobs
    return Stream.empty();
  }
}
