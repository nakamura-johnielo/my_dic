import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/composition_contract.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_dao.dart';
import 'package:my_dic/features/user_profile/port/composition.dart';

/// Builds the Firebase-backed profile remote adapter in canonical Firebase
/// infrastructure, keeping the dataset factory SDK-free.
FirebaseUserRemoteDataSource createInternalFirebaseUserProfileRemoteDataSource(
  SyncDependencyReader read,
) => FirebaseUserRemoteDataSource(
  UserDao(
    read<FirebaseFirestore>(UserProfileSyncDependency.firestore),
    read<RemoteMutationExecutor>(
      UserProfileSyncDependency.remoteMutationExecutor,
    ),
  ),
);
