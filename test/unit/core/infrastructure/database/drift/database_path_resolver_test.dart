import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_path_resolver.dart';
import 'package:path/path.dart' as path;

void main() {
  group('resolveDatabaseDirectory', () {
    test('uses the release application-support path exactly', () {
      expect(
        resolveDatabaseDirectory(
          applicationSupportRoot: '/support/root',
          isRelease: true,
          appName: 'my_dic',
        ),
        path.join('/support/root', 'my_dic_DB'),
      );
    });

    test('uses the debug child directory exactly', () {
      expect(
        resolveDatabaseDirectory(
          applicationSupportRoot: '/support/root',
          isRelease: false,
          appName: 'my_dic',
        ),
        path.join('/support/root', 'DEBUG', 'my_dic_DB'),
      );
    });
  });
}
