import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: StreamBuilder<List<Applicant>>(
        stream: FirestoreService().getApplicants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No applicants found'));
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

  ApplicantCard({required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(applicant.name),
        subtitle: Text(applicant.jobProfile),
        trailing: IconButton(
          icon: Icon(Icons.description),
          onPressed: () {
            // Implement resume viewing logic
          },
        ),
      ),
    );
  }
}