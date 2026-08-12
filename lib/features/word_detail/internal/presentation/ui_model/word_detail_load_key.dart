import 'package:flutter/foundation.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

/// Identifies the complete read request represented by a word-detail page.
@immutable
class WordDetailLoadKey {
  const WordDetailLoadKey(this.word);

  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      other is WordDetailLoadKey && other.word == word;

  @override
  int get hashCode => word.hashCode;
}
