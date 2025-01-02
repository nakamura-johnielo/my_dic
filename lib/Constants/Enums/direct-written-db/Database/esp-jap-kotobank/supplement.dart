enum SupplementsColumns {
  supplementId,
  dictionaryId,
  supplementNo,
  content,
  exampleId,
}

extension SupplementsColumnsExtension on SupplementsColumns {
  String get columnName {
    switch (this) {
      case SupplementsColumns.supplementId:
        return 'supplement_id';
      case SupplementsColumns.dictionaryId:
        return 'dictionary_id';
      case SupplementsColumns.supplementNo:
        return 'supplement_no';
      case SupplementsColumns.content:
        return 'content';
      case SupplementsColumns.exampleId:
        return 'example_id';
    }
  }
}
