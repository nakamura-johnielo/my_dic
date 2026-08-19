import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/conjugation/esp_conjugations.dart';

/// 任意の活用形データに対する Catalog 内部の永続化境界。
abstract interface class ICatalogConjugationRepository {
  Future<Result<EspJpnConjugation?>> getConjugationByWordId(int id);

  Future<Result<bool>> hasConjugationByWordId(int wordId);
}
