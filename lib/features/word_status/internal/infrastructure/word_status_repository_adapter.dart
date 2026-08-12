import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_status/port/repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

/// The persistence boundary for one physical dictionary status dataset.
///
/// The shared application layer only knows [CatalogWordRef].  Dataset and
/// table-specific details deliberately remain behind this interface.
abstract interface class DictionaryWordStatusAdapter {
  CatalogId get catalogId;

  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  });

  Stream<WordStatus> watch(
    CatalogWordRef word, {
    required String accountId,
  });

  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  });
}

/// Dispatches shared status operations to the adapter registered for the
/// [CatalogWordRef.catalogId].
final class WordStatusRepositoryAdapter implements WordStatusRepository {
  WordStatusRepositoryAdapter(Iterable<DictionaryWordStatusAdapter> adapters)
      : _adapters = _buildRegistry(adapters);

  final Map<CatalogId, DictionaryWordStatusAdapter> _adapters;

  static Map<CatalogId, DictionaryWordStatusAdapter> _buildRegistry(
    Iterable<DictionaryWordStatusAdapter> adapters,
  ) {
    final registry = <CatalogId, DictionaryWordStatusAdapter>{};
    for (final adapter in adapters) {
      if (registry.containsKey(adapter.catalogId)) {
        throw ArgumentError.value(
          adapter.catalogId,
          'adapters',
          'A DictionaryWordStatusAdapter is already registered for this CatalogId.',
        );
      }
      registry[adapter.catalogId] = adapter;
    }

    final missing = CatalogId.values.where((id) => !registry.containsKey(id));
    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        missing.toList(growable: false),
        'adapters',
        'A DictionaryWordStatusAdapter is required for every CatalogId.',
      );
    }
    return Map.unmodifiable(registry);
  }

  DictionaryWordStatusAdapter _adapterFor(CatalogWordRef word) =>
      _adapters[word.catalogId]!;

  @override
  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  }) =>
      _adapterFor(word).get(word, accountId: accountId);

  @override
  Stream<WordStatus> watch(
    CatalogWordRef word, {
    required String accountId,
  }) =>
      _adapterFor(word).watch(word, accountId: accountId);

  @override
  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  }) =>
      _adapterFor(word).update(
        word,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote,
        updatedAt: updatedAt,
        accountId: accountId,
      );
}
