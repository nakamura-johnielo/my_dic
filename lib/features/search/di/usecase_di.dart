import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_interactor.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_interactor.dart';

final searchWordUseCaseProvider = Provider<ISearchWordUseCase>((ref) {
  return SearchWordInteractor(ref.read(searchQueryRepositoryProvider));
});

final judgeSearchWordUseCaseProvider = Provider<IJudgeSearchWordUseCase>((ref) {
  return JudgeSearchWordInteractor();
});
