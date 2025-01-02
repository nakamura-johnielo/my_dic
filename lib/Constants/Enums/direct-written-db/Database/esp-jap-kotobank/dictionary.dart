enum DictionariesColumns {
  dictionaryId,
  wordId,
  word,
  excf,
  headword,
  partOfSpeech,
  partOfSpeechMark,
  content,
  origin,
  htmlRaw,
}

extension DictionariesColumnsExtension on DictionariesColumns {
  String get columnName {
    switch (this) {
      case DictionariesColumns.dictionaryId:
        return 'dictionary_id';
      case DictionariesColumns.wordId:
        return 'word_id';
      case DictionariesColumns.word:
        return 'word';
      case DictionariesColumns.excf:
        return 'excf';
      case DictionariesColumns.headword:
        return 'headword';
      case DictionariesColumns.partOfSpeech:
        return 'part_of_speech';
      case DictionariesColumns.partOfSpeechMark:
        return 'part_of_speech_mark';
      case DictionariesColumns.content:
        return 'content';
      case DictionariesColumns.origin:
        return 'origin';
      case DictionariesColumns.htmlRaw:
        return 'html_raw';
    }
  }
}
