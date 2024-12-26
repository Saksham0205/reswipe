import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/company_model/applications.dart';
import '../widgets/application_details_sheet.dart';
import 'components/animated_app_bar.dart';
import 'components/animated_favorite_card.dart';
import 'components/empty_state.dart';


class FavoritesScreen extends StatefulWidget {
  final List<Application> favoriteApplications;
  final Function() clearAllFavorites;
  final Function(Application) removeFromFavorites;

  const FavoritesScreen({
    Key? key,
    required this.favoriteApplications,
    required this.clearAllFavorites,
    required this.removeFromFavorites,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<Application> _localFavorites;

  @override
  void initState() {
    super.initState();
    _localFavorites = List.from(widget.favoriteApplications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          AnimatedAppBar(
            hasItems: _localFavorites.isNotEmpty,
            onClearAll: () => _showClearConfirmation(context),
            onBack: () => Navigator.pop(context),
          ),
        ],
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_localFavorites.isEmpty) {
      return EmptyState().animate().fadeIn(duration: 300.ms);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.deepPurple,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _localFavorites.length,
        itemBuilder: (context, index) {
          final application = _localFavorites[index];
          return AnimatedFavoriteCard(
            application: application,
            index: index,
            onDelete: () => _handleDeleteApplication(application),
            onTap: () => _showApplicationDetails(context, application),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  void _handleDeleteApplication(Application application) {
    final index = _localFavorites.indexOf(application);
    final deletedApplication = application;

    setState(() {
      _localFavorites.remove(application);
      widget.removeFromFavorites(application);
    });

    _showUndoSnackBar(deletedApplication, index);
  }

  void _showUndoSnackBar(Application application, int index) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_remove, color: Colors.white, size: 20.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  '${application.applicantName} removed from matches',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          width: MediaQuery.of(context).size.width * 0.9,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                _localFavorites.insert(index, application);
                // Add this line to update the parent's state
                widget.favoriteApplications.insert(index, application);
              });
            },
          ),
        ),
      );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All matches cleared'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _localFavorites = List.from(previousFavorites);
            });
          },
        ),
      ),
    );
  }

  void _showApplicationDetails(BuildContext context, Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailsSheet(application: application),
    );
  }
}