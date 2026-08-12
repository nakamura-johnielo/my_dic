import 'package:my_dic/features/catalog/port/catalog.dart';

/// Identifies the Catalog word for which a Quiz game is loaded.
final class QuizGameQuery {
  const QuizGameQuery(this.word);

  final CatalogWordRef word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is QuizGameQuery && word == other.word;

  @override
  int get hashCode => word.hashCode;

  @override
  String toString() => 'QuizGameQuery(word: $word)';
}
