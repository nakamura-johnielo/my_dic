import 'package:my_dic/core/application/model/query_issue.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/port/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query_result.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';

/// Aggregates the catalog reads needed by a word-detail page.
class LoadWordDetailQuery implements ILoadWordDetailQuery {
  LoadWordDetailQuery(
    this._catalogQueryPort,
    this._conjugationQueryPort,
  );

  final CatalogQueryPort _catalogQueryPort;
  final ConjugationQueryPort _conjugationQueryPort;

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) async {
    final detailResult = await _catalogQueryPort.getEntryDetail(query.word);
    if (detailResult case Failure(error: final error)) {
      return Result.failure(error);
    }

    final detail = detailResult.dataOrNull!;
    if (detail.word != query.word) return Result.failure(_identityError(query));

    return switch (detail) {
      EspJpnEntryDetail() => _loadEspJpn(query, detail),
      JpnEspEntryDetail() => _loadJpnEsp(query, detail),
    };
  }

  Future<Result<WordDetailQueryResult>> _loadEspJpn(
    WordDetailQuery query,
    EspJpnEntryDetail detail,
  ) async {
    if (query.word.catalogId != CatalogId.espJpnMain) {
      return Result.failure(_variantError(query));
    }

    final conjugationResult =
        await _conjugationQueryPort.getConjugation(query.word);
    return conjugationResult.when(
      success: (conjugation) => Result.success(
        WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(
            word: query.word,
            entries: detail.entries,
            conjugation: conjugation,
          ),
        ),
      ),
      failure: (error) => Result.success(
        WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(
            word: query.word,
            entries: detail.entries,
          ),
          issue: QueryIssue(source: 'conjugation', error: error),
        ),
      ),
    );
  }

  Future<Result<WordDetailQueryResult>> _loadJpnEsp(
    WordDetailQuery query,
    JpnEspEntryDetail detail,
  ) async {
    if (query.word.catalogId != CatalogId.jpnEspMain) {
      return Result.failure(_variantError(query));
    }
    return Result.success(
      WordDetailQueryResult(
        viewData: JpnEspWordDetailViewData(
          word: query.word,
          entries: detail.entries,
        ),
      ),
    );
  }

  BusinessRuleError _identityError(WordDetailQuery query) => BusinessRuleError(
        message: 'Catalog detail identity does not match requested word: '
            '${query.word}',
      );

  BusinessRuleError _variantError(WordDetailQuery query) => BusinessRuleError(
        message: 'Catalog detail variant does not match requested catalog: '
            '${query.word.catalogId}',
      );
}
