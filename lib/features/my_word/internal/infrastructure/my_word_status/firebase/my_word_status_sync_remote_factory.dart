import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// 正規の Firebase インフラストラクチャ境界内で、Firebase ベースの MyWordStatus リモートアダプターを組み立てる。
MyWordStatusRemoteGateway createFirebaseMyWordStatusRemoteGateway({
  required FirebaseAccountNestedUpdatedDocumentGateway remoteDocuments,
  required RemoteMutationExecutor remoteMutationExecutor,
}) =>
    FirebaseMyWordStatusGateway(
      FirebaseMyWordStatusDao(
        remoteDocuments,
        remoteMutationExecutor,
      ),
    );
