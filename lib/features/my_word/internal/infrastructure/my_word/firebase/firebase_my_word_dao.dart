import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/core/port/firebase_account_nested_document_gateway.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_mapper.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

class FirebaseMyWordDao {
  final FirebaseAccountNestedUpdatedDocumentGateway _remoteDocuments;
  final RemoteMutationExecutor _remoteMutations;

  FirebaseMyWordDao(this._remoteDocuments, this._remoteMutations);

  /// ID で 1 つの MyWord を取得する。
  Future<MyWordDTO?> getMyWord(String userId, String myWordId) async {
    final document = await _remoteDocuments.read(
      accountId: userId,
      collection: MyWordDTO.collectionName,
      documentId: myWordId,
    );
    if (document == null) return null;
    return FirebaseMyWordMapper.fromDocument(document);
  }

  /// 指定したタイムスタンプ以降に更新された MyWord を取得する（単発クエリ）。
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime lastSync) async {
    final documents = await _remoteDocuments.fetchUpdatedSince(
      accountId: userId,
      collection: MyWordDTO.collectionName,
      updatedAtField: MyWordDTO.fieldUpdatedAt,
      since: lastSync,
    );
    return documents.map(FirebaseMyWordMapper.fromDocument).toList();
  }

  /// [fieldMask] のキーと管理用タイムスタンプのみをマージ書き込みし、同期アウトボックス変更で
  /// 対象としないフィールドを変更しない。`deletedAt` 値は ISO-8601 文字列で届き、Firestore の
  /// `Timestamp` トゥームストーンマーカーへ変換する。
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      document: RemoteMutationDocument(
        pathSegments: [
          FirebaseAccountDocumentNamespace.usersCollection,
          request.accountId,
          MyWordDTO.collectionName,
          request.entityId,
        ],
        identityFields: {'wordId': request.entityId},
        encodedFields: {
          for (final field in request.fieldMask)
            field: field == MyWordDTO.fieldDeletedAt &&
                    request.fields[field] is String
                ? DateTime.parse(request.fields[field]! as String).toUtc()
                : request.fields[field],
        },
      ),
      request: request,
    );
  }
}
