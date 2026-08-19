import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

/// Quiz ゲームが要求される Catalog 単語を識別する。
final class QuizGameQuery {
  const QuizGameQuery(this.word);
  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      other is QuizGameQuery && word == other.word;
  @override
  int get hashCode => word.hashCode;
}
