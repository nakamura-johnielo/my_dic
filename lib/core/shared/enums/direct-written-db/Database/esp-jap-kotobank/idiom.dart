enum IdiomsColumns {
  idiomId,
  dictionaryId,
  idiomNo,
  idiom,
  description,
}

extension IdiomsColumnsExtension on IdiomsColumns {
  String get columnName {
    switch (this) {
      case IdiomsColumns.idiomId:
        return 'idiom_id';
      case IdiomsColumns.dictionaryId:
        return 'dictionary_id';
      case IdiomsColumns.idiomNo:
        return 'idiom_no';
      case IdiomsColumns.idiom:
        return 'idiom';
      case IdiomsColumns.description:
        return 'description';
    }
  }
}
