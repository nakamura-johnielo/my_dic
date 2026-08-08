import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';

/// Immutable, direction-specific dictionary content for a Catalog word.
sealed class CatalogEntryDetail {
  const CatalogEntryDetail(this.word);

  final CatalogWordRef word;
}

/// Dictionary detail supplied by the Spanish-to-Japanese Catalog.
final class EspJpnEntryDetail extends CatalogEntryDetail {
  EspJpnEntryDetail({
    required CatalogWordRef word,
    required List<EspJpnEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<EspJpnEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EspJpnEntryDetail &&
          word == other.word &&
          _listEquals(entries, other.entries);

  @override
  int get hashCode => Object.hash(word, Object.hashAll(entries));
}

/// Dictionary detail supplied by the Japanese-to-Spanish Catalog.
final class JpnEspEntryDetail extends CatalogEntryDetail {
  JpnEspEntryDetail({
    required CatalogWordRef word,
    required List<JpnEspEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<JpnEspEntry> entries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JpnEspEntryDetail &&
          word == other.word &&
          _listEquals(entries, other.entries);

  @override
  int get hashCode => Object.hash(word, Object.hashAll(entries));
}

bool _listEquals<T>(List<T> first, List<T> second) {
  if (identical(first, second)) return true;
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
