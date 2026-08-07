import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/jpn_esp_drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/shared/value_objects/field_update.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordstatus_repository.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_repository_input_data.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_repository.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_repository_input_data.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

class _MockOutboxWriter extends Mock implements OutboxWriter {}

typedef _StatusValues = ({bool learned, bool bookmarked, bool hasNote});

abstract interface class _StatusContractFixture {
  Future<_StatusValues> apply({
    FieldUpdate<bool> learned,
    FieldUpdate<bool> bookmarked,
    FieldUpdate<bool> hasNote,
  });

  Future<void> close();
}

class _EspJpnFixture implements _StatusContractFixture {
  _EspJpnFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final WordStatusRepository _repository;

  static Future<_EspJpnFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = DriftWordStatusDataSource(EspJpnWordStatusDao(database));
    return _EspJpnFixture._(
      database,
      WordStatusRepository(local, _MockOutboxWriter()),
    );
  }

  @override
  Future<_StatusValues> apply({
    FieldUpdate<bool> learned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> bookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
  }) async {
    final result = await _repository.updateLocalWordStatus(
      UpdateStatusRepositoryInputData(
        wordId: 1,
        isLearned: learned,
        isBookmarked: bookmarked,
        hasNote: hasNote,
      ),
      DateTime.utc(2026, 8, 5),
      accountId: null,
    );
    expect(result.isSuccess, isTrue);
    final status = result.dataOrNull!;
    return (
      learned: status.isLearned,
      bookmarked: status.isBookmarked,
      hasNote: status.hasNote,
    );
  }

  @override
  Future<void> close() => _database.close();
}

class _JpnEspFixture implements _StatusContractFixture {
  _JpnEspFixture._(this._database, this._repository);

  final DatabaseProvider _database;
  final JpnEspWordStatusRepository _repository;

  static Future<_JpnEspFixture> create() async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final local = JpnEspDriftWordStatusDataSource(
      JpnEspWordStatusDao(database),
    );
    return _JpnEspFixture._(
      database,
      JpnEspWordStatusRepository(local, _MockOutboxWriter()),
    );
  }

  @override
  Future<_StatusValues> apply({
    FieldUpdate<bool> learned = const FieldUpdate.unchanged(),
    FieldUpdate<bool> bookmarked = const FieldUpdate.unchanged(),
    FieldUpdate<bool> hasNote = const FieldUpdate.unchanged(),
  }) async {
    final result = await _repository.updateLocalWordStatus(
      UpdateJpnEspStatusRepositoryInputData(
        wordId: 1,
        isLearned: learned,
        isBookmarked: bookmarked,
        hasNote: hasNote,
      ),
      DateTime.utc(2026, 8, 5),
      accountId: null,
    );
    expect(result.isSuccess, isTrue);
    final status = result.dataOrNull!;
    return (
      learned: status.isLearned,
      bookmarked: status.isBookmarked,
      hasNote: status.hasNote,
    );
  }

  @override
  Future<void> close() => _database.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixtures = <String, Future<_StatusContractFixture> Function()>{
    'Esp-Jpn': _EspJpnFixture.create,
    'Jpn-Esp': _JpnEspFixture.create,
  };

  for (final fixtureEntry in fixtures.entries) {
    group('${fixtureEntry.key} local status patch contract', () {
      late _StatusContractFixture fixture;

      setUp(() async {
        fixture = await fixtureEntry.value();
        await fixture.apply(
          learned: const FieldUpdate.set(true),
          bookmarked: const FieldUpdate.set(true),
          hasNote: const FieldUpdate.set(true),
        );
      });

      tearDown(() => fixture.close());

      test('bookmark-only update preserves learned and hasNote', () async {
        final status = await fixture.apply(
          bookmarked: const FieldUpdate.set(false),
        );

        expect(status, (learned: true, bookmarked: false, hasNote: true));
      });

      test('learned-only update preserves bookmark and hasNote', () async {
        final status = await fixture.apply(
          learned: const FieldUpdate.set(false),
        );

        expect(status, (learned: false, bookmarked: true, hasNote: true));
      });

      test('hasNote-only update preserves learned and bookmark', () async {
        final status = await fixture.apply(
          hasNote: const FieldUpdate.set(false),
        );

        expect(status, (learned: true, bookmarked: true, hasNote: false));
      });

      test('set(false) is distinct from unchanged', () async {
        await fixture.apply(bookmarked: const FieldUpdate.set(false));
        final status = await fixture.apply(
          learned: const FieldUpdate.set(false),
        );

        expect(status, (learned: false, bookmarked: false, hasNote: true));
      });
    });
  }
}
