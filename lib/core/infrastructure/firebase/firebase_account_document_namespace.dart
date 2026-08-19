/// 最上位のFirebaseアカウントドキュメントパスに関する共有技術的責務。
///
/// 機能が所有するネストされたコレクションやペイロードフィールドはここには含めません。
abstract final class FirebaseAccountDocumentNamespace {
  static const usersCollection = 'Users';
}

/// 共有アカウント名前空間にある1件のドキュメントのSDK非依存スナップショット。
final class FirebaseAccountDocument {
  const FirebaseAccountDocument({required this.id, required this.fields});

  final String id;
  final Map<String, Object?> fields;
}

/// 共有アカウントドキュメント名前空間のSDK非依存な技術的リーダー。
abstract interface class FirebaseAccountDocumentGateway {
  Future<FirebaseAccountDocument?> read(String accountId);

  /// アカウントドキュメントが存在しない場合にアトミックに作成します。
  ///
  /// すでにドキュメントがある場合はそれを返し、ない場合は作成後に `null` を返します。
  /// フィールドの意味は呼び出し元の機能が所有し、このゲートウェイは外部システム操作のみを
  /// 担当します。
  Future<FirebaseAccountDocument?> createIfAbsent({
    required String accountId,
    required Map<String, Object?> fields,
    required Set<String> serverTimestampFields,
  });
}
