import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../../tool/check_feature_dependencies.dart';

void main() {
  group('FeatureDependencyChecker', () {
    late Directory root;

    setUp(() async =>
        root = await Directory.systemTemp.createTemp('feature_dependencies_'));
    tearDown(() => root.delete(recursive: true));

    test('allows consumers to import another feature port', () async {
      await write(root, 'lib/app/bootstrap.dart',
          directive('features/catalog/port/reader.dart'));
      await write(
          root, 'lib/features/catalog/port/reader.dart', 'class ReaderPort {}');

      expect(await check(root), isEmpty);
    });

    test('rejects consumers importing another feature internal', () async {
      const target = 'features/catalog/internal/domain/entity.dart';
      await write(root, 'lib/features/search/internal/application/search.dart',
          directive(target));
      await write(root, 'lib/features/catalog/internal/domain/entity.dart',
          'class Entity {}');

      expect(
          await check(root),
          contains(const FeatureDependencyViolation(
              'feature_import_only_port',
              'lib/features/search/internal/application/search.dart',
              'package:my_dic/features/catalog/internal/domain/entity.dart')));
    });

    test('allows a feature to use its own internal layers', () async {
      await write(
          root,
          'lib/features/catalog/internal/application/use_case.dart',
          directive('features/catalog/internal/domain/entity.dart'));
      await write(root, 'lib/features/catalog/internal/domain/entity.dart',
          'class Entity {}');

      expect(await check(root), isEmpty);
    });

    test('rejects inward clean architecture violations', () async {
      const source = 'lib/features/catalog/internal/domain/entity.dart';
      const target = 'features/catalog/internal/infrastructure/store.dart';
      await write(root, source, directive(target));
      await write(
          root,
          'lib/features/catalog/internal/infrastructure/store.dart',
          'class Store {}');

      expect(
          await check(root),
          contains(const FeatureDependencyViolation(
              'internal_clean_architecture',
              source,
              'package:my_dic/features/catalog/internal/infrastructure/store.dart')));
    });
  });
}

Future<List<FeatureDependencyViolation>> check(Directory root) =>
    FeatureDependencyChecker().check(root: root.path);

Future<void> write(Directory root, String relativePath, String contents) async {
  final file = File(
      '${root.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}');
  await file.parent.create(recursive: true);
  await file.writeAsString(contents);
}

String directive(String target) => "import 'package:my_dic/$target';";
