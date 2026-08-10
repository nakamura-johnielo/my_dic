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

    test('scans test sources but excludes only the boundary-checker fixtures',
        () async {
      await write(root, 'test/unit/features/catalog/domain/model_test.dart',
          "import 'package:flutter/material.dart';");
      await write(root, 'test/tool/import_boundaries/fixtures/violation.dart',
          "import 'package:flutter/material.dart';");

      final violations = await checker().check(root: root.path);

      expect(
          violations,
          contains(const Violation(
              'domain_no_framework',
              'test/unit/features/catalog/domain/model_test.dart',
              'package:flutter/material.dart')));
      expect(
          violations,
          isNot(contains(const Violation(
              'domain_no_framework',
              'test/tool/import_boundaries/fixtures/violation.dart',
              'package:flutter/material.dart'))));
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

    test('finds a three-feature cycle', () async {
      await write(root, 'lib/features/a/domain/a.dart',
          "import 'package:my_dic/features/b/domain/b.dart';");
      await write(root, 'lib/features/b/domain/b.dart',
          "import 'package:my_dic/features/c/domain/c.dart';");
      await write(root, 'lib/features/c/domain/c.dart',
          "import 'package:my_dic/features/a/domain/a.dart';");

      final cycles = (await checker().check(root: root.path))
          .where((violation) => violation.ruleId == 'no_feature_cycle');

      expect(cycles, hasLength(3));
    });

    test('allows Firebase imports only at explicit infrastructure boundaries',
        () async {
      await write(
          root,
          'lib/features/auth/internal/infrastructure/firebase/auth.dart',
          sdkImport('firebase_auth/firebase_auth.dart'));
      await write(root, 'lib/app/bootstrap/firebase_providers.dart',
          sdkImport('firebase_core/firebase_core.dart'));
      await write(
          root,
          'lib/features/catalog/internal/infrastructure/sync/firebase/adapter.dart',
          sdkImport('cloud_firestore/cloud_firestore.dart'));
      await write(root, 'integration_test/firebase_emulator_test.dart',
          sdkImport('cloud_firestore/cloud_firestore.dart'));

      expect(await checker().check(root: root.path), isEmpty);
    });

    test('finds Firebase imports in repository_impl, closing the old glob gap',
        () async {
      const source = 'lib/features/catalog/data/repository_impl/catalog.dart';
      await write(
          root, source, sdkImport('cloud_firestore/cloud_firestore.dart'));

      expect(
          await checker().check(root: root.path),
          contains(const Violation('firebase_import_allowlist', source,
              'package:cloud_firestore/cloud_firestore.dart')));
    });

    test('applies the Firebase allowlist to every Firebase SDK package',
        () async {
      const source = 'lib/features/catalog/application/catalog.dart';
      await write(
          root,
          source,
          [
            sdkImport('firebase_core/firebase_core.dart'),
            sdkImport('firebase_auth/firebase_auth.dart'),
            sdkImport('cloud_firestore/cloud_firestore.dart'),
          ].join('\n'));

      final violations = await checker().check(root: root.path);

      expect(violations.where((v) => v.ruleId == 'firebase_import_allowlist'),
          hasLength(3));
    });

    test('forbids imports of removed legacy sync APIs', () async {
      const source = 'lib/features/catalog/application/catalog.dart';
      const target = 'package:my_dic/features/sync/sync_service.dart';
      await write(root, source, "import '$target';");

      expect(
          await checker().check(root: root.path),
          contains(const Violation(
              'legacy_sync_imports_forbidden', source, target)));
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

    test('does not allow zero-violation rules into the baseline', () async {
      final baseline =
          Baseline({}, zeroViolationRuleIds: {'firebase_import_allowlist'});

      await expectLater(
          Baseline.write(
              '${root.path}${Platform.pathSeparator}baseline.json',
              [
                const Violation(
                    'firebase_import_allowlist',
                    'lib/features/catalog/data/repository_impl/catalog.dart',
                    'package:cloud_firestore/cloud_firestore.dart')
              ],
              previous: baseline),
          throwsStateError);
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

String sdkImport(String packagePath) => 'im' 'port \'package:$packagePath\';';
