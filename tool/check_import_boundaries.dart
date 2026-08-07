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
    for (final sourceRoot in const ['lib', 'test']) {
      final directory = Directory('$root${Platform.pathSeparator}$sourceRoot');
      if (!await directory.exists()) continue;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = relative(root, entity.path);
        if (isExcluded(source)) continue;
        for (final target in dartImports(await entity.readAsString())) {
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
    final sourceFeature = featureOf(entry.source);
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
  Baseline(this.records);
  final Map<String, Map<String, dynamic>> records;
  static Future<Baseline> read(String path) async {
    final file = File(path);
    if (!await file.exists()) return Baseline({});
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final entries =
        (json['violations'] as List? ?? const []).cast<Map<String, dynamic>>();
    return Baseline({for (final entry in entries) keyJson(entry): entry});
  }

  static Future<void> write(String path, List<Violation> violations,
      {required Baseline previous}) async {
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
Iterable<String> dartImports(String source) =>
    RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''')
        .allMatches(source)
        .map((m) => m.group(1)!);
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
