import 'dart:io';

/// Checks dependencies at the feature public boundary and inside a feature.
///
/// Usage: `dart run tool/check_feature_dependencies.dart [--root <path>]`.
Future<void> main(List<String> args) async {
  final root = parseRoot(args);
  final violations = await FeatureDependencyChecker().check(root: root);
  for (final violation in violations) {
    stdout.writeln(
        '${violation.ruleId}:\n  ${violation.source} -> \n  ${violation.target}\n');
  }
  if (violations.isNotEmpty) exitCode = 1;
}

class FeatureDependencyChecker {
  Future<List<FeatureDependencyViolation>> check({String root = '.'}) async {
    final imports = <_Import>[];
    final sources = <String, String>{};
    final lib = Directory('$root${Platform.pathSeparator}lib');
    if (!await lib.exists()) return const [];

    await for (final file in lib.list(recursive: true)) {
      if (file is! File ||
          !file.path.endsWith('.dart') ||
          file.path.endsWith('.g.dart') ||
          file.path.endsWith('.freezed.dart')) {
        continue;
      }
      final source = relative(root, file.path);
      final contents = await file.readAsString();
      sources[source] = contents;
      for (final target in importsOf(contents)) {
        final localTarget = resolve(source, target);
        imports.add(_Import(source, target, localTarget));
      }
    }

    final violations = <FeatureDependencyViolation>[];
    final strictFeatures = strictFacadeFeatures(sources.keys);
    for (final entry in imports) {
      final sourceFeature = featureOf(entry.source);
      final target = entry.localTarget;
      final targetFeature = target == null ? null : featureOf(target);

      if (targetFeature != null &&
          strictFeatures.contains(targetFeature) &&
          sourceFeature != targetFeature) {
        if (target!.startsWith('lib/features/$targetFeature/internal/')) {
          violations.add(FeatureDependencyViolation(
            'feature_external_no_internal',
            entry.source,
            entry.target,
          ));
        } else if (target.startsWith('lib/features/$targetFeature/port/')) {
          if (isTechnicalSeam(target)) {
            if (!isAllowedTechnicalSeamCaller(entry.source, target)) {
              violations.add(FeatureDependencyViolation(
                'feature_technical_seam_only',
                entry.source,
                entry.target,
              ));
            }
          } else if (target != featureFacade(targetFeature)) {
            violations.add(FeatureDependencyViolation(
              'feature_external_only_facade',
              entry.source,
              entry.target,
            ));
          }

          if (entry.source.startsWith('lib/integration/') &&
              target != featureFacade(targetFeature) &&
              !((isComposition(target) && isIntegrationWiring(entry.source)) ||
                  (isSyncDatasetContract(target) &&
                      isAllowedSyncDatasetContractCaller(entry.source)))) {
            violations.add(FeatureDependencyViolation(
              'integration_feature_only_facade',
              entry.source,
              entry.target,
            ));
          }
        }
      }
      if (isStrictFeatureIntegration(entry.source, strictFeatures) &&
          !isIntegrationWiring(entry.source) &&
          isFrameworkImport(entry.target)) {
        violations.add(FeatureDependencyViolation(
          'integration_feature_no_framework',
          entry.source,
          entry.target,
        ));
      }

      if (sourceFeature != null &&
          strictFeatures.contains(sourceFeature) &&
          target != null &&
          sourceFeature == targetFeature &&
          target.contains('/internal/')) {
        if (isComposition(entry.source) &&
            !isAllowedCompositionFactoryBridge(entry.source, target)) {
          violations.add(FeatureDependencyViolation(
            'composition_exact_facade',
            entry.source,
            entry.target,
          ));
        }
        if (isPresentationEntry(entry.source) &&
            !isControlledPresentationTarget(target)) {
          violations.add(FeatureDependencyViolation(
            'presentation_entry_exact_facade',
            entry.source,
            entry.target,
          ));
        }
      }
      if (sourceFeature != null &&
          strictFeatures.contains(sourceFeature) &&
          (isBusinessPort(entry.source) || isComposition(entry.source)) &&
          isFrameworkImport(entry.target) &&
          !isAllowedTechnicalBridgeFrameworkImport(
            entry.source,
            entry.target,
          )) {
        violations.add(FeatureDependencyViolation(
          isComposition(entry.source)
              ? 'composition_no_framework'
              : 'business_port_no_framework',
          entry.source,
          entry.target,
        ));
      }

      // A feature's implementation is private to its owner. Every other
      // consumer, including app/core, reaches it through port/.
      if (targetFeature != null &&
          sourceFeature != targetFeature &&
          !target!.startsWith('lib/features/$targetFeature/port/')) {
        violations.add(FeatureDependencyViolation(
            'feature_import_only_port', entry.source, entry.target));
      }

      final sourceLayer = internalLayerOf(entry.source);
      final targetLayer = target == null ? null : internalLayerOf(target);
      if (sourceFeature != null &&
          sourceFeature == targetFeature &&
          sourceLayer != null &&
          targetLayer != null &&
          (forbiddenInternalLayers[sourceLayer] ?? const <String>{})
              .contains(targetLayer)) {
        violations.add(FeatureDependencyViolation(
            'internal_clean_architecture', entry.source, entry.target));
      }

      if (target != null &&
          target.startsWith('lib/features/catalog/internal/') &&
          sourceFeature != 'catalog') {
        violations.add(FeatureDependencyViolation(
            'catalog_external_no_internal', entry.source, entry.target));
      }
      if (target != null &&
          target.startsWith('lib/features/catalog/port/') &&
          sourceFeature != 'catalog' &&
          !isAllowedCatalogExternalPortImport(entry.source, target)) {
        violations.add(FeatureDependencyViolation(
            'catalog_external_only_facade', entry.source, entry.target));
      }
      if (target != null &&
          entry.source.startsWith('lib/integration/') &&
          target.startsWith('lib/features/catalog/') &&
          target != _catalogFacade) {
        violations.add(FeatureDependencyViolation(
            'integration_catalog_only_facade', entry.source, entry.target));
      }
      if (target != null &&
          target.startsWith('lib/features/my_word/internal/') &&
          sourceFeature != 'my_word') {
        violations.add(FeatureDependencyViolation(
            'my_word_external_no_internal', entry.source, entry.target));
      }
      if (target != null &&
          target.startsWith('lib/features/my_word/port/') &&
          sourceFeature != 'my_word' &&
          !isAllowedMyWordExternalPortImport(entry.source, target)) {
        violations.add(FeatureDependencyViolation(
            'my_word_external_only_facade', entry.source, entry.target));
      }
      if (target != null &&
          target.startsWith('lib/features/quiz/internal/') &&
          sourceFeature != 'quiz') {
        violations.add(FeatureDependencyViolation(
            'quiz_external_no_internal', entry.source, entry.target));
      }
      if (target != null &&
          target.startsWith('lib/features/quiz/port/') &&
          sourceFeature != 'quiz' &&
          !isAllowedQuizExternalPortImport(entry.source, target)) {
        violations.add(FeatureDependencyViolation(
            'quiz_external_only_facade', entry.source, entry.target));
      }
      if (target != null &&
          entry.source.startsWith('lib/integration/') &&
          target.startsWith('lib/features/quiz/') &&
          target != _quizFacade) {
        violations.add(FeatureDependencyViolation(
            'integration_quiz_only_facade', entry.source, entry.target));
      }
      if (entry.source.startsWith('lib/integration/catalog_quiz/') &&
          (entry.target.startsWith('package:flutter/') ||
              entry.target.startsWith('package:flutter_riverpod/') ||
              entry.target.startsWith('package:drift/'))) {
        violations.add(FeatureDependencyViolation(
            'integration_quiz_no_framework_or_drift',
            entry.source,
            entry.target));
      }
      if (entry.source.startsWith('lib/features/catalog/internal/') &&
          (targetFeature == 'search' || targetFeature == 'quiz')) {
        violations.add(FeatureDependencyViolation(
            'catalog_internal_no_search_quiz', entry.source, entry.target));
      }
      if (entry.source.startsWith('lib/features/catalog/port/') &&
          isFrameworkImport(entry.target) &&
          !isAllowedCatalogBridgeFrameworkImport(entry.source, entry.target)) {
        violations.add(FeatureDependencyViolation(
            'catalog_port_framework_only_bridges', entry.source, entry.target));
      }
    }

    for (final source in sources.keys.where(isComposition)) {
      final contents = sources[source]!;
      if (RegExp(
        r'\b(?:Provider|Ref|Override|ProviderContainer|ProviderListenable)\b',
      ).hasMatch(contents)) {
        violations.add(FeatureDependencyViolation(
          'composition_no_provider_types',
          source,
          'public signature/provider type',
        ));
      }
      if (RegExp(
        r'T\s+Function<T>\s*\(\s*(?:Object|dynamic)|\bas\s+T\b',
      ).hasMatch(contents)) {
        violations.add(FeatureDependencyViolation(
          'composition_no_provider_types',
          source,
          'opaque dependency resolver',
        ));
      }
    }
    return violations.toSet().toList()..sort();
  }
}

const forbiddenInternalLayers = <String, Set<String>>{
  'domain': {
    'application',
    'infrastructure',
    'presentation',
    'composition',
    'di'
  },
  'application': {'infrastructure', 'presentation', 'composition', 'di'},
  'infrastructure': {'presentation', 'composition', 'di'},
  'presentation': {
    'infrastructure',
    'composition',
  },
};

class _Import {
  const _Import(this.source, this.target, this.localTarget);
  final String source, target;
  final String? localTarget;
}

class FeatureDependencyViolation
    implements Comparable<FeatureDependencyViolation> {
  const FeatureDependencyViolation(this.ruleId, this.source, this.target);
  final String ruleId, source, target;
  @override
  int compareTo(FeatureDependencyViolation other) => '$ruleId|$source|$target'
      .compareTo('${other.ruleId}|${other.source}|${other.target}');
  @override
  bool operator ==(Object other) =>
      other is FeatureDependencyViolation &&
      ruleId == other.ruleId &&
      source == other.source &&
      target == other.target;
  @override
  int get hashCode => Object.hash(ruleId, source, target);
}

String parseRoot(List<String> args) {
  if (args.isEmpty) return '.';
  if (args.length == 2 && args.first == '--root') return args.last;
  throw ArgumentError('Usage: check_feature_dependencies.dart [--root <path>]');
}

/// Extracts every URI in import/export/part directives, including every
/// branch of a conditional import.
Iterable<String> importsOf(String source) =>
    RegExp(r'''(?:import|export|part)\s+[^;]*;''', multiLine: true)
        .allMatches(source)
        .expand((directive) => RegExp(r'''['"]([^'"]+)['"]''')
            .allMatches(directive.group(0)!)
            .map((uri) => uri.group(1)!));

String? resolve(String source, String target) {
  if (target.startsWith('package:my_dic/')) {
    return 'lib/${target.substring('package:my_dic/'.length)}';
  }
  if (target.startsWith('package:') || target.startsWith('dart:')) return null;
  return join(dirname(source), target);
}

String? featureOf(String path) =>
    RegExp(r'^lib/features/([^/]+)/').firstMatch(path)?.group(1);
String? internalLayerOf(String path) =>
    RegExp(r'^lib/features/[^/]+/internal/([^/]+)/').firstMatch(path)?.group(1);
String featureFacade(String feature) =>
    'lib/features/$feature/port/$feature.dart';
Set<String> strictFacadeFeatures(Iterable<String> paths) {
  final sources = paths.toSet();
  final features = sources.map(featureOf).whereType<String>().toSet();
  return features
      .where((feature) => sources.contains(featureFacade(feature)))
      .toSet();
}

bool isComposition(String path) => path.endsWith('/port/composition.dart');
bool isPresentationDependencies(String path) =>
    path.endsWith('/port/presentation_dependencies.dart');
bool isPresentationEntry(String path) =>
    path.endsWith('/port/presentation_entry.dart');
bool isTechnicalSeam(String path) =>
    isComposition(path) ||
    isPresentationDependencies(path) ||
    isPresentationEntry(path) ||
    isSyncDatasetContract(path);
bool isSyncDatasetContract(String path) =>
    path == 'lib/features/sync/port/dataset_contract.dart';
bool isBusinessPort(String path) =>
    path.contains('/port/') && !isTechnicalSeam(path);
bool isIntegrationWiring(String source) =>
    source.startsWith('lib/integration/') &&
    (source.endsWith('_providers.dart') ||
        source.endsWith('_composition.dart'));
bool isAllowedTechnicalSeamCaller(String source, String target) {
  if (isSyncDatasetContract(target)) {
    return isAllowedSyncDatasetContractCaller(source);
  }
  if (isComposition(target)) {
    return source.startsWith('lib/app/bootstrap/') ||
        isIntegrationWiring(source);
  }
  if (isPresentationDependencies(target)) {
    return source.startsWith('lib/app/bootstrap/');
  }
  return isPresentationEntry(target) && source.startsWith('lib/app/routing/');
}

bool isAllowedSyncDatasetContractCaller(String source) {
  if (source.startsWith('lib/app/bootstrap/')) return true;
  if (source.startsWith('lib/app/infrastructure/')) return true;
  if (source.startsWith('lib/integration/sync/')) return true;
  return RegExp(
    r'^lib/features/[^/]+/(?:port/composition\.dart|internal/(?:composition|infrastructure)/)',
  ).hasMatch(source);
}

bool isAllowedCompositionFactoryBridge(String source, String target) {
  final feature = featureOf(source);
  if (feature == null) return false;
  return target ==
      'lib/features/$feature/internal/composition/${feature}_composition_factory.dart';
}

bool isControlledPresentationTarget(String path) =>
    path.contains('/presentation/view/') || path.endsWith('/presentation/view.dart');
bool isStrictFeatureIntegration(String source, Set<String> strictFeatures) {
  final match = RegExp(r'^lib/integration/([^/]+)/').firstMatch(source);
  if (match == null) return false;
  final tokens = match.group(1)!.split('_').toSet();
  return strictFeatures.any(tokens.contains);
}

const _catalogFacade = 'lib/features/catalog/port/catalog.dart';
const _catalogComposition = 'lib/features/catalog/port/composition.dart';
const _myWordFacade = 'lib/features/my_word/port/my_word.dart';
const _myWordComposition = 'lib/features/my_word/port/composition.dart';
const _myWordPresentationEntry =
    'lib/features/my_word/port/presentation_entry.dart';
const _quizFacade = 'lib/features/quiz/port/quiz.dart';
const _quizComposition = 'lib/features/quiz/port/composition.dart';
const _quizPresentationDependencies =
    'lib/features/quiz/port/presentation_dependencies.dart';
const _quizPresentationEntry = 'lib/features/quiz/port/presentation_entry.dart';
const _frameworkPackages = {
  'flutter',
  'flutter_riverpod',
  'riverpod',
  'provider',
  'drift',
  'firebase_core',
  'firebase_auth',
  'cloud_firestore',
  'go_router',
};
bool isAllowedTechnicalBridgeFrameworkImport(String source, String target) =>
    (isPresentationDependencies(source) &&
        target.startsWith('package:flutter_riverpod/'));
bool isAllowedCatalogBridgeFrameworkImport(String source, String target) =>
    isAllowedTechnicalBridgeFrameworkImport(source, target);
bool isFrameworkImport(String target) =>
    _frameworkPackages.any((package) => target.startsWith('package:$package/'));
bool isAllowedCatalogExternalPortImport(String source, String target) {
  if (target == _catalogFacade) return true;
  if (target == _catalogComposition) {
    return source.startsWith('lib/app/bootstrap/');
  }
  return false;
}

bool isAllowedMyWordExternalPortImport(String source, String target) {
  if (target == _myWordFacade) return true;
  if (target == _myWordComposition) {
    return source.startsWith('lib/app/bootstrap/');
  }
  if (target == _myWordPresentationEntry) {
    return source.startsWith('lib/app/routing/');
  }
  return false;
}

bool isAllowedQuizExternalPortImport(String source, String target) {
  if (target == _quizFacade) return true;
  if (target == _quizComposition || target == _quizPresentationDependencies) {
    return source.startsWith('lib/app/bootstrap/');
  }
  return target == _quizPresentationEntry &&
      source.startsWith('lib/app/routing/');
}

String dirname(String path) => path.substring(0, path.lastIndexOf('/') + 1);
String relative(String root, String path) => normalize(path)
    .replaceFirst(RegExp('^${RegExp.escape(normalize(root))}/?'), '');
String normalize(String value) => value.replaceAll('\\', '/');
String join(String base, String target) {
  final parts = <String>[];
  for (final part in '$base/$target'.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(part);
    }
  }
  return parts.join('/');
}
