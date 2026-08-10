/// Transitional app-workflow contracts.  The app imports them through this
/// feature port while the transaction remains app-owned across datasets.
export 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_local_data_source.dart';
export 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_status_local_data_source.dart';

/// Feature-owned contribution to the app's guest-data migration workflow.
abstract interface class MyWordGuestMigrationPort {
  Future<int> countGuestMyWords();

  Future<int> countGuestMyWordStatuses();
}
