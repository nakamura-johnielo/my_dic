import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/my_word_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// 正規の Firebase インフラストラクチャ境界内で、Firebase ベースの MyWord リモートアダプターを組み立てる。
MyWordRemoteGateway createFirebaseMyWordRemoteGateway({
  required FirebaseAccountNestedUpdatedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
}) =>
    FirebaseMyWordGateway(
      FirebaseMyWordDao(
        remoteDocuments,
        remoteMutationExecutor,
      ),
    );
