import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/company_model/applications.dart';
import 'components/app_class.dart';

class FavoritesScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context, innerBoxIsScrolled),
          ];
        },
        body: _buildFavoritesList(context),
      ),
    );
  }


  Widget _buildFavoritesList(BuildContext context) {
    if (favoriteApplications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: favoriteApplications.length,
        itemBuilder: (context, index) {
          final application = favoriteApplications[index];
          return _buildFavoriteCard(context, application)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate a network refresh
    await Future.delayed(const Duration(seconds: 2));
    // Consider implementing actual data refresh logic here
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Matches Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe right on profiles you like\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Matched Profiles',
          style: AppTypography.appBarTitle.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (favoriteApplications.isNotEmpty)
          IconButton(
            tooltip: 'Clear all matches',
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: () => _showClearConfirmation(context),
          ),
      ],
    );}

  Widget _buildFavoriteCard(BuildContext context, Application application) {
    return Dismissible(
      key: Key(application.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showRemoveConfirmation(context, application);
      },
      background: _buildDismissBackground(),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showApplicationDetails(context, application),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(application),
              _buildCardBody(application),
              _buildCardActions(context, application),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade700, size: 36),
    );
  }

  Future<bool?> _showRemoveConfirmation(BuildContext context, Application application) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Match'),
        content: Text(
          'Are you sure you want to remove ${application.applicantName} from your matches?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              removeFromFavorites(application);
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(Application application) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.deepPurple.shade50, Colors.white],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildProfileImage(application),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.applicantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.jobProfile,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'Matched',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Application application) {
    return Hero(
      tag: 'profile_${application.id}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
          ),
        ),
        child: Center(
          child: Text(
            application.applicantName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBody(Application application) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.school, application.qualification),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Location • Remote'),
          const SizedBox(height: 12),
          _buildSkillsList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSkillChip('Flutter'),
        _buildSkillChip('React'),
        _buildSkillChip('UI/UX'),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCardActions(BuildContext context, Application application) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description, size: 18),
              label: const Text('View Resume'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: BorderSide(color: Colors.deepPurple.shade200),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendEmail(context, application),
              icon: const Icon(Icons.message, size: 18),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmail(BuildContext context, Application application) async {
//     // Assume that the HR's registered email is fetched from their account/profile details.
//     String hrEmail = "saksham252003@gmail.com"; // Replace with actual retrieval logic
//
//     // Compose the email URI
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: 'sakshamchauhan02@outlook.com',
//       queryParameters: {
//         'subject': 'Job Application Inquiry - ${application.applicantName}',
//         'body': '''
// Dear ${application.applicantName},
//
// I am reaching out regarding your job application for the ${application.jobProfile} position.
//
// Best regards,
// $hrEmail
// '''
//       },
//     );
//
//     try {
//       // Check if the email can be launched
//       if (await canLaunchUrl(emailUri)) {
//         // Launch the email client
//         await launchUrl(emailUri);
//       } else {
//         // If email client can't be launched, show an error
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not launch email app'),
//           ),
//         );
//       }
//     } catch (e) {
//       // Handle any errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An error occurred: $e'),
//         ),
//       );
//     }
  }


  void _showApplicationDetails(BuildContext context, Application application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailHeader(application),
                      const SizedBox(height: 24),
                      _buildDetailSection('Experience', [
                        'Senior Developer at Tech Corp',
                        'Lead Developer at StartUp Inc',
                      ]),
                      _buildDetailSection('Education', [
                        application.qualification,
                      ]),
                      _buildDetailSection('Skills', [
                        'Flutter Development',
                        'React Native',
                        'UI/UX Design',
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(Application application) {
    return Row(
      children: [
        _buildProfileImage(application),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application.applicantName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                application.jobProfile,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Matches'),
        content: const Text(
          'Are you sure you want to remove all matched profiles? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              clearAllFavorites();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}