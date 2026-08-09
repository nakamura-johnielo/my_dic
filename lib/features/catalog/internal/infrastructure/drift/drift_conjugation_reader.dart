import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/conjugation_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_entity_mapper.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

/// Catalog's public conjugation reader backed by its Drift repository graph.
final class DriftConjugationReader implements ConjugationReader {
  const DriftConjugationReader(this._repository);

  final IConjugacionsRepository _repository;

  @override
  Future<Result<CatalogConjugation?>> getConjugation(
    CatalogWordRef word,
  ) async {
    if (word.catalogId == CatalogId.jpnEspMain) return _unsupported();

    final result = await _repository.getConjugacionByWordId(word.wordId);
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
    return _repository.hasConjByWordId(word.wordId);
  }

  Result<T> _unsupported<T>() => Result.failure(
        BusinessRuleError(
          message: 'Conjugation is not supported for the Jpn-Esp Catalog.',
        ),
      );
}
