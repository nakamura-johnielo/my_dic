import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

/// Labels used exclusively by the word-detail presentation.
///
/// Catalog models deliberately expose stable enum values rather than UI text.
extension CatalogMoodTenseLabels on CatalogMoodTense {
  String get moodName => switch (this) {
        CatalogMoodTense.participlePresent ||
        CatalogMoodTense.participlePast =>
          '分詞',
        CatalogMoodTense.indicativePresent ||
        CatalogMoodTense.indicativePreterite ||
        CatalogMoodTense.indicativeImperfect ||
        CatalogMoodTense.indicativeFuture ||
        CatalogMoodTense.indicativeConditional =>
          '直説法',
        CatalogMoodTense.imperative => '命令法',
        CatalogMoodTense.subjunctivePresent ||
        CatalogMoodTense.subjunctivePast =>
          '接続法',
      };

  String get tenseName => switch (this) {
        CatalogMoodTense.participlePresent => '現在',
        CatalogMoodTense.participlePast => '過去',
        CatalogMoodTense.indicativePresent ||
        CatalogMoodTense.subjunctivePresent =>
          '現在',
        CatalogMoodTense.indicativePreterite => '点過去',
        CatalogMoodTense.indicativeImperfect => '線過去',
        CatalogMoodTense.indicativeFuture => '未来',
        CatalogMoodTense.indicativeConditional => '過去未来',
        CatalogMoodTense.imperative => '',
        CatalogMoodTense.subjunctivePast => '過去',
      };

  String get label => switch (this) {
        CatalogMoodTense.participlePresent => '現在分詞',
        CatalogMoodTense.participlePast => '過去分詞',
        _ => '【$moodName】 $tenseName',
      };
}

extension CatalogSubjectLabels on CatalogSubject {
  String get displayEsp => switch (this) {
        CatalogSubject.yo => 'Yo',
        CatalogSubject.tu => 'Tú',
        CatalogSubject.el => 'Él/Ella/Usted',
        CatalogSubject.nosotros => 'Nosotr@s',
        CatalogSubject.vosotros => 'Vosotr@s',
        CatalogSubject.ellos => 'Ell@s/Ustedes',
      };
}

const catalogSubjectOrder = <CatalogSubject>[
  CatalogSubject.yo,
  CatalogSubject.tu,
  CatalogSubject.el,
  CatalogSubject.nosotros,
  CatalogSubject.vosotros,
  CatalogSubject.ellos,
];
