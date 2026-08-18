import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_semantic_content_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_semantic_entry_detail.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_entry_detail_reader_port.dart';
import 'package:my_dic/features/catalog/port/queryport/catalog_semantic_entry_detail_reader_port.dart';

final class DriftCatalogSemanticEntryDetailQueryService
    implements CatalogSemanticEntryDetailQueryPort {
  const DriftCatalogSemanticEntryDetailQueryService(
    this._source, {
    CatalogSemanticContentMapper mapper = const CatalogSemanticContentMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _mapper = mapper,
        _errorMapper = errorMapper;

  final CatalogEntryDetailQueryPort _source;
  final CatalogSemanticContentMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogSemanticEntryDetail>> readSemanticEntryDetail(
    CatalogWordRef word,
  ) async {
    final result = await _source.readEntryDetail(word);
    return result.when(
      success: (detail) {
        try {
          return Result.success(_mapper.detail(detail));
        } catch (cause, stackTrace) {
          return Result.failure(_errorMapper.conversion(cause, stackTrace));
        }
      },
      failure: Result.failure,
    );
  }
}
