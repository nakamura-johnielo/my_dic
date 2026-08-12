import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

/// Identifies the Catalog word for which a Quiz game is requested.
final class QuizGameQuery {
  const QuizGameQuery(this.word);
  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      other is QuizGameQuery && word == other.word;
  @override
  int get hashCode => word.hashCode;
}
