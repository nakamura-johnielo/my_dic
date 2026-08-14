import 'package:my_dic/features/ranking/port/ranking.dart';

extension RankingPartOfSpeechLabels on RankingPartOfSpeech {
  String get displayLabel => switch (this) {
        RankingPartOfSpeech.noun => '名詞',
        RankingPartOfSpeech.abbreviation => '略語',
        RankingPartOfSpeech.preposition => '前置詞',
        RankingPartOfSpeech.prefix => '接辞',
        RankingPartOfSpeech.adjective => '形容詞',
        RankingPartOfSpeech.verb => '動詞',
        RankingPartOfSpeech.adverb => '副詞',
        RankingPartOfSpeech.interjection => '間投詞',
        RankingPartOfSpeech.participle => '分詞',
        RankingPartOfSpeech.pronoun => '代名詞',
        RankingPartOfSpeech.conjunction => '接続詞',
        RankingPartOfSpeech.article => '冠詞',
        RankingPartOfSpeech.auxiliaryVerb => '助動詞',
        RankingPartOfSpeech.none => '品詞ナシ',
      };
}

extension RankingStatusFilterLabels on RankingStatusFilter {
  String get displayLabel => switch (this) {
        RankingStatusFilter.learned => 'Done',
        RankingStatusFilter.bookmarked => 'book mark',
        RankingStatusFilter.hasNote => 'メモ',
      };
}
