import 'package:my_dic/Constants/Enums/i_enum.dart';

enum FeatureTag with DisplayEnumMixin {
  learned,
  hasNote,
  isBookmarked,
  myWord;

  @override
  String get display {
    return japName;
  }
}

extension FeatureTagExtension on FeatureTag {
  String get japName {
    switch (this) {
      case FeatureTag.learned:
        return "Done";
      case FeatureTag.hasNote:
        return "メモ";
      case FeatureTag.isBookmarked:
        return "book mark";
      case FeatureTag.myWord:
        return "my word";
    }
  }
}
