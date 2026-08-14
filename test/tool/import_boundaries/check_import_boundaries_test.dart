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

    test('allows Riverpod in app bootstrap composition roots', () async {
      await write(
        root,
        'lib/app/bootstrap/my_word_composition.dart',
        sdk('flutter_riverpod/flutter_riverpod.dart'),
      );

      expect(await check(root), isEmpty);
    });

    test('rejects Riverpod from feature business implementation layers',
        () async {
      await write(
        root,
        'lib/features/a/internal/application/use_case.dart',
        sdk('flutter_riverpod/flutter_riverpod.dart'),
      );
      await write(
        root,
        'lib/features/a/internal/infrastructure/store.dart',
        sdk('riverpod/riverpod.dart'),
      );

      final violations = (await check(root))
          .where((v) => v.ruleId == 'business_port_no_framework');
      expect(violations, hasLength(2));
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

    test('enforces the Auth facade, pure composition and routing-owned entry',
        () async {
      await writeStrictSurface(root, 'auth');
      await write(root, 'lib/app/use.dart', imp('features/auth/port/auth.dart'));
      await write(
        root,
        'lib/app/bootstrap/auth_composition.dart',
        imp('features/auth/port/composition.dart'),
      );
      await write(
        root,
        'lib/app/routing/auth.dart',
        imp('features/auth/port/presentation_entry.dart'),
      );
      await write(
        root,
        'lib/integration/session_lifecycle_workflow/auth.dart',
        imp('features/auth/port/presentation_entry.dart'),
      );
      await write(
        root,
        'lib/features/auth/port/composition.dart',
        "${imp('features/auth/internal/composition/auth_composition_factory.dart')}\n"
            "${sdk('firebase_auth/firebase_auth.dart')}",
      );

      final violations = await check(root);
      expectRule(violations, 'feature_technical_seam_only');
      expectRule(violations, 'composition_no_framework');
      expectRule(violations, 'firebase_canonical_infrastructure_only');
      expect(
        violations.where((v) =>
            v.source == 'lib/app/use.dart' ||
            v.source == 'lib/app/bootstrap/auth_composition.dart' ||
            v.source == 'lib/app/routing/auth.dart'),
        isEmpty,
      );
    });

    test('allows a pure composition facade to call a framework-backed factory',
        () async {
      await write(root, 'lib/features/a/port/composition.dart',
          "export '../internal/composition/a_composition_factory.dart';");
      await write(root,
          'lib/features/a/internal/composition/a_composition_factory.dart',
          sdk('flutter_riverpod/flutter_riverpod.dart'));

      expect(await check(root), isEmpty);
    });

    test('rejects provider types but not DatabaseProvider in composition',
        () async {
      await write(root, 'lib/features/a/port/composition.dart',
          'Object compose(ProviderListenable provider) => provider;');
      await write(root, 'lib/features/b/port/composition.dart',
          'Object compose(DatabaseProvider database) => database;');

      final violations = await check(root);
      expectRule(violations, 'composition_no_provider_types');
      expect(
        violations.where((v) => v.source.contains('/features/b/')),
        isEmpty,
      );
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

    test('enforces WordDetail facade and technical seam ownership', () async {
      await writeStrictSurface(root, 'word_detail');
      await write(root, 'lib/features/word_detail/port/word_detail.dart',
          "export 'model.dart';");
      await write(root, 'lib/features/word_detail/port/model.dart',
          'class Detail {}');
      await write(root, 'lib/features/word_detail/internal/value.dart',
          'class Internal {}');
      await write(root, 'lib/features/search/internal/good.dart',
          imp('features/word_detail/port/word_detail.dart'));
      await write(root, 'lib/features/search/internal/deep.dart',
          imp('features/word_detail/port/model.dart'));
      await write(root, 'lib/features/search/internal/internal.dart',
          imp('features/word_detail/internal/value.dart'));
      await write(root, 'lib/features/search/internal/seam.dart',
          imp('features/word_detail/port/presentation_dependencies.dart'));

      final violations = await check(root);
      expectRule(violations, 'feature_external_only_facade');
      expectRule(violations, 'feature_external_no_internal');
      expectRule(violations, 'feature_technical_seam_only');
      expect(
        violations.where((v) => v.source.endsWith('/good.dart')),
        isEmpty,
      );
    });

    test('rejects Catalog internal and deep port imports from consumers',
        () async {
      await write(root, 'lib/features/search/internal/use.dart',
          "${imp('features/catalog/internal/domain/value.dart')}\n${imp('features/catalog/port/catalog_word_ref.dart')}");

      final violations = await check(root);
      expectRule(violations, 'catalog_external_no_internal');
      expectRule(violations, 'catalog_external_only_facade');
    });

    test('allows the Catalog facade and narrowly scoped public bridges',
        () async {
      await write(root, 'lib/features/search/internal/use.dart',
          imp('features/catalog/port/catalog.dart'));
      await write(root, 'lib/app/bootstrap/catalog.dart',
          imp('features/catalog/port/composition.dart'));

      final catalogRules = (await check(root))
          .where((violation) => violation.ruleId.startsWith('catalog_'));
      expect(catalogRules, isEmpty);
    });

    test('allows only Catalog composition to expose its exact factory',
        () async {
      const factory =
          'features/catalog/internal/composition/catalog_composition_factory.dart';
      const otherFactory =
          'features/catalog/internal/composition/other_factory.dart';
      await write(root, 'lib/features/catalog/port/composition.dart',
          "export 'package:my_dic/$factory';\nexport 'package:my_dic/$otherFactory';");
      await write(root, 'lib/$factory', 'void composeCatalog() {}');
      await write(root, 'lib/$otherFactory', 'void composeOther() {}');

      final violations = await check(root);
      expect(violations.where((v) => v.ruleId == 'composition_exact_facade'),
          hasLength(1));
      expect(
          violations
              .singleWhere((v) => v.ruleId == 'composition_exact_facade')
              .target,
          endsWith('/other_factory.dart'));
    });

    test('does not widen Catalog bridge exceptions to arbitrary callers',
        () async {
      await write(root, 'lib/app/use.dart',
          imp('features/catalog/port/composition.dart'));
      await write(root, 'lib/features/quiz/internal/application/use.dart',
          imp('features/catalog/port/catalog_word_ref.dart'));

      expect(
          (await check(root))
              .where((v) => v.ruleId == 'catalog_external_only_facade'),
          hasLength(2));
    });

    test('allows integration to import only the Catalog facade', () async {
      await write(root, 'lib/integration/catalog_search/good.dart',
          imp('features/catalog/port/catalog.dart'));
      await write(root, 'lib/integration/catalog_search/bad.dart',
          imp('features/catalog/port/catalog_word_ref.dart'));

      expectRule(await check(root), 'integration_catalog_only_facade');
    });

    test('enforces the MyWord facade and rejects internal consumers', () async {
      await write(root, 'lib/features/search/internal/good.dart',
          imp('features/my_word/port/my_word.dart'));
      await write(root, 'lib/features/search/internal/bad.dart',
          "${imp('features/my_word/internal/domain/entity.dart')}\n${imp('features/my_word/port/command.dart')}");

      final violations = await check(root);
      expectRule(violations, 'my_word_external_no_internal');
      expectRule(violations, 'my_word_external_only_facade');
      expect(
          violations.where((v) =>
              v.source.endsWith('/good.dart') &&
              v.ruleId.startsWith('my_word_')),
          isEmpty);
    });

    test('allows only MyWord composition and presentation technical seams',
        () async {
      await write(root, 'lib/app/bootstrap/my_word.dart',
          imp('features/my_word/port/composition.dart'));
      await write(root, 'lib/app/routing/my_word.dart',
          imp('features/my_word/port/presentation_entry.dart'));

      final violations = await check(root);
      expect(violations.where((v) => v.ruleId.startsWith('my_word_')), isEmpty);
    });

    test('rejects app composition importing MyWord internal code', () async {
      await write(
        root,
        'lib/app/bootstrap/my_word_composition.dart',
        imp('features/my_word/internal/composition/my_word_composition_factory.dart'),
      );

      expectRule(await check(root), 'my_word_external_no_internal');
    });

    test('allows only MyWord canonical composition factory', () async {
      await write(
        root,
        'lib/features/my_word/port/composition.dart',
        "${imp('features/my_word/internal/composition/my_word_composition_factory.dart')}\n"
            "${imp('features/my_word/internal/composition/other_factory.dart')}",
      );

      final violations = (await check(root)).where((v) =>
          v.ruleId == 'composition_exact_facade' &&
          v.source.endsWith('/my_word/port/composition.dart'));
      expect(violations, hasLength(1));
      expect(violations.single.target, endsWith('/other_factory.dart'));
    });

    test('rejects opaque dependency resolvers in MyWord composition', () async {
      await write(
        root,
        'lib/features/my_word/port/composition.dart',
        'typedef Reader = T Function<T>(Object dependency);',
      );

      expectRule(await check(root), 'composition_no_provider_types');
    });

    test('keeps MyWord composition out of the business facade', () async {
      await write(
        root,
        'lib/features/my_word/port/my_word.dart',
        "export 'composition.dart';",
      );

      expectRule(await check(root), 'my_word_external_only_facade');
    });

    test('allows typed technical contracts and canonical factory in composition',
        () async {
      await write(
        root,
        'lib/features/my_word/port/composition.dart',
        "${imp('core/port/firebase_account_nested_document_gateway.dart')}\n"
            "${imp('core/infrastructure/database/drift/database_provider.dart')}\n"
            "${imp('features/my_word/internal/composition/my_word_composition_factory.dart')}\n"
            "export 'package:my_dic/features/my_word/port/composition_contract.dart';\n"
            "${imp('features/sync/port/dataset_contract.dart')}\n"
            'Object compose(DatabaseProvider database) => database;',
      );

      expect(
        (await check(root)).where(
          (v) => v.source.endsWith('/my_word/port/composition.dart'),
        ),
        isEmpty,
      );
    });

    test('permits Firebase SDK imports only in external-system infrastructure',
        () async {
      await write(
        root,
        'lib/app/infrastructure/firebase/remote.dart',
        sdk('cloud_firestore/cloud_firestore.dart'),
      );
      await write(
        root,
        'lib/core/infrastructure/firebase/account.dart',
        sdk('firebase_auth/firebase_auth.dart'),
      );
      await write(
        root,
        'lib/app/workflow/remote.dart',
        sdk('cloud_firestore/cloud_firestore.dart'),
      );
      await write(
        root,
        'lib/features/my_word/internal/application/remote.dart',
        sdk('cloud_firestore/cloud_firestore.dart'),
      );

      final violations = await check(root);
      expect(
        violations.where((v) =>
            v.ruleId == 'firebase_canonical_infrastructure_only' &&
            (v.source.endsWith('/app/workflow/remote.dart') ||
                v.source.endsWith('/internal/application/remote.dart'))),
        hasLength(2),
      );
    });

    test('rejects Search and Quiz dependencies from Catalog internal',
        () async {
      await write(root, 'lib/features/catalog/internal/application/use.dart',
          "${imp('features/search/port/search.dart')}\n${imp('features/quiz/port/quiz.dart')}");

      final violations = await check(root);
      expect(
          violations
              .where((v) => v.ruleId == 'catalog_internal_no_search_quiz'),
          hasLength(2));
    });

    test(
        'rejects framework imports from Catalog business and composition ports',
        () async {
      await write(root, 'lib/features/catalog/port/catalog.dart',
          sdk('flutter_riverpod/flutter_riverpod.dart'));
      await write(root, 'lib/features/catalog/port/composition.dart',
          "${sdk('flutter_riverpod/flutter_riverpod.dart')}\n${sdk('drift/drift.dart')}");
      final violations = await check(root);
      expect(
          violations
              .where((v) => v.ruleId == 'catalog_port_framework_only_bridges'),
          hasLength(3));
      expect(
          violations
              .where((v) => v.ruleId == 'catalog_port_framework_only_bridges')
              .map((v) => v.target),
          containsAll(<String>[
            'package:flutter_riverpod/flutter_riverpod.dart',
            'package:drift/drift.dart',
          ]));
    });

    test('enforces the Quiz facade and its narrow technical seams', () async {
      await write(root, 'lib/features/search/internal/good.dart',
          imp('features/quiz/port/quiz.dart'));
      await write(root, 'lib/features/search/internal/bad.dart',
          "${imp('features/quiz/internal/application/service.dart')}\n${imp('features/quiz/port/query/quiz_game_query.dart')}");
      await write(root, 'lib/app/bootstrap/quiz.dart',
          "${imp('features/quiz/port/composition.dart')}\n${imp('features/quiz/port/presentation_dependencies.dart')}\n${imp('features/quiz/internal/infrastructure/assets.dart')}");
      await write(root, 'lib/app/routing/quiz.dart',
          imp('features/quiz/port/presentation_entry.dart'));

      final violations = await check(root);
      expectRule(violations, 'quiz_external_no_internal');
      expectRule(violations, 'quiz_external_only_facade');
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

    test('rejects Quiz implementation and framework imports in integration',
        () async {
      await write(root, 'lib/integration/catalog_quiz/good.dart',
          imp('features/quiz/port/quiz.dart'));
      await write(root, 'lib/integration/catalog_quiz/bad.dart',
          "${imp('features/quiz/internal/infrastructure/drift/dao.dart')}\n${sdk('drift/drift.dart')}\n${sdk('flutter/widgets.dart')}");

      final violations = await check(root);
      expectRule(violations, 'integration_quiz_only_facade');
      expectRule(violations, 'integration_quiz_no_framework_or_drift');
    });

    test('allows the generic Search facade and its three technical seams',
        () async {
      await writeStrictSurface(root, 'search');
      await write(root, 'lib/app/use.dart', imp('features/search/port/search.dart'));
      await write(root, 'lib/app/bootstrap/search.dart',
          "${imp('features/search/port/composition.dart')}\n${imp('features/search/port/presentation_dependencies.dart')}");
      await write(root, 'lib/app/routing/search.dart',
          imp('features/search/port/presentation_entry.dart'));
      await write(root, 'lib/integration/catalog_search/catalog_search_providers.dart',
          imp('features/search/port/composition.dart'));

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

    test('allows the UserProfile facade and controlled technical seams',
        () async {
      await writeStrictSurface(root, 'user_profile');
      await write(root, 'lib/app/use.dart',
          imp('features/user_profile/port/user_profile.dart'));
      await write(root, 'lib/app/bootstrap/user_profile.dart',
          imp('features/user_profile/port/composition.dart'));
      await write(root, 'lib/app/routing/user_profile.dart',
          imp('features/user_profile/port/presentation_entry.dart'));

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
          imp('features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart'));
      await write(root, 'lib/app/bad_user_profile_wire.dart',
          imp('features/user_profile/port/user_profile_remote_dto.dart'));
      await write(root, 'lib/app/bad_user_profile_entry.dart',
          imp('features/user_profile/port/presentation_entry.dart'));
      await write(root, 'lib/features/user_profile/port/composition.dart',
          "${imp('features/user_profile/internal/composition/user_profile_composition_factory.dart')}\n${imp('features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart')}\n${sdk('flutter_riverpod/flutter_riverpod.dart')}\ntypedef Reader = T Function<T>(Object value);");
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

    test('rejects generic Search internal, deep port, seam and wiring leaks',
        () async {
      await writeStrictSurface(root, 'search');
      await write(root, 'lib/app/bad_internal.dart',
          imp('features/search/internal/application/service.dart'));
      await write(root, 'lib/app/bad_deep.dart',
          imp('features/search/port/query/search_query.dart'));
      await write(root, 'lib/app/bad_entry.dart',
          imp('features/search/port/presentation_entry.dart'));
      await write(root, 'lib/integration/catalog_search/adapter.dart',
          "${imp('features/search/port/query/search_query.dart')}\n${sdk('flutter/widgets.dart')}");
      await write(root, 'lib/features/search/port/composition.dart',
          "${imp('features/search/internal/composition/search_composition_factory.dart')}\n${imp('features/search/internal/application/service.dart')}\n${sdk('flutter_riverpod/flutter_riverpod.dart')}\ntypedef Reader = T Function<T>(Object value);");
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

    test('discovers a canonical facade without requiring every seam',
        () async {
      await write(root, 'lib/features/notes/port/notes.dart', 'library;');
      await write(root, 'lib/features/notes/port/query.dart', 'class Query {}');
      await write(root, 'lib/features/notes/port/composition.dart',
          'Object compose(ProviderListenable provider) => provider;');
      await write(root, 'lib/app/bad_deep.dart',
          imp('features/notes/port/query.dart'));
      await write(root, 'lib/app/bad_seam.dart',
          imp('features/notes/port/composition.dart'));

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
          imp('features/sync/port/dataset_contract.dart'));
      await write(root,
          'lib/features/my_word/internal/infrastructure/sync/service.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/bootstrap/sync.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root,
          'lib/app/infrastructure/firebase/remote_mutation_executor.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/integration/sync/executor.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/features/my_word/internal/application/bad.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/features/my_word/internal/presentation/bad.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/bad_business.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/app/presentation/bad.dart',
          imp('features/sync/port/dataset_contract.dart'));
      await write(root, 'lib/integration/catalog_sync/bad.dart',
          imp('features/sync/port/dataset_contract.dart'));

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

Future<String> baselineFile() async {
  final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}empty-boundary-baseline.json');
  await file.writeAsString('{"violations":[]}');
  return file.path;
}
