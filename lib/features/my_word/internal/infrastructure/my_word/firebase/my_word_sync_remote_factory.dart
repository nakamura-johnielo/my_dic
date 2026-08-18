import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/my_word_remote_gateway.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// Builds the Firebase-backed MyWord remote adapter inside its canonical
/// Firebase infrastructure boundary.
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
