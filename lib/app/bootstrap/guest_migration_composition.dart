import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/app/guest_migration/detect_guest_data_usecase.dart';
import 'package:my_dic/app/guest_migration/guest_data_summary.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/sync/port/model/sync_context.dart';
import 'package:my_dic/features/sync/port/sync_run_outcome.dart';

/// Guest-data detection and migration are inherently cross-feature (they
/// touch esp_jpn/jpn_esp word status and MyWord/MyWordStatus local
/// datasources), so they are composed here rather than inside any one
/// feature, mirroring `sync_composition.dart`.
final detectGuestDataUseCaseProvider = Provider<DetectGuestDataUseCase>((ref) {
  return DetectGuestDataUseCase(
    wordStatus: ref.watch(wordStatusGuestMigrationProvider),
    myWord: ref.watch(myWordLocalDataSourceProvider),
    myWordStatus: ref.watch(myWordStatusLocalDataSourceProvider),
    userProfile: ref.watch(userProfileGuestMigrationPortProvider),
  );
});

final migrateGuestDataUseCaseProvider =
    Provider<MigrateGuestDataUseCase>((ref) {
  return MigrateGuestDataUseCase(
    database: ref.watch(databaseProvider),
    wordStatus: ref.watch(wordStatusGuestMigrationProvider),
    myWord: ref.watch(myWordLocalDataSourceProvider),
    myWordStatus: ref.watch(myWordStatusLocalDataSourceProvider),
    userProfile: ref.watch(userProfileGuestMigrationPortProvider),
    outboxWriter: ref.watch(driftOutboxWriterProvider),
    sessionFence: ref.watch(syncSessionFenceProvider),
  );
});

/// App-workflow seam for the prompt. It is deliberately app-owned: feature
/// ports stay unchanged while widget/cross-layer tests can control deferred
/// detection, migration, sync outcomes, and the session fence.
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
