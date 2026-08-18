import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_remote_store.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';

/// Builds the Firebase-backed JpnEsp status remote store in canonical Firebase
/// infrastructure, keeping feature composition SDK-free.
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
