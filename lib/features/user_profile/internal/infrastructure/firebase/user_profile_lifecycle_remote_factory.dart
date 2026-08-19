import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_remote_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/firebase_user_profile_dao.dart';

/// ライフサイクルのプロフィールプロビジョニング用の標準的な Firebase 構築です。
FirebaseUserRemoteDataSource
    createInternalLifecycleFirebaseUserRemoteDataSource({
  required FirebaseAccountDocumentGateway accountDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
}) =>
        FirebaseUserRemoteDataSource(
          FirebaseUserProfileDao(accountDocuments, remoteMutationExecutor),
        );
