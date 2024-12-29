import 'package:flutter/material.dart';
import '../../../../models/company_model/applications.dart';
import 'profile_card.dart';

class FavoritesListView extends StatelessWidget {
  final List<Application> applications;
  final Future<void> Function() onRefresh;
  final Function(Application) onDelete;
  final Function(Application) onViewResume;

  const FavoritesListView({
    Key? key,
    required this.applications,
    required this.onRefresh,
    required this.onDelete,
    required this.onViewResume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProfileCard(
              application: application,
              index: index,
              onDelete: () => onDelete(application),
              onViewResume: () => onViewResume(application),
            ),
          );
        },
      ),
    );
  }
}