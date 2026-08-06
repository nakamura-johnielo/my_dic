import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../../tool/check_import_boundaries.dart';

void main() {
  group('ImportBoundaryChecker', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('import_boundaries_');
    });
    tearDown(() => root.delete(recursive: true));

    test('finds framework imports from domain code', () async {
      await write(root, 'lib/features/catalog/domain/model.dart',
          "import 'package:flutter/material.dart';");

      final violations = await checker().check(root: root.path);

      expect(
          violations,
          contains(const Violation(
              'domain_no_framework',
              'lib/features/catalog/domain/model.dart',
              'package:flutter/material.dart')));
    });

    test('resolves relative Windows imports before applying core rule',
        () async {
      await write(root, 'lib/core/service.dart',
          "import '..\\features\\catalog\\entry.dart';");
      await write(root, 'lib/features/catalog/entry.dart', 'class Entry {}');

      final violations = await checker().check(root: root.path);

      expect(
          violations,
          contains(const Violation('core_no_feature', 'lib/core/service.dart',
              '..\\features\\catalog\\entry.dart')));
    });

    test('ignores generated source and generated targets', () async {
      await write(root, 'lib/features/catalog/domain/model.g.dart',
          "import 'package:flutter/material.dart';");
      await write(root, 'lib/features/catalog/domain/model.dart',
          "import '../model.g.dart';");

      expect(await checker().check(root: root.path), isEmpty);
    });

    test('finds presentation dependency and feature cycle', () async {
      await write(root, 'lib/features/a/presentation/a.dart',
          "import 'package:my_dic/features/b/presentation/b.dart';");
      await write(root, 'lib/features/b/presentation/b.dart',
          "import 'package:my_dic/features/a/presentation/a.dart';");

      final violations = await checker().check(root: root.path);

      expect(
          violations.where((v) => v.ruleId == 'no_cross_feature_presentation'),
          hasLength(2));
      expect(violations.where((v) => v.ruleId == 'no_feature_cycle'),
          hasLength(2));
    });

    test('baseline comparison reports additions and removals', () async {
      final baseline =
          File('${root.path}${Platform.pathSeparator}baseline.json');
      await baseline.writeAsString('''
{"violations":[{"ruleId":"domain_no_framework","source":"lib/old.dart","target":"package:flutter/material.dart","introducedAt":"2026-01-01","owner":"architecture","trackingIssue":"issue"}]}
''');

      final report = await compareWithBaseline(
        [
          const Violation('domain_no_framework', 'lib/new.dart',
              'package:flutter/material.dart')
        ],
        baseline.path,
      );

      expect(report.added, hasLength(1));
      expect(report.removed, hasLength(1));
    });
  });
}

ImportBoundaryChecker checker() =>
    ImportBoundaryChecker.fromFile('tool/import_boundaries/rules.json');

Future<void> write(Directory root, String relativePath, String contents) async {
  final file = File(
      '${root.path}${Platform.pathSeparator}${relativePath.replaceAll('/', Platform.pathSeparator)}');
  await file.parent.create(recursive: true);
  await file.writeAsString(contents);
}
