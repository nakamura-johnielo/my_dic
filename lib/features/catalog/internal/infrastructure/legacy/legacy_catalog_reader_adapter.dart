import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';

final class LegacyCatalogReaderAdapter implements CatalogReader {
  const LegacyCatalogReaderAdapter({
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
          success: (dictionaries) => Result.success(
              LegacyCatalogMapper.espJpnDetail(word, dictionaries)),
          failure: Result.failure,
        );
      case CatalogId.jpnEspMain:
        final result =
            await _jpnEspRepository.getDictionaryByWordId(word.wordId);
        return result.when(
          success: (dictionaries) => Result.success(
              LegacyCatalogMapper.jpnEspDetail(word, dictionaries)),
          failure: Result.failure,
        );
    }
  }
}
