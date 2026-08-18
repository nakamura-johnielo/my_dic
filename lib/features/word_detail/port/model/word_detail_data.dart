import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/word_detail/port/model/word_detail_conjugation.dart';
import 'package:my_dic/features/word_detail/port/model/word_detail_entry.dart';

/// Required primary detail returned by [WordDetailCatalogGateway].
sealed class WordDetailDictionary {
  const WordDetailDictionary(this.word);

  final CatalogWordRef word;
}

final class EspJpnWordDetailDictionary extends WordDetailDictionary {
  EspJpnWordDetailDictionary({
    required CatalogWordRef word,
    required Iterable<WordDetailEspJpnEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<WordDetailEspJpnEntry> entries;
}

final class JpnEspWordDetailDictionary extends WordDetailDictionary {
  JpnEspWordDetailDictionary({
    required CatalogWordRef word,
    required Iterable<WordDetailJpnEspEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<WordDetailJpnEspEntry> entries;
}

/// Complete direction-specific projection produced by WordDetail application.
sealed class WordDetailData {
  const WordDetailData(this.word);

  final CatalogWordRef word;
  bool get isEmpty;
}

final class EspJpnWordDetailData extends WordDetailData {
  EspJpnWordDetailData({
    required CatalogWordRef word,
    required Iterable<WordDetailEspJpnEntry> entries,
    this.conjugation,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<WordDetailEspJpnEntry> entries;
  final WordDetailConjugation? conjugation;

  @override
  bool get isEmpty => entries.isEmpty;
}

final class JpnEspWordDetailData extends WordDetailData {
  JpnEspWordDetailData({
    required CatalogWordRef word,
    required Iterable<WordDetailJpnEspEntry> entries,
  })  : entries = List.unmodifiable(entries),
        super(word);

  final List<WordDetailJpnEspEntry> entries;

  @override
  bool get isEmpty => entries.isEmpty;
}
