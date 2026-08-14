import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/catalog_conjugation_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/conjugation/conjugation_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class CatalogConjugationRepository implements ICatalogConjugationRepository {
  CatalogConjugationRepository(this._dataSource);
  final ConjugationDataSource _dataSource;

  @override
  Future<Result<bool>> hasConjugationByWordId(int wordId) async {
    try {
      return Result.success(
        await _dataSource.existsConjugationByWordId(wordId),
      );
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'データベースエラーが発生しました',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<EspJpnConjugation?>> getConjugationByWordId(int id) async {
    try {
      return Result.success(
        CatalogDriftMapper.conjugation(
          await _dataSource.getConjugationByWordId(id),
        ),
      );
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'データベースエラーが発生しました',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
