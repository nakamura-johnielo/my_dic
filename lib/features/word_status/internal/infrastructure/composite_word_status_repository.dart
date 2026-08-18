import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository.dart'
    as domain;

/// The persistence boundary for one physical dictionary status dataset.
///
/// The shared application layer only knows [CatalogWordRef].  Dataset and
/// table-specific details deliberately remain behind this interface.
abstract interface class DictionaryWordStatusStore {
  CatalogId get catalogId;

  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  });

  Future<Result<Map<CatalogWordRef, WordStatus>>> getBatch(
    Iterable<CatalogWordRef> words, {
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

/// Dispatches shared status operations to the store registered for the
/// [CatalogWordRef.catalogId].
final class CompositeWordStatusRepository
    implements domain.WordStatusRepository {
  CompositeWordStatusRepository(Iterable<DictionaryWordStatusStore> stores)
      : _stores = _buildRegistry(stores);

  final Map<CatalogId, DictionaryWordStatusStore> _stores;

  @override
  Set<CatalogId> get supportedCatalogs => Set.unmodifiable(_stores.keys);

  static Map<CatalogId, DictionaryWordStatusStore> _buildRegistry(
    Iterable<DictionaryWordStatusStore> stores,
  ) {
    final registry = <CatalogId, DictionaryWordStatusStore>{};
    for (final store in stores) {
      if (registry.containsKey(store.catalogId)) {
        throw ArgumentError.value(
          store.catalogId,
          'stores',
          'A DictionaryWordStatusStore is already registered for this CatalogId.',
        );
      }
      registry[store.catalogId] = store;
    }

    return Map.unmodifiable(registry);
  }

  DictionaryWordStatusStore _storeFor(CatalogWordRef word) =>
      _stores[word.catalogId]!;

  @override
  Future<Result<WordStatus?>> get(
    CatalogWordRef word, {
    required String accountId,
  }) =>
      _storeFor(word).get(word, accountId: accountId);

  @override
  Future<Result<Map<CatalogWordRef, WordStatus>>> getBatch(
    Iterable<CatalogWordRef> words, {
    required String accountId,
  }) async {
    final grouped = <CatalogId, List<CatalogWordRef>>{};
    for (final word in words) {
      grouped.putIfAbsent(word.catalogId, () => []).add(word);
    }
    final combined = <CatalogWordRef, WordStatus>{};
    for (final entry in grouped.entries) {
      final store = _stores[entry.key];
      if (store == null) {
        throw StateError('Unsupported WordStatus Catalog: ${entry.key}');
      }
      final result = await store.getBatch(entry.value, accountId: accountId);
      if (result case Failure<Map<CatalogWordRef, WordStatus>>(:final error)) {
        return Result.failure(error);
      }
      combined.addAll(result.dataOrNull!);
    }
    return Result.success(Map.unmodifiable(combined));
  }

  @override
  Stream<WordStatus> watch(
    CatalogWordRef word, {
    required String accountId,
  }) =>
      _storeFor(word).watch(word, accountId: accountId);

  @override
  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  }) =>
      _storeFor(word).update(
        word,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote,
        updatedAt: updatedAt,
        accountId: accountId,
      );
}
