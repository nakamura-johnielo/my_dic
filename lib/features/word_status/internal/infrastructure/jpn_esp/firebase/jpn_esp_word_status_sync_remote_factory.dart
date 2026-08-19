import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_remote_store.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

/// 標準的な Firebase インフラで Firebase ベースの JpnEsp ステータスリモートストアを構築し、
/// 機能構成を SDK 非依存に保ちます。
FirebaseJpnEspWordStatusRemoteStore
    createInternalFirebaseJpnEspWordStatusRemoteStore({
      required FirebaseAccountNestedDocumentGateway remoteDocuments,
      required RemoteMutationExecutor remoteMutationExecutor,
    }) =>
        FirebaseJpnEspWordStatusRemoteStore(
          FirebaseJpnEspWordStatusDao(
            remoteDocuments,
            remoteMutationExecutor,
          ),
        );
