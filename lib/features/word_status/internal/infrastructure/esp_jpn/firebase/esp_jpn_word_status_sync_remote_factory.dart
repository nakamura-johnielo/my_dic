import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_remote_store.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

/// Builds the Firebase-backed EspJpn status remote store in canonical Firebase
/// infrastructure, keeping feature composition SDK-free.
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
