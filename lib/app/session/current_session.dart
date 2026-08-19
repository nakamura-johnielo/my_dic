/// 読み取り専用のaccountId解決ポート。
///
/// アプリ全体で「誰がサインインしているか」に一つの答えを持たせ、Firebaseに依存せず
/// テストで代替できるよう、機能はAuth RepositoryやFirebaseへ直接ではなくこれに依存します。
abstract interface class CurrentSession {
  /// サインイン済みのアカウントID。準備完了セッションがない場合（サインアウト、メール未確認、
  /// プロフィール読み込み中）は `null`。
  String? get accountIdOrNull;

  /// サインイン済みのアカウントID。
  ///
  /// 存在しない場合は [SessionRequiresAccountError] をスローします。未認証の呼び出し元が
  /// プログラムエラーとなる場所でのみ使用してください。多くのユースケースは
  /// [accountIdOrNull] を読み、`null` を「ゲストとして扱う」と解釈します。
  String requireAccountId();
}

class SessionRequiresAccountError extends StateError {
  SessionRequiresAccountError()
      : super('CurrentSession has no authenticated account.');
}
