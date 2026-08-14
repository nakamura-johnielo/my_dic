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
      await write(
          root, 'lib/features/catalog/port/catalog.dart', 'class QueryPort {}');

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
      await write(root, 'lib/features/catalog/port/composition.dart',
          "import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';");

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
          directive('features/catalog/port/catalog_word_ref.dart'));

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

    test('rejects framework imports from Catalog business and composition ports',
        () async {
      await write(root, 'lib/features/catalog/port/catalog.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");
      await write(
          root,
          'lib/features/catalog/port/composition.dart',
          "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
              "import 'package:drift/drift.dart';");
      final violations = (await check(root))
          .where((v) => v.ruleId == 'catalog_port_framework_only_bridges')
          .toList();
      expect(violations, hasLength(3));
      expect(
          violations.map((v) => v.target),
          containsAll(<String>[
            'package:flutter_riverpod/flutter_riverpod.dart',
            'package:drift/drift.dart',
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
              v.source == 'lib/app/bootstrap/quiz.dart' &&
              v.target ==
                  'package:my_dic/features/quiz/internal/infrastructure/assets.dart' &&
              v.ruleId == 'quiz_external_no_internal'),
          hasLength(1));
      expect(
          violations.where((v) =>
              v.source.endsWith('/good.dart') && v.ruleId.startsWith('quiz_')),
          isEmpty);
    });

    test('allows the generic Search facade and controlled technical seams',
        () async {
      await writeStrictSurface(root, 'search');
      await write(root, 'lib/app/use.dart',
          directive('features/search/port/search.dart'));
      await write(root, 'lib/app/bootstrap/search.dart',
          "${directive('features/search/port/composition.dart')}\n${directive('features/search/port/presentation_dependencies.dart')}");
      await write(root, 'lib/app/routing/search.dart',
          directive('features/search/port/presentation_entry.dart'));
      await write(root,
          'lib/integration/catalog_search/catalog_search_providers.dart',
          directive('features/search/port/composition.dart'));

      final generic = (await check(root)).where((violation) => {
            'feature_external_no_internal',
            'feature_external_only_facade',
            'feature_technical_seam_only',
            'integration_feature_only_facade',
            'integration_feature_no_framework',
            'composition_exact_facade',
            'presentation_entry_exact_facade',
            'composition_no_framework',
            'composition_no_provider_types',
          }.contains(violation.ruleId));
      expect(generic, isEmpty);
    });

    test('enforces Auth facade and controlled technical seam callers',
        () async {
      await writeStrictSurface(root, 'auth');
      await write(root, 'lib/app/use.dart',
          directive('features/auth/port/auth.dart'));
      await write(root, 'lib/app/bootstrap/auth.dart',
          directive('features/auth/port/composition.dart'));
      await write(root, 'lib/app/routing/auth.dart',
          directive('features/auth/port/presentation_entry.dart'));
      await write(root, 'lib/integration/session_lifecycle_workflow/auth.dart',
          directive('features/auth/port/presentation_entry.dart'));
      await write(root, 'lib/features/search/internal/bad.dart',
          directive('features/auth/port/query.dart'));

      final violations = await check(root);
      expectRule(violations, 'feature_technical_seam_only');
      expectRule(violations, 'feature_external_only_facade');
      expect(
        violations.where((v) =>
            v.source == 'lib/app/use.dart' ||
            v.source == 'lib/app/bootstrap/auth.dart' ||
            v.source == 'lib/app/routing/auth.dart'),
        isEmpty,
      );
    });

    test('allows the UserProfile facade and controlled technical seams',
        () async {
      await writeStrictSurface(root, 'user_profile');
      await write(root, 'lib/app/use.dart',
          directive('features/user_profile/port/user_profile.dart'));
      await write(root, 'lib/app/bootstrap/user_profile.dart',
          directive('features/user_profile/port/composition.dart'));
      await write(root, 'lib/app/routing/user_profile.dart',
          directive('features/user_profile/port/presentation_entry.dart'));

      final violations = (await check(root)).where((violation) => {
            'feature_external_no_internal',
            'feature_external_only_facade',
            'feature_technical_seam_only',
            'composition_exact_facade',
            'presentation_entry_exact_facade',
            'composition_no_framework',
            'composition_no_provider_types',
          }.contains(violation.ruleId));
      expect(violations, isEmpty);
    });

    test('rejects UserProfile internal, wire DTO, seam and resolver leaks',
        () async {
      await writeStrictSurface(root, 'user_profile');
      await write(root, 'lib/app/bad_user_profile_internal.dart',
          directive('features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart'));
      await write(root, 'lib/app/bad_user_profile_wire.dart',
          directive('features/user_profile/port/user_profile_remote_dto.dart'));
      await write(root, 'lib/app/bad_user_profile_entry.dart',
          directive('features/user_profile/port/presentation_entry.dart'));
      await write(root, 'lib/features/user_profile/port/composition.dart',
          "${directive('features/user_profile/internal/composition/user_profile_composition_factory.dart')}\n${directive('features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart')}\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\ntypedef Reader = T Function<T>(Object value);");
      await write(root, 'lib/features/user_profile/port/presentation_entry.dart',
          "export 'package:my_dic/features/user_profile/internal/presentation/provider/provider.dart';");

      final violations = await check(root);
      for (final rule in [
        'feature_external_no_internal',
        'feature_external_only_facade',
        'feature_technical_seam_only',
        'composition_exact_facade',
        'presentation_entry_exact_facade',
        'composition_no_framework',
        'composition_no_provider_types',
      ]) {
        expectRule(violations, rule);
      }
    });

    test('rejects generic Search boundary and composition leaks', () async {
      await writeStrictSurface(root, 'search');
      await write(root, 'lib/app/bad_internal.dart',
          directive('features/search/internal/application/service.dart'));
      await write(root, 'lib/app/bad_deep.dart',
          directive('features/search/port/query/search_query.dart'));
      await write(root, 'lib/app/bad_entry.dart',
          directive('features/search/port/presentation_entry.dart'));
      await write(root, 'lib/integration/catalog_search/adapter.dart',
          "${directive('features/search/port/query/search_query.dart')}\nimport 'package:flutter/widgets.dart';");
      await write(root, 'lib/features/search/port/composition.dart',
          "${directive('features/search/internal/composition/search_composition_factory.dart')}\n${directive('features/search/internal/factory/other_factory.dart')}\n${directive('features/search/internal/application/service.dart')}\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\ntypedef Reader = T Function<T>(Object value);");
      await write(root, 'lib/features/search/port/presentation_entry.dart',
          "export 'package:my_dic/features/search/internal/presentation/provider/provider.dart';");

      final violations = await check(root);
      for (final rule in [
        'feature_external_no_internal',
        'feature_external_only_facade',
        'feature_technical_seam_only',
        'integration_feature_only_facade',
        'integration_feature_no_framework',
        'composition_exact_facade',
        'presentation_entry_exact_facade',
        'composition_no_framework',
        'composition_no_provider_types',
      ]) {
        expectRule(violations, rule);
      }
    });

    test('enforces the generic WordDetail strict surface', () async {
      await writeStrictSurface(root, 'word_detail');
      await write(root, 'lib/features/search/internal/good.dart',
          directive('features/word_detail/port/word_detail.dart'));
      await write(root, 'lib/features/search/internal/deep.dart',
          directive('features/word_detail/port/model/detail.dart'));
      await write(root, 'lib/features/search/internal/internal.dart',
          directive('features/word_detail/internal/application/service.dart'));
      await write(root, 'lib/features/search/internal/seam.dart',
          directive('features/word_detail/port/presentation_dependencies.dart'));

      final violations = await check(root);
      expectRule(violations, 'feature_external_only_facade');
      expectRule(violations, 'feature_external_no_internal');
      expectRule(violations, 'feature_technical_seam_only');
      expect(
        violations.where((v) => v.source.endsWith('/good.dart')),
        isEmpty,
      );
    });

    test('discovers a canonical facade without requiring every seam',
        () async {
      await write(root, 'lib/features/notes/port/notes.dart', 'library;');
      await write(root, 'lib/features/notes/port/query.dart', 'class Query {}');
      await write(root, 'lib/features/notes/port/composition.dart',
          'Object compose(ProviderListenable provider) => provider;');
      await write(root, 'lib/app/bad_deep.dart',
          directive('features/notes/port/query.dart'));
      await write(root, 'lib/app/bad_seam.dart',
          directive('features/notes/port/composition.dart'));

      final violations = await check(root);
      expectRule(violations, 'feature_external_only_facade');
      expectRule(violations, 'feature_technical_seam_only');
      expectRule(violations, 'composition_no_provider_types');
    });

    test('limits the Sync dataset SPI to dataset-owner technical code',
        () async {
      await write(root, 'lib/features/sync/port/sync.dart', 'library;');
      await write(root, 'lib/features/sync/port/dataset_contract.dart',
          'abstract interface class DatasetSyncGateway {}');
      await write(root, 'lib/features/my_word/port/composition.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root,
          'lib/features/my_word/internal/infrastructure/sync/service.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/bootstrap/sync.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root,
          'lib/app/infrastructure/firebase/remote_mutation_executor.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/integration/sync/executor.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/features/my_word/internal/application/bad.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/features/my_word/internal/presentation/bad.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/bad_business.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/presentation/bad.dart',
          directive('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/integration/catalog_sync/bad.dart',
          directive('features/sync/port/dataset_contract.dart'));

      final violations = await check(root);
      for (final allowed in [
        'lib/features/my_word/port/composition.dart',
        'lib/features/my_word/internal/infrastructure/sync/service.dart',
        'lib/app/bootstrap/sync.dart',
        'lib/app/infrastructure/firebase/remote_mutation_executor.dart',
        'lib/integration/sync/executor.dart',
      ]) {
        expect(
          violations.where((v) =>
              v.source == allowed &&
              (v.ruleId == 'feature_technical_seam_only' ||
                  v.ruleId == 'feature_external_only_facade' ||
                  v.ruleId == 'integration_feature_only_facade')),
          isEmpty,
        );
      }
      for (final rejected in [
        'lib/features/my_word/internal/application/bad.dart',
        'lib/features/my_word/internal/presentation/bad.dart',
        'lib/app/bad_business.dart',
        'lib/app/presentation/bad.dart',
        'lib/integration/catalog_sync/bad.dart',
      ]) {
        expect(
          violations.any((v) =>
              v.source == rejected &&
              v.ruleId == 'feature_technical_seam_only'),
          isTrue,
          reason: rejected,
        );
      }
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

Future<void> writeStrictSurface(Directory root, String feature) async {
  final port = 'lib/features/$feature/port';
  await write(root, '$port/$feature.dart', 'library;');
  await write(root, '$port/composition.dart',
      "import 'package:my_dic/features/$feature/internal/composition/${feature}_composition_factory.dart';");
  await write(root, '$port/presentation_dependencies.dart',
      "import 'package:flutter_riverpod/flutter_riverpod.dart';");
  await write(root, '$port/presentation_entry.dart',
      "export 'package:my_dic/features/$feature/internal/presentation/view/view.dart';");
}

String directive(String target) => "import 'package:my_dic/$target';";
void expectRule(Iterable<FeatureDependencyViolation> violations, String rule) =>
    expect(violations.any((violation) => violation.ruleId == rule), isTrue,
        reason: '$rule: $violations');
