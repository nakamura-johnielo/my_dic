import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/app/guest_migration/detect_guest_data_usecase.dart';
import 'package:my_dic/app/guest_migration/migrate_guest_data_usecase.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';
import 'package:my_dic/features/jpn_esp_word_status/di/di.dart';
import 'package:my_dic/features/my_word/di/data_di.dart';
import 'package:my_dic/features/user/di/data_di.dart';

/// Guest-data detection and migration are inherently cross-feature (they
/// touch esp_jpn/jpn_esp word status and MyWord/MyWordStatus local
/// datasources), so they are composed here rather than inside any one
/// feature, mirroring `sync_composition.dart`.
final detectGuestDataUseCaseProvider = Provider<DetectGuestDataUseCase>((ref) {
  return DetectGuestDataUseCase(
    espJpnWordStatus: ref.watch(localWordStatusDataSourceProvider),
    jpnEspWordStatus: ref.watch(jpnEspLocalWordStatusDataSourceProvider),
    myWord: ref.watch(myWordLocalDataSourceProvider),
    myWordStatus: ref.watch(myWordStatusLocalDataSourceProvider),
    userProfile: ref.watch(userProfileLocalDataSourceProvider),
  );
});

final migrateGuestDataUseCaseProvider =
    Provider<MigrateGuestDataUseCase>((ref) {
  return MigrateGuestDataUseCase(
    database: ref.watch(databaseProvider),
    espJpnWordStatus: ref.watch(localWordStatusDataSourceProvider),
    jpnEspWordStatus: ref.watch(jpnEspLocalWordStatusDataSourceProvider),
    myWord: ref.watch(myWordLocalDataSourceProvider),
    myWordStatus: ref.watch(myWordStatusLocalDataSourceProvider),
    userProfile: ref.watch(userProfileLocalDataSourceProvider),
    outboxWriter: ref.watch(driftOutboxWriterProvider),
    sessionFence: ref.watch(syncSessionFenceProvider),
  );
});
