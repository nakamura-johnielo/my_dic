import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/catalog_conjugation_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entity_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/reader/catalog_conjugation_reader_port.dart';

///  Driftリポジトリグラフを基盤とする、Catalogの公開活用形リーダー。
final class DriftCatalogConjugationQueryService
    implements CatalogConjugationQueryPort {
  const DriftCatalogConjugationQueryService(this._repository);

  final ICatalogConjugationRepository _repository;

  @override
  Future<Result<CatalogConjugation?>> readConjugation(CatalogWordRef word) =>
      _read(word);

  Future<Result<CatalogConjugation?>> _read(CatalogWordRef word) async {
    if (word.catalogId == CatalogId.jpnEspMain) return _unsupported();

    final result = await _repository.getConjugationByWordId(word.wordId);
    return result.when(
      success: (entity) => Result.success(
        entity == null ? null : CatalogEntityMapper.conjugation(word, entity),
      ),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async {
    if (word.catalogId == CatalogId.jpnEspMain) return _unsupported();
    return _repository.hasConjugationByWordId(word.wordId);
  }

  Result<T> _unsupported<T>() => Result.failure(
        BusinessRuleError(
          message: 'Conjugation is not supported for the Jpn-Esp Catalog.',
        ),
      );
}
