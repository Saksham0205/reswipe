import '../../../models/company_model/job.dart';

enum SortOrder {
  newest,
  oldest,
}

class JobSorter {
  static List<Job> sortByDate(List<Job> jobs, SortOrder order) {
    return List<Job>.from(jobs)
      ..sort((a, b) {
        final comparison = b.timestamp.compareTo(a.timestamp);
        return order == SortOrder.newest ? comparison : -comparison;
      });
  }
}