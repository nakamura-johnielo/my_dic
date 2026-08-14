import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/my_word_status_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// Builds the Firebase-backed MyWordStatus remote adapter inside its canonical
/// Firebase infrastructure boundary.
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
