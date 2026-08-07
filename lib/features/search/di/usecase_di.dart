import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/data/datasource.dart';
import 'package:my_dic/features/search/application/query/i_search_query_repository.dart';
import 'package:my_dic/features/search/data/query/drift_search_query_repository.dart';
import 'package:my_dic/features/search/data/query/search_query_dao.dart';
import 'package:my_dic/features/search/data/query/search_ranking_lookup.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_interactor.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/application/usecase/search_word/search_word_interactor.dart';

final searchWordUseCaseProvider = Provider<ISearchWordUseCase>((ref) {
  return SearchWordInteractor(ref.read(searchQueryRepositoryProvider));
});

final searchQueryRepositoryProvider = Provider<ISearchQueryRepository>((ref) {
  return DriftSearchQueryRepository(
    SearchQueryDao(
      ref.read(esjWordDataSourceProvider),
      ref.read(jpnEspWordDataSourceProvider),
      ref.read(conjugacionDataSourceProvider),
    ),
    ref.read(esjDictionaryDataSourceProvider),
    ref.read(jpnEspDictionaryDataSourceProvider),
    ref.read(conjugacionDataSourceProvider),
    SearchRankingLookup(ref.read(databaseProvider)),
  );
});

final judgeSearchWordUseCaseProvider = Provider<IJudgeSearchWordUseCase>((ref) {
  return JudgeSearchWordInteractor();
});
