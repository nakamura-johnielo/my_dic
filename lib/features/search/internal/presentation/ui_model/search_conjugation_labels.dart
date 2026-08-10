import 'package:my_dic/features/search/port/model/search_conjugation_match_key.dart';

extension SearchMoodTenseLabel on SearchMoodTense {
  String get shortLabel => switch (this) {
        SearchMoodTense.participlePresent => '現分',
        SearchMoodTense.participlePast => '過分',
        SearchMoodTense.indicativePresent => '直現在',
        SearchMoodTense.indicativePreterite => '直点過去',
        SearchMoodTense.indicativeImperfect => '直線過去',
        SearchMoodTense.indicativeFuture => '直未来',
        SearchMoodTense.indicativeConditional => '直過去未来',
        SearchMoodTense.imperative => '命令',
        SearchMoodTense.subjunctivePresent => '接現在',
        SearchMoodTense.subjunctivePast => '接過去',
      };
}
