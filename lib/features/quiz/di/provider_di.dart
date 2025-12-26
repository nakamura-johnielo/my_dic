import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/di/usecase_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';


final conjEnglishProvider = FutureProvider<Map<String, String>>((ref) async {
  final usecase=ref.read(fetchEnglishConjSubUsecaseProvider);
  return await usecase.getConjEnglishGuide();
});

final beConjProvider =
    FutureProvider<Map<String, Map<String, String>>>((ref) async {
  final usecase=ref.read(fetchEnglishConjSubUsecaseProvider);
  return await usecase.getConjOfBe();
});

// 追加: DBから英語活用を取得（wordIdごと）
final englishConjByWordIdProvider =
    FutureProvider.family<Map<String, String>, int>((ref, wordId) async {
  final controller = ref.read(quizGameViewModelProvider.notifier);
  // final controller = ref.read(quizControllerProvider);
  return controller.fetchEnglishConj(wordId);
});
