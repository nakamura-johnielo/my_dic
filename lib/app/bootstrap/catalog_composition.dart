import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/repository_di.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_catalog_reader_adapter.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/legacy/legacy_conjugation_reader_adapter.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';

/// Composes Catalog's public read ports from the existing legacy repositories.
final catalogReaderProvider = Provider<CatalogReader>((ref) {
  return LegacyCatalogReaderAdapter(
    espJpnRepository: ref.read(esjDictionaryRepositoryProvider),
    jpnEspRepository: ref.read(jpnEspDictionaryRepositoryProvider),
  );
});

/// Composes Catalog's public conjugation port from the legacy repository.
final conjugationReaderProvider = Provider<ConjugationReader>((ref) {
  return LegacyConjugationReaderAdapter(
    ref.read(conjugacionsRepositoryProvider),
  );
});
