import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/esp_jpn_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/jpn_esp_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entity_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';

/// Catalog's public detail reader backed by the Catalog-owned repository graph.
final class DriftCatalogReaderPort implements CatalogReaderPort {
  const DriftCatalogReaderPort({
    required IEsjDictionaryRepository espJpnRepository,
    required IJpnEspDictionaryRepository jpnEspRepository,
  })  : _espJpnRepository = espJpnRepository,
        _jpnEspRepository = jpnEspRepository;

  final IEsjDictionaryRepository _espJpnRepository;
  final IJpnEspDictionaryRepository _jpnEspRepository;

  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(CatalogWordRef word) async {
    switch (word.catalogId) {
      case CatalogId.espJpnMain:
        final result =
            await _espJpnRepository.getDictionaryByWordId(word.wordId);
        return result.when(
          success: (entries) => Result.success(
            CatalogEntityMapper.espJpnDetail(word, entries),
          ),
          failure: Result.failure,
        );
      case CatalogId.jpnEspMain:
        final result =
            await _jpnEspRepository.getDictionaryByWordId(word.wordId);
        return result.when(
          success: (entries) => Result.success(
            CatalogEntityMapper.jpnEspDetail(word, entries),
          ),
          failure: Result.failure,
        );
    }
  }
}
