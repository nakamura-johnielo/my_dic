import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

/// クイズ検索結果リストのプロバイダー
final quizSearchedItemsProvider =
    StateProvider<List<QuizSearchedItem>>((ref) => []);

/// クイズで選択中の単語IDのプロバイダー
final quizSelectedWordIdProvider = StateProvider<int?>((ref) => null);

final quizWordDataProvider = StateProvider<Conjugacions?>((ref) => null);
