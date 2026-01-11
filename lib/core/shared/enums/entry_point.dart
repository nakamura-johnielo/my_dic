enum EntryPoint {
  search,
  studyRanking,
  studyQuiz,
  studyDashboard,
  myword,
  profile
}
enum EntryPointCategory {
  main,
  study,
  meta
}

extension EntryPointExtension on EntryPoint {
  EntryPointCategory get category {
    switch (this) {
      case EntryPoint.search:
      case EntryPoint.myword:
        return EntryPointCategory.main;
      case EntryPoint.studyRanking:
      case EntryPoint.studyQuiz:
      case EntryPoint.studyDashboard:
        return EntryPointCategory.study;
      case EntryPoint.profile:
        return EntryPointCategory.meta;
    }
  }
}