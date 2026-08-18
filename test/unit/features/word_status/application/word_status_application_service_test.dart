import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/word_status/internal/application/word_status_application_service.dart';
import 'package:my_dic/features/word_status/internal/application/word_status_clock.dart';
import 'package:my_dic/features/word_status/internal/domain/word_status_repository.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';

void main() {
  const first = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 1,
  );
  const second = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 2,
  );

  test('read and batch turn missing rows into explicit initial statuses',
      () async {
    final repository = _Repository();
    final service = WordStatusApplicationService(repository);

    final read = await service.read(const ReadWordStatusQuery(
      scope: WordStatusScope.guest(),
      word: first,
    ));
    final batch = await service.readBatch(ReadWordStatusBatchQuery(
      scope: const WordStatusScope.guest(),
      words: const [first, second],
    ));

    expect(read.dataOrNull!.updatedAt, isNull);
    expect(batch.dataOrNull!.statusFor(first)!.updatedAt, isNull);
    expect(batch.dataOrNull!.statusFor(second)!.isLearned, isFalse);
    expect(repository.batchReads, 1);
  });

  test('empty batch succeeds without persistence access', () async {
    final repository = _Repository();
    final service = WordStatusApplicationService(repository);
    final result = await service.readBatch(ReadWordStatusBatchQuery(
      scope: const WordStatusScope.guest(),
      words: const [],
    ));
    expect(result.dataOrNull!.isEmpty, isTrue);
    expect(repository.batchReads, 0);
  });

  test('watch converts infrastructure stream errors to read errors',
      () async {
    final repository = _Repository()..watchError = true;
    final result = await WordStatusApplicationService(repository)
        .watch(const ReadWordStatusQuery(
          scope: WordStatusScope.guest(),
          word: first,
        ))
        .single;
    expect(result.errorOrNull, isA<WordStatusReadError>());
    expect(
      (result.errorOrNull! as WordStatusReadError).kind,
      WordStatusReadFailureKind.storage,
    );
  });

  test('no-op update does not evaluate clock or repository', () async {
    final repository = _Repository();
    final clock = _Clock();
    final result = await WordStatusApplicationService(
      repository,
      clock: clock,
    ).update(const UpdateWordStatusCommand(
      scope: WordStatusScope.guest(),
      word: first,
    ));
    expect(result.isSuccess, isTrue);
    expect(repository.updates, 0);
    expect(clock.reads, 0);
  });

  test('changed update gets one UTC application timestamp', () async {
    final repository = _Repository();
    final clock = _Clock();
    await WordStatusApplicationService(repository, clock: clock).update(
      UpdateWordStatusCommand(
        scope: WordStatusScope.account('account-a'),
        word: first,
        hasNote: const FieldUpdate.set(true),
      ),
    );
    expect(repository.updatedAt, DateTime.utc(2026, 8, 13, 12));
    expect(repository.accountId, 'account-a');
    expect(clock.reads, 1);
  });

  test('unsupported Catalog is a typed failure', () async {
    final repository = _Repository()
      ..supportedCatalogs = const {CatalogId.espJpnMain};
    final result = await WordStatusApplicationService(repository).read(
      const ReadWordStatusQuery(
        scope: WordStatusScope.guest(),
        word: CatalogWordRef(
          catalogId: CatalogId.jpnEspMain,
          wordId: 1,
        ),
      ),
    );
    expect(
      (result.errorOrNull! as WordStatusReadError).kind,
      WordStatusReadFailureKind.unsupportedCatalog,
    );
  });
}

final class _Clock implements WordStatusClock {
  int reads = 0;

  @override
  DateTime now() {
    reads++;
    return DateTime(2026, 8, 13, 7);
  }
}

final class _Repository implements WordStatusRepository {
  @override
  Set<CatalogId> supportedCatalogs = CatalogId.values.toSet();
  int batchReads = 0;
  int updates = 0;
  bool watchError = false;
  DateTime? updatedAt;
  String? accountId;

  @override
  Future<Result<WordStatus?>> get(CatalogWordRef word,
          {required String accountId}) async =>
      const Result.success(null);

  @override
  Future<Result<Map<CatalogWordRef, WordStatus>>> getBatch(
      Iterable<CatalogWordRef> words,
      {required String accountId}) async {
    batchReads++;
    return const Result.success({});
  }

  @override
  Stream<WordStatus> watch(CatalogWordRef word,
      {required String accountId}) {
    if (watchError) {
      return Stream.error(DatabaseError(message: 'offline'));
    }
    return Stream.value(WordStatus.initial(word));
  }

  @override
  Future<Result<WordStatus>> update(
    CatalogWordRef word, {
    required FieldUpdate<bool> isLearned,
    required FieldUpdate<bool> isBookmarked,
    required FieldUpdate<bool> hasNote,
    required DateTime updatedAt,
    required String? accountId,
  }) async {
    updates++;
    this.updatedAt = updatedAt;
    this.accountId = accountId;
    return Result.success(WordStatus(
      word: word,
      isLearned: false,
      isBookmarked: false,
      hasNote: true,
      updatedAt: updatedAt,
    ));
  }
}
