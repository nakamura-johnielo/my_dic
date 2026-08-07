import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/application/query/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query_result.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';

/// Aggregates the catalog reads needed by a word-detail page.
class LoadWordDetailQuery implements ILoadWordDetailQuery {
  LoadWordDetailQuery(
    this._esjDictionaryRepository,
    this._jpnEspDictionaryRepository,
    this._conjugacionsRepository,
  );

  final IEsjDictionaryRepository _esjDictionaryRepository;
  final IJpnEspDictionaryRepository _jpnEspDictionaryRepository;
  final IConjugacionsRepository _conjugacionsRepository;

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) =>
      switch (query.wordType) {
        WordType.espJpn => _loadEspJpn(query),
        WordType.jpnEsp => _loadJpnEsp(query),
        WordType.espEng || WordType.engEsp => Future.value(
            Result.failure(BusinessRuleError(
              message: 'Unsupported word detail direction: ${query.wordType}',
            )),
          ),
      };

  Future<Result<WordDetailQueryResult>> _loadJpnEsp(
    WordDetailQuery query,
  ) async {
    final result = await _jpnEspDictionaryRepository.getDictionaryByWordId(
      query.wordId,
    );
    return result.when(
      success: (dictionaries) => Result.success(
        WordDetailQueryResult(
          viewData: JpnEspWordDetailViewData(dictionaries: dictionaries),
        ),
      ),
      failure: Result.failure,
    );
  }

  Future<Result<WordDetailQueryResult>> _loadEspJpn(
    WordDetailQuery query,
  ) async {
    final dictionaryResult =
        await _esjDictionaryRepository.getDictionaryByWordId(
      query.wordId,
    );
    if (dictionaryResult case Failure(error: final error)) {
      return Result.failure(error);
    }

    final dictionaries = dictionaryResult.dataOrNull!;
    if (!query.hasConjugation) {
      return Result.success(
        WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(dictionaries: dictionaries),
        ),
      );
    }

    final conjugationResult =
        await _conjugacionsRepository.getConjugacionByWordId(query.wordId);
    return conjugationResult.when(
      success: (conjugation) => Result.success(
        WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(
            dictionaries: dictionaries,
            conjugation: conjugation,
          ),
        ),
      ),
      failure: (error) => Result.success(
        WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(dictionaries: dictionaries),
          issue: QueryIssue(source: 'conjugation', error: error),
        ),
      ),
    );
  }
}
