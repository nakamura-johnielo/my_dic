import 'package:flutter/foundation.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// 単語詳細ページが表す完全な読み込み要求を識別します。
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
