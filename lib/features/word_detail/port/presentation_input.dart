import 'package:my_dic/features/catalog/port/catalog.dart';

/// 単語詳細エントリ用の一時的な表示データです。
///
/// [highlight] は意図的にルートまたは URL の識別フィールドではありません。
final class WordDetailPresentationInput {
  const WordDetailPresentationInput({required this.word, this.highlight});

  final CatalogWordRef word;
  final String? highlight;
}
