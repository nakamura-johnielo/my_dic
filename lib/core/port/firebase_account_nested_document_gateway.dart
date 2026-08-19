/// 共有アカウントドキュメント名前空間配下の、SDKに依存しないドキュメント値。
final class FirebaseAccountNestedDocument {
  const FirebaseAccountNestedDocument({
    required this.id,
    required this.fields,
  });

  final String id;
  final Map<String, Object?> fields;
}

/// アカウント所有のネストされたドキュメントコレクションの技術的契約。
///
/// この契約には意図的にFirebase SDKの型を含めません。具体的なFirebaseの仕組みは
/// インフラストラクチャ実装に留めます。
abstract interface class FirebaseAccountNestedDocumentGateway {
  Future<FirebaseAccountNestedDocument?> read({
    required String accountId,
    required String collection,
    required String documentId,
  });

  Future<List<FirebaseAccountNestedDocument>> fetchPage({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required int? cursorSeconds,
    required int? cursorNanoseconds,
    required String? cursorDocumentId,
  });
}

/// 旧来の包含条件 `updatedAt >= since` によるデータセット取得の技術的契約。
abstract interface class FirebaseAccountNestedUpdatedDocumentGateway {
  Future<FirebaseAccountNestedDocument?> read({
    required String accountId,
    required String collection,
    required String documentId,
  });

  Future<List<FirebaseAccountNestedDocument>> fetchUpdatedSince({
    required String accountId,
    required String collection,
    required String updatedAtField,
    required DateTime since,
  });
}
