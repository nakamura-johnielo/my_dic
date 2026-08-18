import 'package:path/path.dart' as path;

/// Resolves the native database directory without depending on Flutter globals.
///
/// Keeping this policy pure makes the release/debug storage contract testable;
/// the production wrapper supplies the application-support directory and build
/// mode.
String resolveDatabaseDirectory({
  required String applicationSupportRoot,
  required bool isRelease,
  required String appName,
}) {
  return isRelease
      ? path.join(applicationSupportRoot, '${appName}_DB')
      : path.join(applicationSupportRoot, 'DEBUG', '${appName}_DB');
}
