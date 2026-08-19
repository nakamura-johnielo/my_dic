import 'package:my_dic/features/catalog/port/catalog.dart';

/// Quiz ゲームのプレゼンテーションエントリに渡す一時的な入力。
///
/// ルート解析はアプリ所有のままである。この入力は意図的にルート契約ではなく、URL
/// シリアライズを考慮する必要もない。
final class QuizGamePresentationInput {
  const QuizGamePresentationInput({required this.word, this.displayHint});

  final CatalogWordRef word;
  final String? displayHint;
}
