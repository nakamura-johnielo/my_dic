import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_esp_jpn_dictionary_repository.dart';

void main() {
  group('Catalog Drift repositories', () {
    test('Esp-Jpn empty result preserves the NotFoundError contract', () async {
      final result = await EsjDictionaryRepository(_DictionaryDataSource())
          .getDictionaryByWordId(42);

      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('database failure preserves the original error identity', () async {
      final cause = StateError('database unavailable');
      final result = await EsjDictionaryRepository(
        _DictionaryDataSource(error: cause),
      ).getDictionaryByWordId(42);

      expect(result.errorOrNull, isA<DatabaseError>());
      expect(result.errorOrNull!.originalError, same(cause));
    });

    test('neutral conjugation search delegates size and zero-based page',
        () async {
      final dataSource = _ConjugationDataSource();
      final result = await DriftConjugationRepository(dataSource)
          .searchConjugations('hab', 20, 3);

      expect(result.dataOrNull, isEmpty);
      expect(dataSource.searchArguments, ('hab', 20, 3));
    });

    test('neutral conjugation search preserves failure identity', () async {
      final cause = StateError('query failed');
      final result = await DriftConjugationRepository(
        _ConjugationDataSource(error: cause),
      ).searchConjugations('hab', 20, 0);

      expect(result.errorOrNull, isA<DatabaseError>());
      expect(result.errorOrNull!.originalError, same(cause));
    });
  });
}

final class _DictionaryDataSource implements IEsjDictionaryLocalDataSource {
  _DictionaryDataSource({this.error});
  final Object? error;

  @override
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(
      int wordId) async {
    if (error case final error?) throw error;
    return [];
  }

  @override
  Future<Map<int, String>> getFirstContentsByWordIds(List<int> wordIds) =>
      throw UnimplementedError();
  @override
  Future<Map<int, String>> getFirstHeadwordsByWordIds(List<int> wordIds) =>
      throw UnimplementedError();
  @override
  Future<String?> getFirstContentByWordId(int wordId) =>
      throw UnimplementedError();
  @override
  Future<String?> getFirstHeadwordByWordId(int wordId) =>
      throw UnimplementedError();
  @override
  Future<String?> getHeadwordById(int id) => throw UnimplementedError();
  @override
  Future<String?> getSimpleMeaningById(int id) => throw UnimplementedError();
}

final class _ConjugationDataSource implements IConjugacionLocalDataSource {
  _ConjugationDataSource({this.error});
  final Object? error;
  (String, int, int)? searchArguments;

  @override
  Future<List<EspConjugationTableData>> searchConjugationsAcrossCatalog(
    String word,
    int size,
    int currentPage,
  ) async {
    searchArguments = (word, size, currentPage);
    if (error case final error?) throw error;
    return [];
  }

  @override
  Future<bool> existsConjByWordId(int wordId) => throw UnimplementedError();
  @override
  Future<EspConjugationTableData?> getConjugacionByWordId(int id) =>
      throw UnimplementedError();
  @override
  Future<List<EspConjugationTableData>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
      throw UnimplementedError();
  @override
  Future<Map<int, String>> getMeaningsByWordIds(List<int> wordIds) =>
      throw UnimplementedError();
  @override
  Future<String?> getSimpleMeaningById(int id) => throw UnimplementedError();
}
