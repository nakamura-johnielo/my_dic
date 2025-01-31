import 'package:freezed_annotation/freezed_annotation.dart';
part '../../../__generated/_Business_Rule/_Domain/Entities/ranking.freezed.dart';

@freezed
class Ranking with _$Ranking {
  const factory Ranking({
    required int rank,
    required String rankedWord, //ランクに選定されてる形の単語
    required String lemma, //原形
    required int wordId,
    @Default(false) bool hasConj,
    @Default(false) bool isLearned,
    @Default(false) bool isBookmarked,
    @Default(false) bool hasNote,
  }) = _Ranking;
}
