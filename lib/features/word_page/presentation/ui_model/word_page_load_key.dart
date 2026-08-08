import 'package:flutter/foundation.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Identifies the complete read request represented by a word-detail page.
@immutable
class WordPageLoadKey {
  const WordPageLoadKey(this.word);

  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      other is WordPageLoadKey && other.word == word;

  @override
  int get hashCode => word.hashCode;
}
