import 'package:flutter/material.dart';

import '../models/company_model/job.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: StreamBuilder<List<Job>>(
        stream: FirestoreService().getFavoriteJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite jobs found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final job = snapshot.data![index];
              return ListTile(
                title: Text(job.title),
                subtitle: Text(job.description),
                trailing: Icon(Icons.favorite, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}