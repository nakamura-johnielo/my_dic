import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/catalog_conjugation_store.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/esp_jpn_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/jpn_esp_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_catalog_reader.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/drift_conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';

void main() {
  test('dispatches dictionary reads by CatalogId using the raw wordId',
      () async {
    final esp = _EspRepository(Result.success(
      const [EspJpnDictionary(dictionaryId: 1, word: 'hablar')],
    ));
    final jpn = _JpnRepository(Result.success(
      const [JpnEspDictionary(id: 2, wordId: 43, word: '話す')],
    ));
    final reader = DriftCatalogEntryDetailQueryService(
      espJpnRepository: esp,
      jpnEspRepository: jpn,
    );

    final espResult = await reader.readEntryDetail(
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 41),
    );
    final jpnResult = await reader.readEntryDetail(
      const CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 43),
    );

    expect(esp.requestedIds, [41]);
    expect(jpn.requestedIds, [43]);
    expect(espResult.dataOrNull, isA<EspJpnEntryDetail>());
    expect(jpnResult.dataOrNull, isA<JpnEspEntryDetail>());
  });

  test('preserves repository error subtype, message, cause, and identity',
      () async {
    final cause = StateError('query failed');
    final error = DatabaseError(
      message: 'stable repository failure',
      originalError: cause,
    );
    final reader = DriftCatalogEntryDetailQueryService(
      espJpnRepository: _EspRepository(Result.failure(error)),
      jpnEspRepository: _JpnRepository(const Result.success([])),
    );

    final result = await reader.readEntryDetail(
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9),
    );
    expect(result.errorOrNull, same(error));
    expect(result.errorOrNull, isA<DatabaseError>());
    expect(result.errorOrNull!.message, 'stable repository failure');
    expect(result.errorOrNull!.originalError, same(cause));
  });

  test('preserves dictionary not-found as the identical error', () async {
    final error = NotFoundError(message: 'stable not-found');
    final reader = DriftCatalogEntryDetailQueryService(
      espJpnRepository: _EspRepository(Result.failure(error)),
      jpnEspRepository: _JpnRepository(const Result.success([])),
    );

    final result = await reader.readEntryDetail(
      const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 10),
    );
    expect(result.errorOrNull, same(error));
    expect(result.errorOrNull, isA<NotFoundError>());
    expect(result.errorOrNull!.message, 'stable not-found');
  });

  test('preserves EspJpn null conjugation and failure identity', () async {
    final error = BusinessRuleError(message: 'conjugation failure');
    final repository = _ConjugationRepository(
      conjugation: Result.failure(error),
      hasConjugation: const Result.success(true),
    );
    final reader = DriftCatalogConjugationQueryService(repository);
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 58);

    expect((await reader.readConjugation(word)).errorOrNull, same(error));
    expect((await reader.hasConjugation(word)).dataOrNull, isTrue);
    expect(repository.conjugationIds, [58]);
    expect(repository.hasIds, [58]);

    final notFound = DriftCatalogConjugationQueryService(_ConjugationRepository(
      conjugation: const Result.success(null),
      hasConjugation: const Result.success(false),
    ));
    expect((await notFound.readConjugation(word)).dataOrNull, isNull);
  });

  test('rejects JpnEsp conjugation with the stable business error', () async {
    final repository = _ConjugationRepository(
      conjugation: const Result.success(null),
      hasConjugation: const Result.success(false),
    );
    final reader = DriftCatalogConjugationQueryService(repository);
    const word = CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 64);

    final conjugation = await reader.readConjugation(word);
    final hasConjugation = await reader.hasConjugation(word);
    expect(conjugation.errorOrNull, isA<BusinessRuleError>());
    expect(hasConjugation.errorOrNull, isA<BusinessRuleError>());
    expect(
      conjugation.errorOrNull!.message,
      'Conjugation is not supported for the Jpn-Esp Catalog.',
    );
    expect(
      hasConjugation.errorOrNull!.message,
      'Conjugation is not supported for the Jpn-Esp Catalog.',
    );
    expect(repository.conjugationIds, isEmpty);
    expect(repository.hasIds, isEmpty);
  });
}

final class _EspRepository implements EspJpnDictionaryStore {
  _EspRepository(this.result);
  final Result<List<EspJpnDictionary>> result;
  final List<int> requestedIds = [];

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id) async {
    requestedIds.add(id);
    return result;
  }
}

final class _JpnRepository implements JpnEspDictionaryStore {
  _JpnRepository(this.result);
  final Result<List<JpnEspDictionary>> result;
  final List<int> requestedIds = [];

  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
    int wordId,
  ) async {
    requestedIds.add(wordId);
    return result;
  }
}

final class _ConjugationRepository implements CatalogConjugationStore {
  _ConjugationRepository({
    required this.conjugation,
    required this.hasConjugation,
  });
  final Result<EspJpnConjugation?> conjugation;
  final Result<bool> hasConjugation;
  final List<int> conjugationIds = [];
  final List<int> hasIds = [];

  @override
  Future<Result<EspJpnConjugation?>> getConjugationByWordId(int id) async {
    conjugationIds.add(id);
    return conjugation;
  }

  @override
  Future<Result<bool>> hasConjugationByWordId(int wordId) async {
    hasIds.add(wordId);
    return hasConjugation;
  }

}
