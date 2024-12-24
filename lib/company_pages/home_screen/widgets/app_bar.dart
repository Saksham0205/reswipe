import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/company_model/applications.dart';

class HomeAppBar extends StatelessWidget {
  final List<Application> favoriteApplications;
  final VoidCallback onFavoritesTap;

  const HomeAppBar({
    Key? key,
    required this.favoriteApplications,
    required this.onFavoritesTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'Reswipe',
          style: GoogleFonts.pacifico(
            fontSize: 28,
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          color: Colors.deepPurple,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        _buildFavoritesButton(),
      ],
    );
  }

  Widget _buildFavoritesButton() {
    return GestureDetector(
      onTap: onFavoritesTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.deepPurple, size: 28),
            if (favoriteApplications.isNotEmpty)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${favoriteApplications.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}