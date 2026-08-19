import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/sync_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/my_word_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_status_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/user_profile_composition.dart';
import 'package:my_dic/app/guest_migration/detect_guest_data_usecase.dart';
import 'package:my_dic/app/guest_migration/guest_data_summary.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/core/composition/data_di.dart' show databaseProvider;
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/sync/port/sync.dart';

/// ゲストデータの検出と移行は本質的に機能横断的（esp_jpn/jpn_espの単語ステータスとMyWord集約に
/// 関わる）であるため、`sync_composition.dart` と同様に個別機能の内部ではなくここで構成します。
final detectGuestDataUseCaseProvider = Provider<DetectGuestDataUseCase>((ref) {
  return DetectGuestDataUseCase(
    wordStatus: ref.watch(wordStatusGuestMigrationProvider),
    myWord: ref.watch(myWordPortsProvider).guestMigration,
    userProfile: ref.watch(userProfilePortsProvider).guestMigration,
  );
});

final migrateGuestDataUseCaseProvider =
    Provider<MigrateGuestDataUseCase>((ref) {
  return MigrateGuestDataUseCase(
    database: ref.watch(databaseProvider),
    wordStatus: ref.watch(wordStatusGuestMigrationProvider),
    myWord: ref.watch(myWordPortsProvider).guestMigration,
    userProfile: ref.watch(userProfilePortsProvider).guestMigration,
    sessionFence: ref.watch(syncSessionFenceProvider),
  );
});

/// 確認処理のためのアプリワークフロー境界。機能ポートを変更せずに、ウィジェット/層横断テストで
/// 遅延した検出、移行、同期結果、セッションフェンスを制御できるよう、意図的にアプリが所有します。
final guestMigrationWorkflowDependenciesProvider =
    Provider<GuestMigrationWorkflowDependencies>((ref) {
  final fence = ref.watch(syncSessionFenceProvider);
  return GuestMigrationWorkflowDependencies(
    detect: () => ref.read(detectGuestDataUseCaseProvider).execute(),
    migrate: (accountId, epoch) =>
        ref.read(migrateGuestDataUseCaseProvider).execute(accountId, epoch),
    sync: (context) => ref.read(syncRunnerProvider).foreground(context),
    isCurrent: (scope) => fence.isCurrent(
      accountId: scope.accountScope,
      sessionEpoch: scope.epoch,
    ),
  );
});

class GuestMigrationWorkflowDependencies {
  const GuestMigrationWorkflowDependencies({
    required this.detect,
    required this.migrate,
    required this.sync,
    required this.isCurrent,
  });

  final Future<GuestDataSummary> Function() detect;
  final Future<void> Function(String accountId, int epoch) migrate;
  final Future<SyncRunOutcome> Function(SyncContext context) sync;
  final bool Function(SessionScopeKey scope) isCurrent;
}
