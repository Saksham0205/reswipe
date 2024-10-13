import 'package:flutter/material.dart';
import '../models/user_model/applicant.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Applicants'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<Applicant>>(
        stream: FirestoreService().getFavoriteApplicants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite applicants found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final applicant = snapshot.data![index];
              return ApplicantCard(applicant: applicant);
            },
          );
        },
      ),
    );
  }
}

class ApplicantCard extends StatelessWidget {
  final Applicant applicant;

  const ApplicantCard({Key? key, required this.applicant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              applicant.profilePhotoUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  applicant.jobProfile,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _viewResume(context, applicant),
                      icon: Icon(Icons.description, color: Colors.white),
                      label: Text('View Resume', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromFavorites(context, applicant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewResume(BuildContext context, Applicant applicant) {
    // Implement resume viewing logic
    // You might want to use a package like url_launcher to open the PDF
    // or navigate to a custom PDF viewer screen
    print('Viewing resume for ${applicant.name}');
  }

  void _removeFromFavorites(BuildContext context, Applicant applicant) {
    // Implement logic to remove applicant from favorites
    // This might involve calling a method from your FirestoreService
    // and then showing a snackbar to confirm the action
    FirestoreService().removeFromFavorites(applicant.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${applicant.name} removed from favorites')),
      );
    });
  }
}