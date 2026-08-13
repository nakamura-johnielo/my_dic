import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/my_word_status_drift_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/my_word_sync_remote_factory.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_sync_remote_factory.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/sync/my_word_dataset_sync_adapter.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/sync/my_word_status_dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/dataset_sync_handler.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/sync_handler_runtime.dart';

IDatasetSyncHandler createInternalMyWordDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseFirestore firestore,
  required IRemoteMutationExecutor remoteMutationExecutor,
  required ISyncHandlerRuntime runtime,
}) =>
    AdapterDatasetSyncHandler(
      adapter: MyWordDatasetSyncAdapter(
        local: MyWordDriftDataSource(
          MyWordDao(database),
        ),
        remote: createInternalFirebaseMyWordRemoteDataSource(
          firestore: firestore,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );

IDatasetSyncHandler createInternalMyWordStatusDatasetSyncHandler({
  required DatabaseProvider database,
  required FirebaseFirestore firestore,
  required IRemoteMutationExecutor remoteMutationExecutor,
  required ISyncHandlerRuntime runtime,
}) =>
    AdapterDatasetSyncHandler(
      adapter: MyWordStatusDatasetSyncAdapter(
        local: MyWordStatusDriftDataSource(
          MyWordStatusDao(
            database,
          ),
        ),
        remote: createInternalFirebaseMyWordStatusRemoteDataSource(
          firestore: firestore,
          remoteMutationExecutor: remoteMutationExecutor,
        ),
      ),
      runtime: runtime,
    );
