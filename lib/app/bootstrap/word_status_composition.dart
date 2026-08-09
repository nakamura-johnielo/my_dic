import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_composition.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart'
    show localWordStatusDataSourceProvider;
import 'package:my_dic/features/jpn_esp_word_status/di/di.dart'
    show jpnEspLocalWordStatusDataSourceProvider;
import 'package:my_dic/features/word_status/application/port/word_status_repository.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_adapter.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/word_status_repository_adapter.dart';

/// App-level composition for the unified, catalog-keyed word-status port.
///
/// The direction-specific providers remain the owners of their local
/// datasource and sync graphs. This composition merely reuses those stable
/// boundaries to register both datasets with the shared repository.
final wordStatusRepositoryProvider = Provider<WordStatusRepository>((ref) {
  final outboxWriter = ref.watch(driftOutboxWriterProvider);
  return WordStatusRepositoryAdapter([
    EspJpnDictionaryWordStatusAdapter(
      ref.watch(localWordStatusDataSourceProvider),
      outboxWriter,
    ),
    JpnEspDictionaryWordStatusAdapter(
      ref.watch(jpnEspLocalWordStatusDataSourceProvider),
      outboxWriter,
    ),
  ]);
});
