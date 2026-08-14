import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/catalog/port/composition.dart';

final catalogReadPortsProvider = Provider<CatalogQueryPorts>((ref) {
  return createCatalogComposition(
    dependencies: CatalogDependencies(
      database: ref.watch(databaseProvider),
    ),
  );
});
