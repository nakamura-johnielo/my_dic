import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_read_error_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_search_hit_mapper.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/catalog_like_pattern.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';
import 'package:my_dic/features/catalog/port/query/catalog_conjugation_search_query.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_search_reader_port.dart';
import 'package:my_dic/features/catalog/port/result/catalog_search_page.dart';

final class DriftCatalogConjugationSearchQueryService
    implements CatalogConjugationSearchQueryPort {
  DriftCatalogConjugationSearchQueryService(
    DatabaseProvider database, {
    CatalogSearchHitMapper mapper = const CatalogSearchHitMapper(),
    CatalogReadErrorMapper errorMapper = const CatalogReadErrorMapper(),
  })  : _database = database,
        _mapper = mapper,
        _errorMapper = errorMapper;

  final DatabaseProvider _database;
  final CatalogSearchHitMapper _mapper;
  final CatalogReadErrorMapper _errorMapper;

  @override
  Future<Result<CatalogSearchPage<CatalogConjugationSearchHit>>>
      searchConjugations(CatalogConjugationSearchQuery query) async {
    late final List<EspConjugationTableData> rows;
    try {
      rows = await _fetch(query);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.query(cause, stackTrace));
    }

    late final List<CatalogConjugationSearchHit> items;
    try {
      items = rows
          .take(query.size)
          .map((row) => _mapper.conjugation(row, searchText: query.text))
          .toList(growable: false);
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.conversion(cause, stackTrace));
    }

    try {
      return Result.success(CatalogSearchPage(
        items: items,
        hasMore: rows.length > query.size,
      ));
    } catch (cause, stackTrace) {
      return Result.failure(_errorMapper.unexpected(cause, stackTrace));
    }
  }

  Future<List<EspConjugationTableData>> _fetch(
    CatalogConjugationSearchQuery query,
  ) async {
    final pattern = catalogPrefixLikePattern(query.text);
    final statement = _database.select(_database.espConjugations)
      ..where((table) =>
          table.word.like(pattern, escapeChar: catalogLikeEscapeCharacter) |
          _forms(table)
              .map((column) => column.like(
                    pattern,
                    escapeChar: catalogLikeEscapeCharacter,
                  ))
              .reduce((left, right) => left | right))
      ..orderBy([
        (table) => OrderingTerm.desc(table.word.equals(query.text) |
            _forms(table)
                .map((column) => column.equals(query.text))
                .reduce((left, right) => left | right)),
        (table) => OrderingTerm.asc(table.wordId),
      ])
      ..limit(query.size + 1, offset: query.size * query.page);
    return statement.get();
  }
}

List<GeneratedColumn<String>> _forms($EspConjugationsTable table) => [
      table.presentParticiple,
      table.pastParticiple,
      table.indicativePresentYo,
      table.indicativePresentTu,
      table.indicativePresentEl,
      table.indicativePresentNosotros,
      table.indicativePresentVosotros,
      table.indicativePresentEllos,
      table.indicativePreteriteYo,
      table.indicativePreteriteTu,
      table.indicativePreteriteEl,
      table.indicativePreteriteNosotros,
      table.indicativePreteriteVosotros,
      table.indicativePreteriteEllos,
      table.indicativeImperfectYo,
      table.indicativeImperfectTu,
      table.indicativeImperfectEl,
      table.indicativeImperfectNosotros,
      table.indicativeImperfectVosotros,
      table.indicativeImperfectEllos,
      table.indicativeFutureYo,
      table.indicativeFutureTu,
      table.indicativeFutureEl,
      table.indicativeFutureNosotros,
      table.indicativeFutureVosotros,
      table.indicativeFutureEllos,
      table.indicativeConditionalYo,
      table.indicativeConditionalTu,
      table.indicativeConditionalEl,
      table.indicativeConditionalNosotros,
      table.indicativeConditionalVosotros,
      table.indicativeConditionalEllos,
      table.imperativeTu,
      table.imperativeEl,
      table.imperativeNosotros,
      table.imperativeVosotros,
      table.imperativeEllos,
      table.subjunctivePresentYo,
      table.subjunctivePresentTu,
      table.subjunctivePresentEl,
      table.subjunctivePresentNosotros,
      table.subjunctivePresentVosotros,
      table.subjunctivePresentEllos,
      table.subjunctivePastYo,
      table.subjunctivePastTu,
      table.subjunctivePastEl,
      table.subjunctivePastNosotros,
      table.subjunctivePastVosotros,
      table.subjunctivePastEllos,
    ];
