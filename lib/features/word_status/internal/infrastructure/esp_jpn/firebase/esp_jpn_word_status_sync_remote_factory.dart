import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_remote_store.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

/// 標準的な Firebase インフラで Firebase ベースの EspJpn ステータスリモートストアを構築し、
/// 機能構成を SDK 非依存に保ちます。
FirebaseEspJpnWordStatusRemoteStore
    createInternalFirebaseEspJpnWordStatusRemoteStore({
      required FirebaseAccountNestedDocumentGateway remoteDocuments,
      required RemoteMutationExecutor remoteMutationExecutor,
    }) =>
        FirebaseEspJpnWordStatusRemoteStore(
          FirebaseEspJpnWordStatusDao(
            remoteDocuments,
            remoteMutationExecutor,
          ),
        );
