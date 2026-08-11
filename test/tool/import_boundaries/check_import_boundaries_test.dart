import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/check_import_boundaries.dart';

void main() {
  group('P0 import-boundary fixture matrix', () {
    late Directory root;

    setUp(() async =>
        root = await Directory.systemTemp.createTemp('boundaries_'));
    tearDown(() => root.delete(recursive: true));

    test(
        'allows consumers to use another feature port, including a callback value',
        () async {
      await write(root, 'lib/app/use.dart', imp('features/a/port/model.dart'));
      await write(root, 'lib/features/b/internal/presentation/view.dart',
          imp('features/a/port/model.dart'));

      expect(await check(root), isEmpty);
    });

    test('rejects core and external consumers of non-port feature files',
        () async {
      await write(
          root, 'lib/core/use.dart', imp('features/a/internal/value.dart'));
      await write(
          root, 'lib/app/use.dart', imp('features/a/internal/value.dart'));

      final violations = await check(root);
      expectRule(violations, 'core_no_feature');
      expectRule(violations, 'feature_external_only_port');
    });

    test('rejects an import-less legacy layer file', () async {
      await write(root, 'lib/features/a/domain/value.dart', 'class Value {}');

      expectRule(await check(root), 'feature_top_level_only_port_internal');
    });

    test('rejects a feature importing app', () async {
      await write(
          root, 'lib/features/a/internal/use.dart', imp('app/router.dart'));

      expectRule(await check(root), 'feature_no_app');
    });

    test('finds cycles between otherwise valid feature ports', () async {
      await write(root, 'lib/features/a/internal/a.dart',
          imp('features/b/port/model.dart'));
      await write(root, 'lib/features/b/internal/b.dart',
          imp('features/a/port/model.dart'));

      expect((await check(root)).where((v) => v.ruleId == 'no_feature_cycle'),
          hasLength(2));
    });

    test(
        'rejects framework dependencies in business ports and local export barrels',
        () async {
      await write(
          root, 'lib/features/a/port/model.dart', "export 'barrel.dart';");
      await write(
          root, 'lib/features/a/port/barrel.dart', sdk('drift/drift.dart'));

      expectRule(await check(root), 'business_port_no_framework');
    });

    test(
        'allows only presentation_entry to expose Flutter and internal presentation',
        () async {
      await write(root, 'lib/features/a/port/presentation_entry.dart',
          "${sdk('flutter/widgets.dart')}\nexport '../internal/presentation/view.dart';");
      await write(root, 'lib/features/a/internal/presentation/view.dart',
          'class View {}');
      await write(root, 'lib/features/a/port/model.dart',
          "export '../internal/presentation/view.dart';");

      final violations = await check(root);
      expectRule(violations, 'presentation_entry_exact_facade');
      expect(
          violations.where((v) => v.source.endsWith('presentation_entry.dart')),
          isEmpty);
    });

    test('allows only composition.dart to reach an internal factory', () async {
      await write(root, 'lib/features/a/port/composition.dart',
          "export '../internal/factory/build.dart';");
      await write(root, 'lib/features/a/internal/factory/build.dart',
          'void build() {}');
      await write(root, 'lib/features/a/port/composition_bad.dart',
          "export '../internal/factory/build.dart';");
      await write(root, 'lib/features/a/port/composition.dart',
          "export '../internal/presentation/view.dart';");

      final violations = await check(root);
      expectRule(violations, 'composition_exact_facade');
    });

    test('rejects every non-facade port-to-internal bridge', () async {
      await write(root, 'lib/features/a/port/model.dart',
          "export '../internal/application/model.dart';");
      await write(root, 'lib/features/a/port/presentation_entry.dart',
          "export '../internal/application/model.dart';");
      await write(root, 'lib/features/a/internal/application/model.dart',
          'class Model {}');

      expectRule(await check(root), 'presentation_entry_exact_facade');
    });

    test('rejects framework dependencies from pure composition', () async {
      await write(root, 'lib/features/a/port/composition.dart',
          sdk('flutter_riverpod/flutter_riverpod.dart'));

      expectRule(await check(root), 'composition_no_framework');
    });

    test('allows a pure composition facade to call a framework-backed factory',
        () async {
      await write(root, 'lib/features/a/port/composition.dart',
          "export '../internal/factory/build.dart';");
      await write(root, 'lib/features/a/internal/factory/build.dart',
          sdk('flutter_riverpod/flutter_riverpod.dart'));

      expect(await check(root), isEmpty);
    });

    test('rejects Provider and Override types from a public composition source',
        () async {
      await write(root, 'lib/features/a/port/composition.dart',
          'Object compose(Provider provider) => provider;');

      expectRule(await check(root), 'composition_no_provider_types');
    });

    test('allows Firebase only in canonical infrastructure', () async {
      await write(
          root,
          'lib/features/a/internal/infrastructure/firebase/adapter.dart',
          sdk('firebase_auth/firebase_auth.dart'));
      await write(root, 'lib/features/a/internal/application/use.dart',
          sdk('firebase_auth/firebase_auth.dart'));

      final violations = await check(root);
      expectRule(violations, 'firebase_canonical_infrastructure_only');
      expect(
          violations
              .where((v) => v.source.contains('/infrastructure/firebase/')),
          isEmpty);
    });

    test('checks every conditional branch and part URI', () async {
      await write(root, 'lib/features/a/port/model.dart',
          "import 'safe.dart' if (dart.library.io) 'package:drift/drift.dart';\npart '../internal/presentation/view.dart';");
      await write(
          root, 'lib/features/a/internal/presentation/view.dart', 'part of x;');

      final violations = await check(root);
      expectRule(violations, 'business_port_no_framework');
      expectRule(violations, 'presentation_entry_exact_facade');
    });

    test('rejects router and another feature route from feature presentation',
        () async {
      await write(root, 'lib/features/a/internal/presentation/view.dart',
          "${sdk('go_router/go_router.dart')}\n${imp('features/b/port/route.dart')}");

      expectRule(
          await check(root), 'feature_presentation_navigation_callback_only');
    });

    test('allows same-feature white-box tests only', () async {
      await write(root, 'test/unit/features/a/internal/view_test.dart',
          imp('features/a/internal/view.dart'));

      expect(
          (await check(root)).map((v) => '${v.ruleId}:${v.source}'), isEmpty);
    });

    test('does not turn test helpers into production boundary violations',
        () async {
      await write(root, 'test/helpers/fake.dart',
          imp('features/a/internal/value.dart'));
      await write(root, 'test/unit/features/b/port/port_test.dart',
          sdk('drift/drift.dart'));

      expect(await check(root), isEmpty);
    });
  });

  test('baseline comparison reports additions and removals', () async {
    final report = await compareWithBaseline(
      [
        const Violation('rule', 'lib/new.dart', 'package:flutter/material.dart')
      ],
      await baselineFile(),
    );
    expect(report.added, hasLength(1));
    expect(report.removed, isEmpty);
  });
}

Future<List<Violation>> check(Directory root) =>
    ImportBoundaryChecker.fromFile('tool/import_boundaries/rules.json')
        .check(root: root.path);
void expectRule(Iterable<Violation> violations, String rule) =>
    expect(violations.any((v) => v.ruleId == rule), isTrue,
        reason: '$rule: $violations');
String imp(String path) => "import 'package:my_dic/$path';";
String sdk(String path) => "import 'package:$path';";
Future<void> write(Directory root, String path, String contents) async {
  final file = File(
      '${root.path}${Platform.pathSeparator}${path.replaceAll('/', Platform.pathSeparator)}');
  await file.parent.create(recursive: true);
  await file.writeAsString(contents);
}

Future<String> baselineFile() async {
  final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}empty-boundary-baseline.json');
  await file.writeAsString('{"violations":[]}');
  return file.path;
}
