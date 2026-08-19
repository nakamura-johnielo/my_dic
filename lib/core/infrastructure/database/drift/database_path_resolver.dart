import 'package:path/path.dart' as path;

/// Flutterのグローバル値に依存せず、ネイティブデータベースのディレクトリを解決します。
///
/// このポリシーを純粋に保つことで、リリース/デバッグのストレージ契約をテスト可能にします。
/// 本番用ラッパーがアプリケーションサポートディレクトリとビルドモードを提供します。
String resolveDatabaseDirectory({
  required String applicationSupportRoot,
  required bool isRelease,
  required String appName,
}) {
  return isRelease
      ? path.join(applicationSupportRoot, '${appName}_DB')
      : path.join(applicationSupportRoot, 'DEBUG', '${appName}_DB');
}
