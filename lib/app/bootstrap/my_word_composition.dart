import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/sync_infrastructure_providers.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/my_word/port/composition.dart';

/// App-owned Riverpod lifetime around MyWord's framework-free factory.
final myWordPortsProvider = Provider<MyWordPorts>(
  (ref) => createMyWordPorts(_myWordDependencyReader(ref)),
);

MyWordDependencyReader _myWordDependencyReader(Ref ref) =>
    <T>(MyWordDependency dependency) {
      switch (dependency) {
        case MyWordDependency.database:
          return ref.watch(databaseProvider) as T;
        case MyWordDependency.outboxWriter:
          return ref.watch(driftOutboxWriterProvider) as T;
      }
    };
