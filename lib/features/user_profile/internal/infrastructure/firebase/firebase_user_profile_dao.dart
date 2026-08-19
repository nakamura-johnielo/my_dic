import 'package:my_dic/core/infrastructure/firebase/firebase_account_document_namespace.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';

final class FirebaseUserProfileDao {
  FirebaseUserProfileDao(this._documents, this._remoteMutations);

  final FirebaseAccountDocumentGateway _documents;
  final RemoteMutationExecutor _remoteMutations;

  Future<UserProfileRemoteDto?> getUser(String uid) async {
    final document = await _documents.read(uid);
    if (document == null) return null;
    return _fromDocument(document);
  }

  Future<void> update(UserProfileRemoteDto profile) async {
    await ensure(profile);
  }

  Future<void> create(UserProfileRemoteDto profile) async {
    await ensure(profile);
  }

  /// UID で識別されるアカウントドキュメントを冪等にプロビジョニングします。
  /// 既存の編集可能フィールドおよび認可フィールドは決して上書きしません。
  Future<UserProfileRemoteDto> ensure(UserProfileRemoteDto defaults) async {
    final existing = await _documents.createIfAbsent(
      accountId: defaults.userId,
      fields: {
        'userId': defaults.userId,
        if (defaults.email != null && defaults.email!.isNotEmpty)
          'email': defaults.email,
        if (defaults.userName != null && defaults.userName!.isNotEmpty)
          'userName': defaults.userName,
        'subscriptionStatus': 'free',
        'createdAt': null,
        'updatedAt': null,
        'clientUpdatedAt': null,
        'revision': 0,
        'lastMutationId': null,
        'schemaVersion': 1,
      },
      serverTimestampFields: const {
        'createdAt',
        'updatedAt',
        'clientUpdatedAt',
      },
    );
    if (existing == null) return defaults;
    return UserProfileRemoteDto.fromRemoteData(
      userId: defaults.userId,
      data: Map<String, dynamic>.from(existing.fields),
    );
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) =>
      _remoteMutations.execute(
        document: RemoteMutationDocument(
          pathSegments: [
            FirebaseAccountDocumentNamespace.usersCollection,
            request.accountId,
          ],
          identityFields: {'userId': request.accountId},
          encodedFields: {
            for (final field in request.fieldMask)
              if (field == 'username') 'userName': request.fields[field],
          },
        ),
        request: request,
      );

  UserProfileRemoteDto _fromDocument(FirebaseAccountDocument document) =>
      UserProfileRemoteDto.fromRemoteData(
        userId: document.id,
        data: Map<String, dynamic>.from(document.fields),
      );
}
