import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_dataset.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/repository/drift_esp_jpn_dictionary_repository.dart';

void main() {
  group('Catalog Drift repositories', () {
    test('Esp-Jpn empty result preserves the NotFoundError contract', () async {
      final result = await EspJpnDictionaryRepository(_DictionaryDataSource())
          .getDictionaryByWordId(42);

      expect(result.errorOrNull, isA<NotFoundError>());
    });

    test('database failure preserves the original error identity', () async {
      final cause = StateError('database unavailable');
      final result = await EspJpnDictionaryRepository(
        _DictionaryDataSource(error: cause),
      ).getDictionaryByWordId(42);

      expect(result.errorOrNull, isA<DatabaseError>());
      expect(result.errorOrNull!.originalError, same(cause));
    });
  });
}

final class _DictionaryDataSource implements EspJpnDictionaryDataSource {
  _DictionaryDataSource({this.error});
  final Object? error;

  @override
  Future<List<EspJpnDictionaryDataSet>> getDictionaryByWordId(
      int wordId) async {
    if (error case final error?) throw error;
    return [];
  }
}
