import 'package:my_dic/features/catalog/port/catalog.dart';

/// Ephemeral input to the Quiz game presentation entry.
///
/// Route parsing remains app-owned; this input is intentionally not a route
/// contract and has no URL serialization concerns.
final class QuizGamePresentationInput {
  const QuizGamePresentationInput({required this.word, this.displayHint});

  final CatalogWordRef word;
  final String? displayHint;
}
