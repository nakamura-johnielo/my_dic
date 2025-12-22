import 'package:my_dic/core/common/enums/i_enum.dart';

enum FeatureTag with DisplayEnumMixin {
  isLearned,
  hasNote,
  isBookmarked,
  multiLemma,
  myWord;

  @override
  String get display {
    return japName;
  }

  @override
  String get dbColName {
    return dbColumnName;
  }
}

extension FeatureTagExtension on FeatureTag {
  String get japName {
    switch (this) {
      case FeatureTag.isLearned:
        return "Done";
      case FeatureTag.hasNote:
        return "メモ";
      case FeatureTag.isBookmarked:
        return "book mark";
      case FeatureTag.myWord:
        return "my word";
      case FeatureTag.multiLemma:
        return "ダブり表示なし";
    }
  }
}

extension FeatureTagDbColNameExtension on FeatureTag {
  String get dbColumnName {
    switch (this) {
      case FeatureTag.isLearned:
        return "is_learned";
      case FeatureTag.hasNote:
        return "has_note";
      case FeatureTag.isBookmarked:
        return "is_bookmarked";
      case FeatureTag.myWord:
        return "my_word";
      case FeatureTag.multiLemma:
        return "";
    }
  }
}
