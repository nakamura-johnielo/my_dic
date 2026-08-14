import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_mapper.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

class FirebaseMyWordStatusDao {
  final FirebaseAccountNestedUpdatedDocumentGateway _remoteDocuments;
  final RemoteMutationExecutor _remoteMutations;

  FirebaseMyWordStatusDao(this._remoteDocuments, this._remoteMutations);

  /// Get a single MyWordStatus by word ID
  Future<MyWordStatusDTO?> getStatus(String userId, String myWordId) async {
    final document = await _remoteDocuments.read(
      accountId: userId,
      collection: MyWordStatusDTO.collectionName,
      documentId: myWordId,
    );
    if (document == null) return null;
    return FirebaseMyWordStatusMapper.fromDocument(document);
  }

  /// Get MyWordStatus updated after a specific timestamp (one-time query)
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime lastSync) async {
    final documents = await _remoteDocuments.fetchUpdatedSince(
      accountId: userId,
      collection: MyWordStatusDTO.collectionName,
      updatedAtField: MyWordStatusDTO.fieldUpdatedAt,
      since: lastSync,
    );
    return documents.map(FirebaseMyWordStatusMapper.fromDocument).toList();
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched. Bool
  /// payload values are converted to the DTO's 0/1 int convention.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      document: RemoteMutationDocument(
        pathSegments: [
          FirebaseAccountDocumentNamespace.usersCollection,
          request.accountId,
          MyWordStatusDTO.collectionName,
          request.entityId,
        ],
        identityFields: {'myWordId': request.entityId},
        encodedFields: {
          for (final field in request.fieldMask)
            field: request.fields[field] is bool
                ? (request.fields[field]! as bool ? 1 : 0)
                : request.fields[field],
        },
      ),
      request: request,
    );
  }
}
