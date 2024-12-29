import 'package:flutter/material.dart';
import '../../../models/company_model/applications.dart';
import 'components/favorites_content.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Application> favoriteApplications;
  final VoidCallback clearAllFavorites;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FavoritesContent(
        favoriteApplications: widget.favoriteApplications,
        clearAllFavorites: widget.clearAllFavorites,
        removeFromFavorites: widget.removeFromFavorites,
      ),
    );
  }
}