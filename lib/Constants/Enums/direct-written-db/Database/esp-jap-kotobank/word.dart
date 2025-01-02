enum WordsColumns {
  wordId,
  word,
  partOfSpeech,
  partOfSpeechMark,
}

extension WordsColumnsExtension on WordsColumns {
  String get columnName {
    switch (this) {
      case WordsColumns.wordId:
        return 'word_id';
      case WordsColumns.word:
        return 'word';
      case WordsColumns.partOfSpeech:
        return 'part_of_speech';
      case WordsColumns.partOfSpeechMark:
        return 'part_of_speech_mark';
    }
  }
}
