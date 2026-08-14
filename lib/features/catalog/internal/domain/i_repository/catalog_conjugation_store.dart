import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';

/// Catalog-internal persistence boundary for optional conjugation data.
abstract interface class ICatalogConjugationRepository {
  Future<Result<EspJpnConjugation?>> getConjugationByWordId(int id);

  Future<Result<bool>> hasConjugationByWordId(int wordId);
}
