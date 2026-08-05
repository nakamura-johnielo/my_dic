import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/domain/entity/sync_checkpoint.dart';
import 'package:my_dic/core/infrastructure/database/shared_preferences/shared_preferences_syncstatus_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('checkpoints are isolated by account and dataset', () async {
    final prefs = await SharedPreferences.getInstance();
    final dao = SharedPreferencesSyncStatusDao(prefs);
    final accountAWordKey = SyncCheckpointKey(
      accountId: 'account-a',
      dataset: SyncDataset.myWords,
    );
    final accountAStatusKey = SyncCheckpointKey(
      accountId: 'account-a',
      dataset: SyncDataset.myWordStatus,
    );
    final accountBWordKey = SyncCheckpointKey(
      accountId: 'account-b',
      dataset: SyncDataset.myWords,
    );
    final wordDate = DateTime.utc(2026, 8, 1);
    final statusDate = DateTime.utc(2026, 8, 2);

    await dao.saveCheckpoint(SyncCheckpoint(
      key: accountAWordKey,
      lastSuccessfulAt: wordDate,
      remoteCursor: 'cursor-a',
    ));
    await dao.saveCheckpoint(SyncCheckpoint(
      key: accountAStatusKey,
      lastSuccessfulAt: statusDate,
    ));

    final accountAWord = await dao.getCheckpoint(accountAWordKey);
    final accountAStatus = await dao.getCheckpoint(accountAStatusKey);

    expect(accountAWord?.lastSuccessfulAt, wordDate);
    expect(accountAWord?.remoteCursor, 'cursor-a');
    expect(accountAStatus?.lastSuccessfulAt, statusDate);
    expect(await dao.getCheckpoint(accountBWordKey), isNull);
  });

  test('legacy global checkpoint is discarded instead of copied', () async {
    final legacyDate = DateTime.utc(2026, 7, 1);
    SharedPreferences.setMockInitialValues({
      'lastSync_wordStatus': legacyDate.millisecondsSinceEpoch,
    });
    final prefs = await SharedPreferences.getInstance();
    final dao = SharedPreferencesSyncStatusDao(prefs);
    final key = SyncCheckpointKey(
      accountId: 'account-a',
      dataset: SyncDataset.myWords,
    );

    expect(await dao.getCheckpoint(key), isNull);
    expect(prefs.containsKey('lastSync_wordStatus'), isFalse);
  });

  test('checkpoint changes only after save completes', () async {
    final prefs = await SharedPreferences.getInstance();
    final dao = SharedPreferencesSyncStatusDao(prefs);
    final key = SyncCheckpointKey(
      accountId: 'account-a',
      dataset: SyncDataset.espJpnWordStatus,
    );
    final previous = DateTime.utc(2026, 8, 1);
    final next = DateTime.utc(2026, 8, 2);
    await dao.saveCheckpoint(
      SyncCheckpoint(key: key, lastSuccessfulAt: previous),
    );

    // A process termination before commit leaves the previous value intact.
    expect((await dao.getCheckpoint(key))?.lastSuccessfulAt, previous);

    await dao.saveCheckpoint(
      SyncCheckpoint(key: key, lastSuccessfulAt: next),
    );
    expect((await dao.getCheckpoint(key))?.lastSuccessfulAt, next);
  });
}
