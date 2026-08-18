import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_mapper.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';

/// Firestore persistence for the Esp-Jpn word-status dataset.
final class FirebaseEspJpnWordStatusDao {
  FirebaseEspJpnWordStatusDao(this._remoteDocuments, this._remoteMutations);

  final FirebaseAccountNestedDocumentGateway _remoteDocuments;
  final RemoteMutationExecutor _remoteMutations;

  Future<EspJpnWordStatusDto?> getWordStatus(
    String accountId,
    int wordId,
  ) async {
    final document = await _remoteDocuments.read(
      accountId: accountId,
      collection: EspJpnWordStatusDto.collectionName,
      documentId: wordId.toString(),
    );
    if (document == null) return null;
    return EspJpnWordStatusMapper.fromDocument(document);
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      document: RemoteMutationDocument(
        pathSegments: [
          FirebaseAccountDocumentNamespace.usersCollection,
          request.accountId,
          EspJpnWordStatusDto.collectionName,
          request.entityId,
        ],
        identityFields: {'wordId': int.parse(request.entityId)},
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

  /// Fetches from an inclusive `(updatedAt, documentId)` cursor. Document ID
  /// is the stable tie-breaker for documents with the same update timestamp.
  Future<List<EspJpnWordStatusDto>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  ) async {
    final documents = await _remoteDocuments.fetchPage(
      accountId: accountId,
      collection: EspJpnWordStatusDto.collectionName,
      updatedAtField: EspJpnWordStatusDto.fieldUpdatedAt,
      cursorSeconds: cursor?.seconds,
      cursorNanoseconds: cursor?.nanoseconds,
      cursorDocumentId: cursor?.documentId,
    );
    return documents.map(EspJpnWordStatusMapper.fromDocument).toList();
  }
}
