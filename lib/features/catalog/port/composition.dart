import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/composition/catalog_composition_factory.dart';
import 'package:my_dic/features/catalog/port/catalog_read_ports.dart';

/// Catalog 機能を組み立てるために必要な、アプリ所有のサービス。
final class CatalogDependencies {
  const CatalogDependencies({required this.database});

  final DatabaseProvider database;
}

/// フレームワークの状態なしで Catalog の公開読み取り機能を組み立てる。
CatalogQueryPorts createCatalogComposition({
  required CatalogDependencies dependencies,
}) =>
    createInternalCatalogComposition(database: dependencies.database);
