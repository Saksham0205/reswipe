import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/company_model/applications.dart';
import 'empty_state.dart';
import 'favorites_list_view.dart';

class FavoritesBody extends StatelessWidget {
  final List<Application> localFavorites;
  final List<Application> filteredApplications;
  final Future<void> Function() onRefresh;
  final Function(Application) onDelete;

  const FavoritesBody({
    Key? key,
    required this.localFavorites,
    required this.filteredApplications,
    required this.onRefresh,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (localFavorites.isEmpty) {
      return EmptyState().animate().fadeIn(duration: const Duration(milliseconds: 300));
    }

    if (filteredApplications.isEmpty) {
      return EmptyState(isSearching: true).animate().fadeIn(duration: const Duration(milliseconds: 300));
    }

    return FavoritesListView(
      applications: filteredApplications,
      onRefresh: onRefresh,
      onDelete: onDelete, onViewResume: (Application ) {  },
    );
  }
}