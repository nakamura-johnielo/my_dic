import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final options = Options.parse(args);
  final checker = ImportBoundaryChecker.fromFile(options.rulesPath);
  final violations = await checker.check();
  if (options.updateBaseline) {
    final path = options.baselinePath ?? 'tool/import_boundaries/baseline.json';
    await Baseline.write(path, violations, previous: await Baseline.read(path));
  }
  final report = options.check
      ? await compareWithBaseline(violations, options.baselinePath!)
      : Report(violations, const [], const []);
  if (options.format == 'json') {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report.toJson()));
  } else {
    printReport(report);
  }
  final failed =
      options.check ? report.hasFailures : report.violations.isNotEmpty;
  if (failed && !options.updateBaseline) exitCode = 1;
}

class ImportBoundaryChecker {
  ImportBoundaryChecker(this.rules, this.generatedPatterns, this.packageName);
  factory ImportBoundaryChecker.fromFile(String path) {
    final document =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    return ImportBoundaryChecker(
        (document['rules'] as List)
            .cast<Map<String, dynamic>>()
            .map(BoundaryRule.fromJson)
            .toList(),
        (document['generatedPathPatterns'] as List).cast<String>(),
        document['packageName'] as String);
  }
  final List<BoundaryRule> rules;
  final List<String> generatedPatterns;
  final String packageName;

  static const excludedFixturePatterns = <String>[
    'test/tool/import_boundaries/fixtures/**',
  ];

  Future<List<Violation>> check({String root = '.'}) async {
    final imports = <ImportEntry>[];
    final sources = <String, String>{};
    // This is a production architecture gate.  Tests intentionally use
    // white-box imports and shared fakes while characterising legacy code;
    // those imports must not be reported as production boundary debt.
    for (final sourceRoot in const ['lib']) {
      final directory = Directory('$root${Platform.pathSeparator}$sourceRoot');
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = relative(root, entity.path);
        if (isExcluded(source)) continue;
        final contents = entity.readAsStringSync();
        sources[source] = contents;
        for (final target in dartImports(contents)) {
          imports
              .add(ImportEntry(source, target, resolveTarget(source, target)));
        }
      }
    }
    final violations = <Violation>[];
    for (final entry in imports) {
      if (entry.localTarget != null && isGenerated(entry.localTarget!)) {
        continue;
      }
      for (final rule in rules) {
        if (rule.violates(entry)) {
          violations.add(Violation(rule.id, entry.source, entry.target));
        }
      }
    }
    violations.addAll(findFeatureCycles(imports));
    violations.addAll(semanticViolations(
      imports,
      sources,
      strictFacadeFeatures(sources.keys),
    ));
    return violations.toSet().toList()..sort();
  }

  bool isGenerated(String path) =>
      generatedPatterns.any((pattern) => matches(path, pattern));
  bool isExcluded(String path) =>
      isGenerated(path) ||
      excludedFixturePatterns.any((pattern) => matches(path, pattern));
  String? resolveTarget(String source, String target) {
    if (target.startsWith('package:$packageName/')) {
      return 'lib/${target.substring('package:$packageName/'.length)}';
    }
    if (target.startsWith('package:') || target.startsWith('dart:')) {
      return null;
    }
    return join(dirname(source), normalize(target));
  }
}

class BoundaryRule {
  BoundaryRule.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        sourcePath = json['sourcePath'] as String,
        forbiddenSourcePath = json['forbiddenSourcePath'] as String?,
        forbiddenTargetPath = json['forbiddenTargetPath'] as String?,
        forbiddenPackages =
            (json['forbiddenPackages'] as List? ?? const []).cast<String>(),
        allowedSourcePaths =
            (json['allowedSourcePaths'] as List? ?? const []).cast<String>();
  final String id, sourcePath;
  final String? forbiddenSourcePath, forbiddenTargetPath;
  final List<String> forbiddenPackages, allowedSourcePaths;
  bool violates(ImportEntry entry) {
    final ruleSource = sourceForRuleMatching(entry.source);
    if (!matches(ruleSource, sourcePath) ||
        allowedSourcePaths.any((path) => matches(entry.source, path))) {
      return false;
    }
    if (forbiddenSourcePath != null &&
        !matches(ruleSource, forbiddenSourcePath!)) {
      return false;
    }
    final forbiddenPackage = forbiddenPackages
        .any((package) => entry.target.startsWith('package:$package/'));
    final forbiddenTarget = entry.localTarget != null &&
        forbiddenTargetPath != null &&
        matches(entry.localTarget!, forbiddenTargetPath!);
    if (!forbiddenPackage && !forbiddenTarget) return false;
    if (id != 'no_cross_feature_presentation') return true;
    final sourceFeature = featureOf(sourceForRuleMatching(entry.source));
    final targetFeature =
        entry.localTarget == null ? null : featureOf(entry.localTarget!);
    return sourceFeature != null &&
        targetFeature != null &&
        sourceFeature != targetFeature;
  }
}

class ImportEntry {
  const ImportEntry(this.source, this.target, this.localTarget);
  final String source, target;
  final String? localTarget;
}

class Violation implements Comparable<Violation> {
  const Violation(this.ruleId, this.source, this.target);
  final String ruleId, source, target;
  Map<String, String> toJson() =>
      {'ruleId': ruleId, 'source': source, 'target': target};
  @override
  int compareTo(Violation other) => key(this).compareTo(key(other));
  @override
  bool operator ==(Object other) =>
      other is Violation && key(this) == key(other);
  @override
  int get hashCode => key(this).hashCode;
}

class Baseline {
  Baseline(this.records, {this.zeroViolationRuleIds = const {}});
  final Map<String, Map<String, dynamic>> records;
  final Set<String> zeroViolationRuleIds;
  static Future<Baseline> read(String path) async {
    final file = File(path);
    if (!await file.exists()) return Baseline({});
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final entries =
        (json['violations'] as List? ?? const []).cast<Map<String, dynamic>>();
    return Baseline(
      {for (final entry in entries) keyJson(entry): entry},
      zeroViolationRuleIds: ((json['zeroViolationRuleIds'] as List? ?? const [])
          .cast<String>()
          .toSet()),
    );
  }

  static Future<void> write(String path, List<Violation> violations,
      {required Baseline previous}) async {
    final zeroViolationRecords = violations
        .where((violation) =>
            previous.zeroViolationRuleIds.contains(violation.ruleId))
        .toList();
    if (zeroViolationRecords.isNotEmpty) {
      throw StateError(
          'Cannot baseline zero-violation rules: $zeroViolationRecords');
    }
    final entries = violations.map((v) {
      final old = previous.records[key(v)];
      return {
        ...v.toJson(),
        'introducedAt': old?['introducedAt'] ??
            DateTime.now().toUtc().toIso8601String().split('T').first,
        'owner': old?['owner'] ?? 'architecture',
        'trackingIssue': old?['trackingIssue'] ?? 'docs/refactor/phase1'
      };
    }).toList()
      ..sort((a, b) => keyJson(a).compareTo(keyJson(b)));
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString('${const JsonEncoder.withIndent('  ').convert({
          'zeroViolationRuleIds': previous.zeroViolationRuleIds.toList()
            ..sort(),
          'violations': entries
        })}\n');
  }
}

class Report {
  const Report(this.violations, this.added, this.removed);
  final List<Violation> violations, added, removed;
  bool get hasFailures => added.isNotEmpty || removed.isNotEmpty;
  Map<String, dynamic> toJson() => {
        'violations': violations.map((v) => v.toJson()).toList(),
        'added': added.map((v) => v.toJson()).toList(),
        'removed': removed.map((v) => v.toJson()).toList()
      };
}

Future<Report> compareWithBaseline(List<Violation> actual, String path) async {
  final baseline = await Baseline.read(path);
  final actualMap = {for (final v in actual) key(v): v};
  final expected = {
    for (final e in baseline.records.entries)
      e.key: Violation(e.value['ruleId'] as String, e.value['source'] as String,
          e.value['target'] as String)
  };
  final added = actualMap.keys
      .where((k) => !expected.containsKey(k))
      .map((k) => actualMap[k]!)
      .toList()
    ..sort();
  final removed = expected.keys
      .where((k) => !actualMap.containsKey(k))
      .map((k) => expected[k]!)
      .toList()
    ..sort();
  return Report(actual, added, removed);
}

class Options {
  Options(this.rulesPath, this.baselinePath, this.updateBaseline, this.check,
      this.format);
  factory Options.parse(List<String> args) {
    String? baseline;
    var update = false,
        check = false,
        format = 'text',
        rules = 'tool/import_boundaries/rules.json';
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (arg == '--baseline') {
        baseline = args[++i];
      } else if (arg == '--rules') {
        rules = args[++i];
      } else if (arg == '--update-baseline') {
        update = true;
      } else if (arg == '--check') {
        check = true;
      } else if (arg == '--format') {
        format = args[++i];
      } else if (arg.startsWith('--format=')) {
        format = arg.substring(9);
      } else {
        throw ArgumentError('Unknown argument: $arg');
      }
    }
    if (check && baseline == null) {
      throw ArgumentError('--check requires --baseline <path>.');
    }
    if (format != 'text' && format != 'json') {
      throw ArgumentError('Unsupported format: $format');
    }
    return Options(rules, baseline, update, check, format);
  }
  final String rulesPath;
  final String? baselinePath;
  final bool updateBaseline, check;
  final String format;
}

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

/// Rules which depend on feature ownership rather than just glob matching.
/// Keeping them here makes the JSON file an auditable list of rule IDs while
/// avoiding broad allowlists for same-feature and cross-feature directions.
List<Violation> semanticViolations(
  List<ImportEntry> imports,
  Map<String, String> sources,
  Set<String> strictFeatures,
) {
  final result = <Violation>[];
  final bySource = <String, List<ImportEntry>>{};
  for (final entry in imports) {
    (bySource[entry.source] ??= []).add(entry);
    final sourceFeature = featureOf(sourceForRuleMatching(entry.source));
    final targetFeature =
        entry.localTarget == null ? null : featureOf(entry.localTarget!);
    final target = entry.localTarget;

    if (targetFeature != null &&
        strictFeatures.contains(targetFeature) &&
        sourceFeature != targetFeature) {
      if (target!.startsWith('lib/features/$targetFeature/internal/')) {
        result.add(Violation(
          'feature_external_no_internal',
          entry.source,
          entry.target,
        ));
      } else if (target.startsWith('lib/features/$targetFeature/port/')) {
        if (isTechnicalSeam(target)) {
          if (!isAllowedTechnicalSeamCaller(
            entry.source,
            target,
          )) {
            result.add(Violation(
              'feature_technical_seam_only',
              entry.source,
              entry.target,
            ));
          }
        } else if (target != featureFacade(targetFeature)) {
          result.add(Violation(
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
          result.add(Violation(
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
      result.add(Violation(
        'integration_feature_no_framework',
        entry.source,
        entry.target,
      ));
    }

    if (sourceFeature != null &&
        target != null &&
        target.startsWith('lib/app/')) {
      result.add(Violation('feature_no_app', entry.source, entry.target));
    }
    if (entry.source.startsWith('lib/core/') && targetFeature != null) {
      result.add(Violation('core_no_feature', entry.source, entry.target));
    }
    if (targetFeature != null &&
        sourceFeature != targetFeature &&
        !isPortPath(target!)) {
      result.add(
          Violation('feature_external_only_port', entry.source, entry.target));
    }
    if (target != null &&
        isCatalogInternal(target) &&
        sourceFeature != 'catalog') {
      result.add(Violation(
          'catalog_external_no_internal', entry.source, entry.target));
    }
    if (target != null &&
        isCatalogPort(target) &&
        sourceFeature != 'catalog' &&
        !isAllowedCatalogExternalPortImport(entry.source, target)) {
      result.add(Violation(
          'catalog_external_only_facade', entry.source, entry.target));
    }
    if (target != null &&
        entry.source.startsWith('lib/integration/') &&
        isCatalogPath(target) &&
        target != _catalogFacade) {
      result.add(Violation(
          'integration_catalog_only_facade', entry.source, entry.target));
    }
    if (target != null &&
        isMyWordInternal(target) &&
        sourceFeature != 'my_word') {
      result.add(Violation(
          'my_word_external_no_internal', entry.source, entry.target));
    }
    if (target != null &&
        isMyWordPort(target) &&
        sourceFeature != 'my_word' &&
        !isAllowedMyWordExternalPortImport(entry.source, target)) {
      result.add(Violation(
          'my_word_external_only_facade', entry.source, entry.target));
    }
    if (entry.source == _myWordFacade && target == _myWordComposition) {
      result.add(Violation(
          'my_word_external_only_facade', entry.source, entry.target));
    }
    if (target != null &&
        isQuizInternal(target) &&
        sourceFeature != 'quiz') {
      result.add(
          Violation('quiz_external_no_internal', entry.source, entry.target));
    }
    if (target != null &&
        isQuizPort(target) &&
        sourceFeature != 'quiz' &&
        !isAllowedQuizExternalPortImport(entry.source, target)) {
      result.add(
          Violation('quiz_external_only_facade', entry.source, entry.target));
    }
    if (target != null &&
        entry.source.startsWith('lib/integration/') &&
        isQuizPath(target) &&
        target != _quizFacade) {
      result.add(Violation(
          'integration_quiz_only_facade', entry.source, entry.target));
    }
    if (entry.source.startsWith('lib/integration/catalog_quiz/') &&
        (entry.target.startsWith('package:flutter/') ||
            entry.target.startsWith('package:flutter_riverpod/') ||
            entry.target.startsWith('package:drift/'))) {
      result.add(Violation('integration_quiz_no_framework_or_drift',
          entry.source, entry.target));
    }
    if (entry.source.startsWith('lib/features/catalog/internal/') &&
        (targetFeature == 'search' || targetFeature == 'quiz')) {
      result.add(Violation(
          'catalog_internal_no_search_quiz', entry.source, entry.target));
    }
    if (entry.source.startsWith('lib/features/catalog/port/') &&
        isFrameworkImport(entry.target) &&
        !isAllowedTechnicalBridgeFrameworkImport(entry.source, entry.target)) {
      result.add(Violation(
          'catalog_port_framework_only_bridges', entry.source, entry.target));
    }
    if (sourceFeature != null &&
        targetFeature != null &&
        sourceFeature != targetFeature &&
        target!.endsWith('/port/route.dart') &&
        entry.source.contains('/presentation/')) {
      result.add(Violation('feature_presentation_navigation_callback_only',
          entry.source, entry.target));
    }
    if (sourceFeature != null && entry.source.contains('/presentation/')) {
      if (entry.target.startsWith('package:go_router/') ||
          (target != null &&
              (target.startsWith('lib/app/routing/') ||
                  target.startsWith('lib/core/di/router') ||
                  target.startsWith('lib/router/')))) {
        result.add(Violation('feature_presentation_navigation_callback_only',
            entry.source, entry.target));
      }
    }
    if (sourceFeature != null &&
        target != null &&
        target.contains('/internal/') &&
        sourceFeature == targetFeature &&
        entry.source.contains('/port/')) {
      final isAllowedPresentationBridge =
          isPresentationEntry(entry.source) &&
              isInternalPresentation(target) &&
              (!strictFeatures.contains(sourceFeature) ||
                  isControlledPresentationTarget(target));
      final isAllowedCompositionBridge = isComposition(entry.source) &&
          isCanonicalCompositionFactoryBridge(entry.source, target);
      if (!isAllowedPresentationBridge && !isAllowedCompositionBridge) {
        result.add(Violation(
            isComposition(entry.source)
                ? 'composition_exact_facade'
                : 'presentation_entry_exact_facade',
            entry.source,
            entry.target));
      }
    }
    if ((isBusinessPort(entry.source) || isComposition(entry.source)) &&
        isFrameworkImport(entry.target) &&
        !isAllowedTechnicalBridgeFrameworkImport(entry.source, entry.target)) {
      result.add(Violation(
          isComposition(entry.source)
              ? 'composition_no_framework'
              : 'business_port_no_framework',
          entry.source,
          entry.target));
    }
    if (isFeatureBusinessImplementation(entry.source) &&
        isRiverpodImport(entry.target)) {
      result.add(
          Violation('business_port_no_framework', entry.source, entry.target));
    }
    if (isPresentationEntry(entry.source) &&
        isForbiddenPresentationFacadeImport(entry.target)) {
      result.add(Violation(
          'presentation_entry_exact_facade', entry.source, entry.target));
    }
    if (isFirebaseImport(entry.target) &&
        !isCanonicalFirebaseImport(entry.source)) {
      result.add(Violation('firebase_canonical_infrastructure_only',
          entry.source, entry.target));
    }
  }

  // An empty legacy layer cannot hide merely because it has no imports.
  for (final source in sources.keys) {
    if (RegExp(r'^lib/features/[^/]+/(application|data|domain|di|presentation)/')
            .hasMatch(source) &&
        !source.contains('/internal/')) {
      result.add(
          Violation('feature_top_level_only_port_internal', source, source));
    }
    if (isComposition(source) &&
        RegExp(
          r'\b(?:Provider|Ref|Override|ProviderContainer|ProviderListenable)\b',
        ).hasMatch(sources[source]!)) {
      result.add(Violation('composition_no_provider_types', source,
          'public signature/provider type'));
    }
    if (isComposition(source) &&
        RegExp(
          r'T\s+Function<T>\s*\(\s*(?:Object|dynamic)|\bas\s+T\b',
        ).hasMatch(sources[source]!)) {
      result.add(Violation('composition_no_provider_types', source,
          'opaque dependency resolver'));
    }
  }

  // A public port may re-export a local barrel.  Check its complete export
  // closure so a framework import cannot be hidden behind that barrel.
  for (final source in sources.keys.where((path) => path.contains('/port/'))) {
    final seen = <String>{};
    final packages = <String>{};
    void visit(String current) {
      if (!seen.add(current)) return;
      for (final entry in bySource[current] ?? const <ImportEntry>[]) {
        if (entry.target.startsWith('package:') &&
            isFrameworkImport(entry.target)) {
          packages.add(entry.target);
        }
        // Composition is a public factory facade.  Its implementation factory
        // is allowed to depend on framework infrastructure; only the facade
        // itself (and port-local barrels it exposes) must remain pure.
        final mayFollowPublicBarrel = !isComposition(source) ||
            (entry.localTarget != null &&
                entry.localTarget!.contains('/port/'));
        if (entry.localTarget != null && mayFollowPublicBarrel) {
          visit(entry.localTarget!);
        }
      }
    }

    visit(source);
    if (isCatalogPort(source)) {
      for (final package in packages) {
        if (!isAllowedTechnicalBridgeFrameworkImport(source, package)) {
          result.add(Violation(
              'catalog_port_framework_only_bridges', source, package));
        }
      }
    }
    if (isBusinessPort(source) || isComposition(source)) {
      for (final package in packages) {
        if (isAllowedTechnicalBridgeFrameworkImport(source, package)) continue;
        result.add(Violation(
            isComposition(source)
                ? 'composition_no_framework'
                : 'business_port_no_framework',
            source,
            package));
      }
    }
  }
  return result;
}

bool isPortPath(String path) => path.contains('/port/');
String featureFacade(String feature) =>
    'lib/features/$feature/port/$feature.dart';
Set<String> strictFacadeFeatures(Iterable<String> paths) {
  final sources = paths.toSet();
  final features = sources.map(featureOf).whereType<String>().toSet();
  return features
      .where((feature) => sources.contains(featureFacade(feature)))
      .toSet();
}

bool isTechnicalSeam(String path) =>
    isComposition(path) ||
    isPresentationDependencies(path) ||
    isPresentationEntry(path) ||
    isSyncDatasetContract(path);
bool isSyncDatasetContract(String path) =>
    path == 'lib/features/sync/port/dataset_contract.dart';
bool isIntegrationWiring(String source) =>
    source.startsWith('lib/integration/') &&
    (source.endsWith('_providers.dart') ||
        source.endsWith('_composition.dart'));
bool isAllowedTechnicalSeamCaller(
  String source,
  String target,
) {
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

/// The Sync dataset SPI is not a second business facade.  It is available only
/// to dataset-owner assembly/implementation code and the technical runtime
/// roots which register or execute those completed implementations. An
/// app/infrastructure external-system executor is also a technical runtime
/// root; app business and presentation remain outside this boundary.
bool isAllowedSyncDatasetContractCaller(String source) {
  if (source.startsWith('lib/app/bootstrap/')) return true;
  if (source.startsWith('lib/app/infrastructure/')) return true;
  if (source.startsWith('lib/integration/sync/')) return true;
  return RegExp(
    r'^lib/features/[^/]+/(?:port/composition\.dart|internal/(?:composition|infrastructure)/)',
  ).hasMatch(source);
}

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
bool isCatalogPath(String path) => path.startsWith('lib/features/catalog/');
bool isCatalogInternal(String path) =>
    path.startsWith('lib/features/catalog/internal/');
bool isCatalogPort(String path) =>
    path.startsWith('lib/features/catalog/port/');
bool isMyWordInternal(String path) =>
    path.startsWith('lib/features/my_word/internal/');
bool isMyWordPort(String path) => path.startsWith('lib/features/my_word/port/');
bool isQuizPath(String path) => path.startsWith('lib/features/quiz/');
bool isQuizInternal(String path) =>
    path.startsWith('lib/features/quiz/internal/');
bool isQuizPort(String path) => path.startsWith('lib/features/quiz/port/');
bool isQuizFrameworkBridge(String source) =>
    source == _quizPresentationDependencies;
bool isAllowedQuizBridgeFrameworkImport(String source, String target) =>
    isQuizFrameworkBridge(source) &&
    target.startsWith('package:flutter_riverpod/');
bool isAllowedTechnicalBridgeFrameworkImport(String source, String target) =>
    (isPresentationDependencies(source) &&
        target.startsWith('package:flutter_riverpod/')) ||
    isAllowedQuizBridgeFrameworkImport(source, target);
bool isCanonicalCompositionFactoryBridge(String source, String target) {
  final feature = featureOf(source);
  return feature != null &&
      source == 'lib/features/$feature/port/composition.dart' &&
      target ==
          'lib/features/$feature/internal/composition/${feature}_composition_factory.dart';
}

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

bool isBusinessPort(String path) =>
    path.contains('/port/') &&
    !isPresentationEntry(path) &&
    !isPresentationDependencies(path) &&
    !isComposition(path);
bool isComposition(String path) => path.endsWith('/port/composition.dart');
bool isPresentationDependencies(String path) =>
    path.endsWith('/port/presentation_dependencies.dart');
bool isPresentationEntry(String path) =>
    path.endsWith('/port/presentation_entry.dart');
bool isInternalPresentation(String path) =>
    path.contains('/internal/') && path.contains('/presentation/');
bool isControlledPresentationTarget(String path) =>
    path.contains('/presentation/view/') || path.endsWith('/presentation/view.dart');
bool isFrameworkImport(String target) =>
    _frameworkPackages.any((package) => target.startsWith('package:$package/'));
bool isRiverpodImport(String target) =>
    target.startsWith('package:flutter_riverpod/') ||
    target.startsWith('package:riverpod/');
bool isFeatureBusinessImplementation(String source) => RegExp(
      r'^lib/features/[^/]+/internal/(?:domain|application|infrastructure)/',
    ).hasMatch(source);
bool isFirebaseImport(String target) => const {
      'firebase_core',
      'firebase_auth',
      'cloud_firestore'
    }.any((package) => target.startsWith('package:$package/'));
bool isForbiddenPresentationFacadeImport(String target) =>
    // A presentation entry is the controlled Flutter/Riverpod boundary.
    // Other provider packages and infrastructure frameworks remain private.
    target.startsWith('package:provider/') ||
    target.startsWith('package:drift/') ||
    isFirebaseImport(target) ||
    target.startsWith('package:go_router/');
bool isCanonicalFirebaseImport(String source) =>
    source == 'lib/app/bootstrap/bootstrap.dart' ||
    source == 'lib/app/bootstrap/firebase_options.dart' ||
    source == 'lib/app/bootstrap/firebase_providers.dart' ||
    source.startsWith('lib/app/infrastructure/firebase/') ||
    source.startsWith('lib/core/infrastructure/firebase/') ||
    RegExp(r'^lib/features/[^/]+/internal/infrastructure/(?:.*/)?firebase/')
        .hasMatch(source);

List<Violation> findFeatureCycles(List<ImportEntry> imports) {
  final graph = <String, Set<String>>{};
  for (final entry in imports) {
    final source = featureOf(entry.source),
        target =
            entry.localTarget == null ? null : featureOf(entry.localTarget!);
    if (source != null && target != null && source != target) {
      (graph[source] ??= {}).add(target);
    }
  }
  final result = <Violation>[];
  for (final source in graph.keys) {
    for (final target in graph[source]!) {
      if (reachable(graph, target, source, {})) {
        result.add(Violation(
            'no_feature_cycle', 'feature:$source', 'feature:$target'));
      }
    }
  }
  return result;
}

bool reachable(Map<String, Set<String>> graph, String current, String goal,
        Set<String> seen) =>
    current == goal ||
    (seen.add(current) &&
        (graph[current] ?? const <String>{})
            .any((next) => reachable(graph, next, goal, seen)));

/// Extract every URI from import/export/part directives.  In particular this
/// deliberately includes every conditional branch, rather than only the first
/// URI of `import 'a.dart' if (dart.library.io) 'b.dart'`.
Iterable<String> dartImports(String source) =>
    RegExp(r'''(?:import|export|part)\s+[^;]*;''', multiLine: true)
        .allMatches(source)
        .expand((directive) => RegExp(r'''['"]([^'"]+)['"]''')
            .allMatches(directive.group(0)!)
            .map((uri) => uri.group(1)!));
String normalize(String value) => value
    .replaceAll('\\', '/')
    .replaceAll(RegExp(r'/+'), '/')
    .replaceFirst(RegExp(r'^\./'), '');
String relative(String root, String path) => normalize(path)
    .replaceFirst(RegExp('^${RegExp.escape(normalize(root))}/?'), '');
String dirname(String path) => path.substring(0, path.lastIndexOf('/') + 1);
String join(String base, String path) {
  final parts = <String>[];
  for (final part in '$base/$path'.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(part);
    }
  }
  return parts.join('/');
}

String? featureOf(String path) =>
    RegExp(r'^lib/features/([^/]+)/').firstMatch(path)?.group(1);
String sourceForRuleMatching(String source) {
  if (!source.startsWith('test/')) return source;
  final match = RegExp(r'^test/(?:.*?/)?(app|core|features|router)/(.+)$')
      .firstMatch(source);
  return match == null ? source : 'lib/${match.group(1)}/${match.group(2)}';
}

String key(Violation v) => '${v.ruleId}|${v.source}|${v.target}';
String keyJson(Map<String, dynamic> value) =>
    '${value['ruleId']}|${value['source']}|${value['target']}';
bool matches(String path, String pattern) => expandBraces(pattern)
    .any((glob) => RegExp('^${globRegExp(glob)}\$').hasMatch(path));
List<String> expandBraces(String pattern) {
  final match = RegExp(r'\{([^{}]+)\}').firstMatch(pattern);
  return match == null
      ? [pattern]
      : match
          .group(1)!
          .split(',')
          .expand((choice) => expandBraces(
              pattern.replaceRange(match.start, match.end, choice)))
          .toList();
}

String globRegExp(String glob) {
  final result = StringBuffer();
  for (var i = 0; i < glob.length; i++) {
    if (glob[i] != '*') {
      result.write(RegExp.escape(glob[i]));
      continue;
    }
    if (i + 1 < glob.length && glob[i + 1] == '*') {
      i++;
      if (i + 1 < glob.length && glob[i + 1] == '/') {
        i++;
        result.write('(?:.*/)?');
      } else {
        result.write('.*');
      }
    } else {
      result.write('[^/]*');
    }
  }
  return result.toString();
}

void printReport(Report report) {
  final reported = report.added.isEmpty && report.removed.isEmpty
      ? report.violations
      : report.added;
  for (final v in reported) {
    stdout.writeln('${v.ruleId}: ${v.source} -> ${v.target}');
  }
  for (final v in report.removed) {
    stdout.writeln(
        'removed baseline violation: ${v.ruleId}: ${v.source} -> ${v.target}');
  }
  if (report.violations.isEmpty) {
    stdout.writeln('No import-boundary violations found.');
  }
}
