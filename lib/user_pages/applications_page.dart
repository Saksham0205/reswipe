import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No applications yet'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot application = snapshot.data!.docs[index];
            Map<String, dynamic> data = application.data() as Map<String, dynamic>;

            Color statusColor;
            IconData statusIcon;
            switch (data['status']) {
              case 'accepted':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'rejected':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.hourglass_empty;
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['jobTitle'] ?? 'Unknown Job'),
                subtitle: Text('Status: ${data['status'] ?? 'pending'}'),
                trailing: Icon(statusIcon, color: statusColor),
              ),
            );
          },
        );
      },
    );
  }
}