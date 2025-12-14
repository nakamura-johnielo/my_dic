enum PartOfSpeechListsColumns {
  partOfSpeechId,
  wordId,
  partOfSpeech,
}

extension PartOfSpeechListsColumnsExtension on PartOfSpeechListsColumns {
  String get columnName {
    switch (this) {
      case PartOfSpeechListsColumns.partOfSpeechId:
        return 'part_of_speech_id';
      case PartOfSpeechListsColumns.wordId:
        return 'word_id';
      case PartOfSpeechListsColumns.partOfSpeech:
        return 'part_of_speech';
    }
  }
}
