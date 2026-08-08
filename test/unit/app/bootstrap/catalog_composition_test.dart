import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_reader_adapter.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_conjugation_reader_adapter.dart';

void main() {
  test('resolves Catalog readers from overridden legacy repositories', () {
    final container = ProviderContainer(
      overrides: [
        esjDictionaryRepositoryProvider.overrideWithValue(_EspRepository()),
        jpnEspDictionaryRepositoryProvider.overrideWithValue(_JpnRepository()),
        conjugacionsRepositoryProvider
            .overrideWithValue(_ConjugationRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(catalogReaderProvider),
      isA<LegacyCatalogReaderAdapter>(),
    );
    expect(
      container.read(conjugationReaderProvider),
      isA<LegacyConjugationReaderAdapter>(),
    );
  });
}

final class _EspRepository implements IEsjDictionaryRepository {
  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int id) async =>
      const Result.success([]);
}

final class _JpnRepository implements IJpnEspDictionaryRepository {
  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
    int wordId,
  ) async =>
      const Result.success([]);
}

final class _ConjugationRepository implements IConjugacionsRepository {
  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async =>
      const Result.success(null);

  @override
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
      throw UnimplementedError();

  @override
  Future<Result<List<ConjugacionSearchResultItem>>>
      getQuizConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) =>
          throw UnimplementedError();

  @override
  Future<Result<bool>> hasConjByWordId(int wordId) async =>
      const Result.success(false);
}
