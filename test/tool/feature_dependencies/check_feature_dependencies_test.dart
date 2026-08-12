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
          directive('features/catalog/port/catalog.dart'));
      await write(root, 'lib/features/catalog/port/catalog.dart',
          'class ReaderPort {}');

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

    test('enforces Catalog facade and ownership rules', () async {
      await write(root, 'lib/features/search/internal/use.dart',
          "${directive('features/catalog/internal/domain/entity.dart')}\n${directive('features/catalog/port/catalog_word_ref.dart')}");
      await write(root, 'lib/integration/catalog_search/use.dart',
          directive('features/catalog/port/composition.dart'));
      await write(root, 'lib/features/catalog/internal/application/use.dart',
          directive('features/quiz/port/quiz.dart'));
      await write(root, 'lib/features/catalog/port/catalog.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");

      final violations = await check(root);
      expectRule(violations, 'catalog_external_no_internal');
      expectRule(violations, 'catalog_external_only_facade');
      expectRule(violations, 'integration_catalog_only_facade');
      expectRule(violations, 'catalog_internal_no_search_quiz');
      expectRule(violations, 'catalog_port_framework_only_bridges');
    });

    test('allows the Catalog facade and scoped bridge exceptions', () async {
      await write(root, 'lib/features/search/internal/use.dart',
          directive('features/catalog/port/catalog.dart'));
      await write(root, 'lib/app/bootstrap/catalog.dart',
          directive('features/catalog/port/composition.dart'));
      await write(root, 'lib/features/quiz/internal/presentation/use.dart',
          directive('features/catalog/port/presentation_dependencies.dart'));
      await write(root, 'lib/features/catalog/port/composition.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");
      await write(
          root,
          'lib/features/catalog/port/presentation_dependencies.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");

      final catalogRules = (await check(root)).where((violation) =>
          violation.ruleId.startsWith('catalog_') ||
          violation.ruleId.startsWith('integration_catalog_'));
      expect(catalogRules, isEmpty);
    });

    test('enforces the MyWord facade and scoped technical seams', () async {
      await write(root, 'lib/features/search/internal/good.dart',
          directive('features/my_word/port/my_word.dart'));
      await write(root, 'lib/features/search/internal/bad.dart',
          "${directive('features/my_word/internal/domain/entity.dart')}\n${directive('features/my_word/port/query.dart')}");
      await write(root, 'lib/app/bootstrap/my_word.dart',
          directive('features/my_word/port/composition.dart'));
      await write(root, 'lib/app/routing/my_word.dart',
          directive('features/my_word/port/presentation_entry.dart'));

      final violations = await check(root);
      expectRule(violations, 'my_word_external_no_internal');
      expectRule(violations, 'my_word_external_only_facade');
      expect(
          violations.where((v) =>
              v.source.endsWith('/good.dart') &&
              v.ruleId.startsWith('my_word_')),
          isEmpty);
    });

    test('does not widen Catalog bridge exceptions to arbitrary callers',
        () async {
      await write(root, 'lib/app/use.dart',
          directive('features/catalog/port/composition.dart'));
      await write(root, 'lib/features/quiz/internal/application/use.dart',
          directive('features/catalog/port/presentation_dependencies.dart'));

      final violations = await check(root);
      expect(
          violations.where((v) => v.ruleId == 'catalog_external_only_facade'),
          hasLength(2));
    });

    test('checks every conditional import branch for Catalog rules', () async {
      await write(
          root,
          'lib/features/search/internal/use.dart',
          "import 'package:my_dic/features/catalog/port/catalog.dart' "
              "if (dart.library.io) "
              "'package:my_dic/features/catalog/internal/domain/value.dart';");
      await write(
          root,
          'lib/features/catalog/port/catalog.dart',
          "import 'safe.dart' if (dart.library.io) "
              "'package:flutter_riverpod/flutter_riverpod.dart';");

      final violations = await check(root);
      expectRule(violations, 'catalog_external_no_internal');
      expectRule(violations, 'catalog_port_framework_only_bridges');
    });

    test('allows only Riverpod in Catalog port bridge files', () async {
      await write(root, 'lib/features/catalog/port/catalog.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");
      await write(
          root,
          'lib/features/catalog/port/composition.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
              "import 'package:drift/drift.dart';");
      await write(
          root,
          'lib/features/catalog/port/presentation_dependencies.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
              "import 'package:riverpod/riverpod.dart';\n"
              "import 'package:flutter/widgets.dart';\n"
              "import 'package:firebase_auth/firebase_auth.dart';");

      final violations = (await check(root))
          .where((v) => v.ruleId == 'catalog_port_framework_only_bridges')
          .toList();
      expect(violations, hasLength(5));
      expect(
          violations.map((v) => v.target),
          containsAll(<String>[
            'package:flutter_riverpod/flutter_riverpod.dart',
            'package:drift/drift.dart',
            'package:riverpod/riverpod.dart',
            'package:flutter/widgets.dart',
            'package:firebase_auth/firebase_auth.dart',
          ]));
    });

    test('enforces Quiz facade and integration ownership', () async {
      await write(root, 'lib/features/search/internal/good.dart',
          directive('features/quiz/port/quiz.dart'));
      await write(root, 'lib/features/search/internal/bad.dart',
          "${directive('features/quiz/internal/application/service.dart')}\n${directive('features/quiz/port/query/quiz_game_query.dart')}");
      await write(root, 'lib/app/bootstrap/quiz.dart',
          directive('features/quiz/internal/infrastructure/assets.dart'));
      await write(root, 'lib/integration/catalog_quiz/bad.dart',
          "${directive('features/quiz/internal/infrastructure/drift/dao.dart')}\nimport 'package:flutter/widgets.dart';");

      final violations = await check(root);
      expectRule(violations, 'quiz_external_no_internal');
      expectRule(violations, 'quiz_external_only_facade');
      expectRule(violations, 'integration_quiz_only_facade');
      expectRule(violations, 'integration_quiz_no_framework_or_drift');
      expect(
          violations.where((v) =>
              v.source.endsWith('/good.dart') && v.ruleId.startsWith('quiz_')),
          isEmpty);
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
void expectRule(Iterable<FeatureDependencyViolation> violations, String rule) =>
    expect(violations.any((violation) => violation.ruleId == rule), isTrue,
        reason: '$rule: $violations');
