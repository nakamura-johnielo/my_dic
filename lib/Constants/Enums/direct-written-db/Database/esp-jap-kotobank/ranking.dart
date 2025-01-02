enum RankingsColumns {
  rankingId,
  rankingNo,
  word,
  wordOrigin,
  wordId,
}

extension RankingsColumnsExtension on RankingsColumns {
  String get columnName {
    switch (this) {
      case RankingsColumns.rankingId:
        return 'ranking_id';
      case RankingsColumns.rankingNo:
        return 'ranking_no';
      case RankingsColumns.word:
        return 'word';
      case RankingsColumns.wordOrigin:
        return 'word_origin';
      case RankingsColumns.wordId:
        return 'word_id';
    }
  }
}
