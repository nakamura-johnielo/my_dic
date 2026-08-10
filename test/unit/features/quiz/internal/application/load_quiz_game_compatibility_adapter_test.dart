import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/quiz/internal/application/load_quiz_game_compatibility_adapter.dart';
import 'package:my_dic/features/quiz/internal/game/domain/repository/i_es_en_conjugacion_repository.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_result.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_load_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_game_query.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

void main() {
  Future<QuizGameLoadResult> load({
    Result<CatalogEntryDetail>? detail,
    Result<CatalogConjugation?>? conjugation,
  }) =>
      LoadQuizGameCompatibilityAdapter(
        catalogReader: _Catalog(detail ?? Result.success(_detail)),
        conjugationReader:
            _Conjugation(conjugation ?? const Result.success(null)),
        englishConjugationRepository: _English(),
        assets: QuizGameAssets(),
      ).load(const QuizGameQuery(_word));

  test('maps a primary Catalog not-found to the no-data result', () async {
    final result = await load(
      detail: Result.failure(NotFoundError(message: 'missing word')),
    );

    expect(result, isA<QuizGameNotFound>());
  });

  test('maps a primary Catalog error to its typed source', () async {
    final error = DatabaseError(message: 'catalog unavailable');
    final result = await load(
      detail: Result.failure(error),
    );

    expect(
        result,
        QuizGameLoadResult.failure(
          source: QuizGameLoadSource.primaryCatalog,
          error: error,
        ));
  });

  test('maps a normal null conjugation to no-conjugation', () async {
    final result = await load();

    expect(result, isA<QuizGameNoConjugation>());
  });

  test('maps a conjugation read failure to its typed source', () async {
    final error = NotFoundError(message: 'reader failure');
    final result = await load(conjugation: Result.failure(error));

    expect(
        result,
        QuizGameLoadResult.failure(
          source: QuizGameLoadSource.catalogConjugation,
          error: error,
        ));
  });
}

final _detail = EspJpnEntryDetail(word: _word, entries: const []);

final class _Catalog implements CatalogReader {
  const _Catalog(this.result);
  final Result<CatalogEntryDetail> result;
  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(
          CatalogWordRef word) async =>
      result;
}

final class _Conjugation implements ConjugationReader {
  const _Conjugation(this.result);
  final Result<CatalogConjugation?> result;
  @override
  Future<Result<CatalogConjugation?>> getConjugation(
          CatalogWordRef word) async =>
      result;
  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async =>
      const Result.success(false);
}

final class _English implements IEsEnConjugacionRepository {
  @override
  Future<Result<Map<String, String>>> getEnglishConjById(int id) async =>
      const Result.success({});
}
