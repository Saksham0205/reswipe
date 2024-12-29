import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../models/company_model/applications.dart';
import 'favorites_header.dart';
import 'favorites_body.dart';

class FavoritesContent extends StatefulWidget {
  final List<Application> favoriteApplications;
  final VoidCallback clearAllFavorites;
  final Function(Application) removeFromFavorites;

  const FavoritesContent({
    Key? key,
    required this.favoriteApplications,
    required this.clearAllFavorites,
    required this.removeFromFavorites,
  }) : super(key: key);

  @override
  State<FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> {
  late List<Application> _localFavorites;
  late List<String> _jobTitles;
  String? _selectedJobTitle;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    _localFavorites = List.from(widget.favoriteApplications);
    _jobTitles = _extractUniqueJobTitles();
    _selectedJobTitle = _jobTitles.isNotEmpty ? _jobTitles.first : null;
  }

  List<String> _extractUniqueJobTitles() {
    return _localFavorites
        .map((app) => app.jobTitle)
        .toSet()
        .toList()
      ..sort();
  }

  List<Application> get _filteredApplications {
    if (_selectedJobTitle == null) return [];
    return _localFavorites
        .where((app) => app.jobTitle == _selectedJobTitle)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        FavoritesHeader(
          hasItems: _localFavorites.isNotEmpty,
          jobTitles: _jobTitles,
          selectedJobTitle: _selectedJobTitle,
          onClearAll: _showClearConfirmation,
          onJobTitleSelected: (title) {
            setState(() => _selectedJobTitle = title);
          },
        ),
      ],
      body: FavoritesBody(
        localFavorites: _localFavorites,
        filteredApplications: _filteredApplications,
        onRefresh: _handleRefresh,
        onDelete: _handleDeleteApplication,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _jobTitles = _extractUniqueJobTitles();
      if (_selectedJobTitle != null &&
          !_jobTitles.contains(_selectedJobTitle) &&
          _jobTitles.isNotEmpty) {
        _selectedJobTitle = _jobTitles.first;
      }
    });
  }

  void _handleDeleteApplication(Application application) {
    final index = _localFavorites.indexOf(application);
    setState(() {
      _localFavorites.remove(application);
      widget.removeFromFavorites(application);
      _jobTitles = _extractUniqueJobTitles();
      if (_selectedJobTitle != null &&
          !_jobTitles.contains(_selectedJobTitle) &&
          _jobTitles.isNotEmpty) {
        _selectedJobTitle = _jobTitles.first;
      }
    });
    _showUndoSnackBar(application, index);
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Matches',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade900,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all matched profiles? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleClearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleClearAll() {
    final previousFavorites = List<Application>.from(_localFavorites);
    setState(() {
      _localFavorites.clear();
      widget.clearAllFavorites();
      _initializeState();
    });
    _showUndoSnackBar(previousFavorites);
  }

  void _showUndoSnackBar(dynamic item, [int? index]) {
    final isApplication = item is Application;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
              isApplication
                  ? '${(item as Application).applicantName} removed from matches'
                  : 'All matches cleared'
          ),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                if (isApplication && index != null) {
                  _localFavorites.insert(index, item);
                  widget.favoriteApplications.insert(index, item);
                } else if (!isApplication) {
                  _localFavorites = List<Application>.from(item);
                }
                _initializeState();
              });
            },
          ),
        ),
      );
  }
}