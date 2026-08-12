import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/word_status/port/composition.dart';
import 'package:my_dic/features/word_status/port/guest_migration.dart';
import 'package:my_dic/features/word_status/port/repository.dart';

final _wordStatusPortsProvider =
    Provider<WordStatusPorts>((ref) => createWordStatusPorts(
          database: ref.watch(databaseProvider),
          outboxWriter: ref.watch(driftOutboxWriterProvider),
        ));

final wordStatusRepositoryProvider = Provider<WordStatusRepository>(
  (ref) => ref.watch(_wordStatusPortsProvider).repository,
);

final wordStatusGuestMigrationProvider = Provider<WordStatusGuestMigration>(
  (ref) => ref.watch(_wordStatusPortsProvider).guestMigration,
);
