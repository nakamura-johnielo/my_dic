import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/internal/adapter/my_word_application_adapter.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/delete_my_word/delete_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/register_my_word/register_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/update/update_my_word_interactor.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/query/drift_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository_impl/my_word_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/repository_impl/my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/guest_migration/my_word_guest_migration_adapter.dart';
import 'package:my_dic/features/my_word/port/composition.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';

/// Owner-only assembly for MyWord persistence and application adapters.
MyWordPorts createInternalMyWordPorts(MyWordDependencyReader read) {
  final database = read<DatabaseProvider>(MyWordDependency.database);
  final outboxWriter = read<IOutboxWriter>(MyWordDependency.outboxWriter);
  final wordLocal = MyWordDriftDataSource(MyWordDao(database));
  final statusLocal = MyWordStatusDriftDataSource(MyWordStatusDao(database));
  final wordRepository = MyWordRepository(wordLocal, outboxWriter);
  final statusRepository = MyWordStatusRepository(statusLocal, outboxWriter);
  final application = MyWordApplicationAdapter(
    registerUseCase: RegisterMyWordInteractor(wordRepository),
    updateUseCase: UpdateMyWordInteractor(wordRepository),
    deleteUseCase: DeleteMyWordInteractor(wordRepository),
    updateStatusUseCase: UpdateMyWordStatusInteractor(statusRepository),
    loadUseCase: LoadMyWordInteractor(wordRepository),
    itemQueryRepository: DriftMyWordItemQueryRepository(MyWordDao(database)),
  );
  return MyWordPorts(
    reader: application,
    commands: application,
    statusCommands: application,
    guestMigration: MyWordGuestMigrationAdapter(
      wordLocal,
      statusLocal,
      outboxWriter,
    ),
  );
}
