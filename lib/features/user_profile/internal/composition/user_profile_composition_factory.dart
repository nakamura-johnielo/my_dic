import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/composition/user_profile_ports_factory.dart';
import 'package:my_dic/features/user_profile/internal/composition/user_profile_sync_factory.dart';
import 'package:my_dic/features/user_profile/port/composition_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserProfilePorts createInternalUserProfileComposition({
  required DatabaseProvider database,
  required SharedPreferences sharedPreferences,
  required FirebaseAccountDocumentGateway accountDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required OutboxWriter outboxWriter,
  required UserProfileClock clock,
}) =>
    createInternalUserProfilePorts(
      database: database,
      sharedPreferences: sharedPreferences,
      accountDocuments: accountDocuments,
      remoteMutationExecutor: remoteMutationExecutor,
      outboxWriter: outboxWriter,
      clock: clock,
    );

DatasetSyncHandler createInternalUserProfileSyncComposition({
  required DatabaseProvider database,
  required FirebaseAccountDocumentGateway accountDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
  required SyncHandlerRuntime runtime,
}) =>
    createInternalUserProfileDatasetSyncHandler(
      database: database,
      accountDocuments: accountDocuments,
      remoteMutationExecutor: remoteMutationExecutor,
      runtime: runtime,
    );
