import 'package:flutter/material.dart';

class JobTitleTabs extends StatelessWidget {
  final List<String> jobTitles;
  final String selectedJobTitle;
  final Function(String) onJobTitleSelected;

  const JobTitleTabs({
    Key? key,
    required this.jobTitles,
    required this.selectedJobTitle,
    required this.onJobTitleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = jobTitles.indexOf(selectedJobTitle);

    return DefaultTabController(
      length: jobTitles.length,
      initialIndex: selectedIndex != -1 ? selectedIndex : 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          isScrollable: true,
          tabs: jobTitles.map((title) => Tab(text: title)).toList(),
          onTap: (index) => onJobTitleSelected(jobTitles[index]),
        ),
      ),
    );
  }
}