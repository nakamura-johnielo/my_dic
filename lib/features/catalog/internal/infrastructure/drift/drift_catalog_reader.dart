import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/esp_jpn_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/jpn_esp_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entity_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_entry_detail_reader_port.dart';

/// Catalog 所有のリポジトリグラフを基盤とする、Catalog の公開詳細リーダー。
final class DriftCatalogEntryDetailQueryService
    implements CatalogEntryDetailQueryPort {
  const DriftCatalogEntryDetailQueryService({
    required IEspJpnDictionaryRepository espJpnRepository,
    required IJpnEspDictionaryRepository jpnEspRepository,
  })  : _espJpnRepository = espJpnRepository,
        _jpnEspRepository = jpnEspRepository;

  final IEspJpnDictionaryRepository _espJpnRepository;
  final IJpnEspDictionaryRepository _jpnEspRepository;

  @override
  Future<Result<CatalogEntryDetail>> readEntryDetail(CatalogWordRef word) =>
      _read(word);

  Future<Result<CatalogEntryDetail>> _read(CatalogWordRef word) async {
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
