import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/catalog/port/composition.dart';

final catalogReadPortsProvider = Provider<CatalogReadPorts>((ref) {
  return createCatalogComposition(
    dependencies: CatalogDependencies(
      database: ref.watch(databaseProvider),
    ),
  );
});
