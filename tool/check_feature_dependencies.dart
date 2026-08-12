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
      for (final target in importsOf(await file.readAsString())) {
        final localTarget = resolve(source, target);
        imports.add(_Import(source, target, localTarget));
      }
    }

    final violations = <FeatureDependencyViolation>[];
    for (final entry in imports) {
      final sourceFeature = featureOf(entry.source);
      final target = entry.localTarget;
      final targetFeature = target == null ? null : featureOf(target);

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
const _catalogFacade = 'lib/features/catalog/port/catalog.dart';
const _catalogComposition = 'lib/features/catalog/port/composition.dart';
const _catalogPresentationDependencies =
    'lib/features/catalog/port/presentation_dependencies.dart';
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
bool isCatalogFrameworkBridge(String source) =>
    source == _catalogComposition || source == _catalogPresentationDependencies;
bool isAllowedCatalogBridgeFrameworkImport(String source, String target) =>
    isCatalogFrameworkBridge(source) &&
    target.startsWith('package:flutter_riverpod/');
bool isFrameworkImport(String target) =>
    _frameworkPackages.any((package) => target.startsWith('package:$package/'));
bool isAllowedCatalogExternalPortImport(String source, String target) {
  if (target == _catalogFacade) return true;
  if (target == _catalogComposition) {
    return source.startsWith('lib/app/bootstrap/');
  }
  if (target == _catalogPresentationDependencies) {
    return source.startsWith('lib/app/bootstrap/') ||
        RegExp(r'^lib/features/[^/]+/internal/(?:presentation|composition)/')
            .hasMatch(source);
  }
  return false;
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
