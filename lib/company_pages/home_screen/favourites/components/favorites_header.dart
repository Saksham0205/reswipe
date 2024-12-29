import 'package:flutter/material.dart';
import 'animated_app_bar.dart';
import 'job_title_tabs.dart';

class FavoritesHeader extends StatelessWidget {
  final bool hasItems;
  final List<String> jobTitles;
  final String? selectedJobTitle;
  final Function(BuildContext) onClearAll;
  final Function(String) onJobTitleSelected;

  const FavoritesHeader({
    Key? key,
    required this.hasItems,
    required this.jobTitles,
    required this.selectedJobTitle,
    required this.onClearAll,
    required this.onJobTitleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        AnimatedAppBar(
          hasItems: hasItems,
          onClearAll: () => onClearAll(context),
          onBack: () => Navigator.pop(context),
        ),
        if (jobTitles.isNotEmpty)
          JobTitleTabs(
            jobTitles: jobTitles,
            selectedJobTitle: selectedJobTitle ?? '',
            onJobTitleSelected: onJobTitleSelected,
          ),
      ]),
    );
  }
}