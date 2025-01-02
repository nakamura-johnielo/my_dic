enum ExamplesColumns {
  exampleId,
  dictionaryId,
  exampleNo,
  espanolHtml,
  japaneseText,
  espanolText,
}

extension ExamplesColumnsExtension on ExamplesColumns {
  String get columnName {
    switch (this) {
      case ExamplesColumns.exampleId:
        return 'example_id';
      case ExamplesColumns.dictionaryId:
        return 'dictionary_id';
      case ExamplesColumns.exampleNo:
        return 'example_no';
      case ExamplesColumns.espanolHtml:
        return 'espanol_html';
      case ExamplesColumns.japaneseText:
        return 'japanese_text';
      case ExamplesColumns.espanolText:
        return 'espanol_text';
    }
  }
}
