import 'package:my_dic/features/catalog/port/catalog.dart';

/// 単語詳細ページに必要な辞書コンテンツを識別します。
final class WordDetailQuery {
  WordDetailQuery({required this.word}) {
    if (word.wordId <= 0) {
      throw ArgumentError.value(word.wordId, 'word.wordId', 'must be positive');
    }
  }

  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordDetailQuery && other.word == word;

  @override
  int get hashCode => word.hashCode;
}
