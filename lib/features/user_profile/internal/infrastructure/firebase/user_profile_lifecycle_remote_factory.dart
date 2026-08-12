import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_dao.dart';

/// Canonical Firebase construction for lifecycle profile provisioning.
FirebaseUserRemoteDataSource
    createInternalLifecycleFirebaseUserRemoteDataSource(
  IRemoteMutationExecutor remoteMutations,
) =>
        FirebaseUserRemoteDataSource(
          UserDao(FirebaseFirestore.instance, remoteMutations),
        );
