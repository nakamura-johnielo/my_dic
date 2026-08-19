import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/composition/user_profile_composition_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'composition_contract.dart';

export 'composition_contract.dart';

/// 通常の UserProfile 動作に必要な、アプリケーション所有の実行時依存関係です。
final class UserProfileDependencies {
  const UserProfileDependencies({
    required this.database,
    required this.sharedPreferences,
    required this.accountDocuments,
    required this.remoteMutationExecutor,
    required this.outboxWriter,
    required this.clock,
  });

  final DatabaseProvider database;
  final SharedPreferences sharedPreferences;
  final FirebaseAccountDocumentGateway accountDocuments;
  final RemoteMutationExecutor remoteMutationExecutor;
  final OutboxWriter outboxWriter;
  final UserProfileClock clock;
}

/// UserProfile 同期に必要な、アプリケーション所有の実行時依存関係です。
final class UserProfileSyncDependencies {
  const UserProfileSyncDependencies({
    required this.database,
    required this.accountDocuments,
    required this.remoteMutationExecutor,
  });

  final DatabaseProvider database;
  final FirebaseAccountDocumentGateway accountDocuments;
  final RemoteMutationExecutor remoteMutationExecutor;
}

UserProfilePorts createUserProfilePorts({
  required UserProfileDependencies dependencies,
}) =>
    createInternalUserProfileComposition(
      database: dependencies.database,
      sharedPreferences: dependencies.sharedPreferences,
      accountDocuments: dependencies.accountDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      outboxWriter: dependencies.outboxWriter,
      clock: dependencies.clock,
    );

DatasetSyncHandler createUserProfileDatasetSyncHandler({
  required UserProfileSyncDependencies dependencies,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalUserProfileSyncComposition(
      database: dependencies.database,
      accountDocuments: dependencies.accountDocuments,
      remoteMutationExecutor: dependencies.remoteMutationExecutor,
      runtime: runtime,
    );
