class FilterOptions {
  Set<String> selectedSkills;
  Set<String> selectedLocations;
  Set<String> selectedQualifications;
  Set<String> selectedEmploymentTypes;
  Set<String> selectedColleges;
  Set<String> selectedJobProfiles;

  FilterOptions({
    Set<String>? selectedSkills,
    Set<String>? selectedLocations,
    Set<String>? selectedQualifications,
    Set<String>? selectedEmploymentTypes,
    Set<String>? selectedColleges,
    Set<String>? selectedJobProfiles,
  })  : selectedSkills = selectedSkills ?? {},
        selectedLocations = selectedLocations ?? {},
        selectedQualifications = selectedQualifications ?? {},
        selectedEmploymentTypes = selectedEmploymentTypes ?? {},
        selectedColleges = selectedColleges ?? {},
        selectedJobProfiles = selectedJobProfiles ?? {};

  bool get hasActiveFilters =>
      selectedSkills.isNotEmpty ||
          selectedLocations.isNotEmpty ||
          selectedQualifications.isNotEmpty ||
          selectedEmploymentTypes.isNotEmpty ||
          selectedColleges.isNotEmpty ||
          selectedJobProfiles.isNotEmpty;

  FilterOptions.from(FilterOptions other)
      : selectedSkills = Set.from(other.selectedSkills),
        selectedLocations = Set.from(other.selectedLocations),
        selectedQualifications = Set.from(other.selectedQualifications),
        selectedEmploymentTypes = Set.from(other.selectedEmploymentTypes),
        selectedColleges = Set.from(other.selectedColleges),
        selectedJobProfiles = Set.from(other.selectedJobProfiles);

  void reset() {
    selectedSkills.clear();
    selectedLocations.clear();
    selectedQualifications.clear();
    selectedEmploymentTypes.clear();
    selectedColleges.clear();
    selectedJobProfiles.clear();
  }
}