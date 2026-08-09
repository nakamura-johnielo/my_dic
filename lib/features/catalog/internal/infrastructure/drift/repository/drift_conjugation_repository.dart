import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/conjugation_search_result_item.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/search_result_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class DriftConjugationRepository implements IConjugacionsRepository {
  DriftConjugationRepository(this._dataSource);
  final IConjugacionLocalDataSource _dataSource;

  @override
  Future<Result<bool>> hasConjByWordId(int wordId) async {
    try {
      return Result.success(await _dataSource.existsConjByWordId(wordId));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '豢ｻ逕ｨ蠖｢縺ｮ譛臥┌縺ｮ遒ｺ隱阪↓螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async {
    try {
      return Result.success(
        CatalogDriftMapper.conjugation(
          await _dataSource.getConjugacionByWordId(id),
        ),
      );
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '豢ｻ逕ｨ蠖｢縺ｮ蜿門ｾ励↓螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
    String word,
    int size,
    int currentPage,
  ) async {
    try {
      final rows = await _dataSource.getConjugacionByWordWithPage(
        word,
        size,
        currentPage,
      );
      return Result.success(
        rows.map(CatalogDriftMapper.conjugationSearchResult).toList(),
      );
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '豢ｻ逕ｨ蠖｢讀懃ｴ｢縺ｫ螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<ConjugacionSearchResultItem>>> searchConjugations(
    String word,
    int size,
    int currentPage,
  ) async {
    try {
      final rows = await _dataSource.searchConjugationsAcrossCatalog(
        word,
        size,
        currentPage,
      );
      return Result.success(
        rows.map(CatalogDriftMapper.conjugationSearchItem).toList(),
      );
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '繧ｯ繧､繧ｺ逕ｨ豢ｻ逕ｨ蠖｢讀懃ｴ｢縺ｫ螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
