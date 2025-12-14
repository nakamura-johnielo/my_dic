import 'package:flutter/foundation.dart';

@immutable
class Ranking {
  final int rank;
  final String rankedWord; //ランクに選定されてる形の単語
  final String lemma; //原形
  final int wordId;
  final bool hasConj;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  const Ranking({
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required this.wordId,
    this.hasConj = false,
    this.isLearned = false,
    this.isBookmarked = false,
    this.hasNote = false,
  });

  Ranking copyWith({
    int? rank,
    String? rankedWord,
    String? lemma,
    int? wordId,
    bool? hasConj,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return Ranking(
      rank: rank ?? this.rank,
      rankedWord: rankedWord ?? this.rankedWord,
      lemma: lemma ?? this.lemma,
      wordId: wordId ?? this.wordId,
      hasConj: hasConj ?? this.hasConj,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}
