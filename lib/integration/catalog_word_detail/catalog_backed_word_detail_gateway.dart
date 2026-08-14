import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// Pure value/error adapter from Catalog's public semantic readers.
final class CatalogBackedWordDetailGateway
    implements WordDetailCatalogGateway {
  const CatalogBackedWordDetailGateway(this._catalog);

  final CatalogReadPorts _catalog;

  @override
  Future<Result<WordDetailDictionary>> readDictionary(
    CatalogWordRef word,
  ) async {
    try {
      final result =
          await _catalog.semanticEntryDetail.readSemanticEntryDetail(word);
      if (result case Success<CatalogSemanticEntryDetail>(data: final detail)) {
        try {
          return Result.success(_dictionary(detail));
        } catch (error, stackTrace) {
          return Result.failure(
            WordDetailDataCorruptedError(
              originalError: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }
      return Result.failure(_readError(result.errorOrNull!, word));
    } catch (error, stackTrace) {
      return Result.failure(
        WordDetailUnexpectedReadError(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<WordDetailConjugation?>> readConjugation(
    CatalogWordRef word,
  ) async {
    try {
      final result = await _catalog.conjugation.readConjugation(word);
      if (result case Success<CatalogConjugation?>(data: final conjugation)) {
        try {
          return Result.success(
            conjugation == null ? null : _conjugation(conjugation),
          );
        } catch (error, stackTrace) {
          return Result.failure(
            WordDetailDataCorruptedError(
              originalError: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }
      return Result.failure(_readError(result.errorOrNull!, word));
    } catch (error, stackTrace) {
      return Result.failure(
        WordDetailUnexpectedReadError(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

WordDetailDictionary _dictionary(CatalogSemanticEntryDetail detail) =>
    switch (detail) {
      CatalogSemanticEspJpnEntryDetail(
        :final word,
        :final espJpnEntries,
      ) =>
        EspJpnWordDetailDictionary(
          word: word,
          entries: espJpnEntries.map(_espJpnEntry),
        ),
      CatalogSemanticJpnEspEntryDetail(
        :final word,
        :final jpnEspEntries,
      ) =>
        JpnEspWordDetailDictionary(
          word: word,
          entries: jpnEspEntries.map(_jpnEspEntry),
        ),
    };

WordDetailEspJpnEntry _espJpnEntry(CatalogSemanticEspJpnEntry entry) =>
    WordDetailEspJpnEntry(
      dictionaryId: entry.dictionaryId,
      word: entry.word,
      headword: _content(entry.headword),
      content: _content(entry.content),
      origin: entry.origin == null ? null : _content(entry.origin!),
      examples: entry.examples.map(
        (example) => WordDetailEspJpnExample(
          exampleId: example.exampleId,
          espanol: example.espanol,
          japanese: example.japanese,
        ),
      ),
      idioms: entry.idioms.map(
        (idiom) => WordDetailIdiom(
          idiomId: idiom.idiomId,
          idiom: idiom.idiom,
          description: _content(idiom.description),
        ),
      ),
      supplements: entry.supplements.map(
        (supplement) => WordDetailSupplement(
          supplementId: supplement.supplementId,
          content: _content(supplement.content),
        ),
      ),
    );

WordDetailJpnEspEntry _jpnEspEntry(CatalogSemanticJpnEspEntry entry) =>
    WordDetailJpnEspEntry(
      dictionaryId: entry.dictionaryId,
      wordId: entry.wordId,
      word: entry.word,
      headword: _content(entry.headword),
      content: _content(entry.content),
      examples: entry.examples.map(
        (example) => WordDetailJpnEspExample(
          exampleId: example.exampleId,
          japanese: example.japanese,
          espanol: example.espanol,
          espanolContent: _content(example.espanolContent),
        ),
      ),
    );

WordDetailContent _content(CatalogSemanticContent content) =>
    WordDetailContent(content.nodes.map(_contentBlock));

WordDetailContentBlock _contentBlock(CatalogContentNode node) => switch (node) {
      CatalogContentText(:final text) => WordDetailTextBlock(text),
      CatalogContentGroup(:final kind, :final roles, :final children) =>
        WordDetailGroupBlock(
          kind: _groupKind(kind),
          roles: roles.map(_contentRole),
          children: children.map(_contentBlock),
        ),
      CatalogContentLineBreak() => const WordDetailLineBreakBlock(),
      CatalogContentLink(:final target, :final children) =>
        WordDetailLinkBlock(
          target: target,
          children: children.map(_contentBlock),
        ),
      CatalogContentImage(:final source, :final description) =>
        WordDetailImageBlock(source: source, description: description),
    };

WordDetailContentGroupKind _groupKind(CatalogContentGroupKind kind) =>
    switch (kind) {
      CatalogContentGroupKind.section => WordDetailContentGroupKind.section,
      CatalogContentGroupKind.paragraph =>
        WordDetailContentGroupKind.paragraph,
      CatalogContentGroupKind.inline => WordDetailContentGroupKind.inline,
      CatalogContentGroupKind.strong => WordDetailContentGroupKind.strong,
      CatalogContentGroupKind.italic => WordDetailContentGroupKind.italic,
      CatalogContentGroupKind.emphasis => WordDetailContentGroupKind.emphasis,
      CatalogContentGroupKind.small => WordDetailContentGroupKind.small,
      CatalogContentGroupKind.superscript =>
        WordDetailContentGroupKind.superscript,
      CatalogContentGroupKind.subscript => WordDetailContentGroupKind.subscript,
    };

WordDetailContentRole _contentRole(CatalogContentRole role) => switch (role) {
      CatalogContentRole.meaning => WordDetailContentRole.meaning,
      CatalogContentRole.example => WordDetailContentRole.example,
      CatalogContentRole.subhead => WordDetailContentRole.subhead,
      CatalogContentRole.subheadword => WordDetailContentRole.subheadword,
      CatalogContentRole.partOfSpeech => WordDetailContentRole.partOfSpeech,
      CatalogContentRole.reflexive => WordDetailContentRole.reflexive,
      CatalogContentRole.idiom => WordDetailContentRole.idiom,
      CatalogContentRole.origin => WordDetailContentRole.origin,
      CatalogContentRole.supplement => WordDetailContentRole.supplement,
      CatalogContentRole.synonym => WordDetailContentRole.synonym,
      CatalogContentRole.related => WordDetailContentRole.related,
      CatalogContentRole.compound => WordDetailContentRole.compound,
      CatalogContentRole.derivative => WordDetailContentRole.derivative,
      CatalogContentRole.usage => WordDetailContentRole.usage,
      CatalogContentRole.proverb => WordDetailContentRole.proverb,
      CatalogContentRole.column => WordDetailContentRole.column,
      CatalogContentRole.title => WordDetailContentRole.title,
      CatalogContentRole.middleHeading => WordDetailContentRole.middleHeading,
      CatalogContentRole.reference => WordDetailContentRole.reference,
      CatalogContentRole.grammarLabel => WordDetailContentRole.grammarLabel,
    };

WordDetailConjugation _conjugation(CatalogConjugation conjugation) =>
    WordDetailConjugation(
      word: conjugation.word,
      conjugations: conjugation.conjugations.map(
        (moodTense, value) => MapEntry(
          _moodTense(moodTense),
          WordDetailTenseConjugation(
            forms: value.forms.map(
              (subject, form) => MapEntry(_subject(subject), form),
            ),
          ),
        ),
      ),
      participles: WordDetailParticiples(
        present: conjugation.participles.present,
        past: conjugation.participles.past,
      ),
    );

WordDetailMoodTense _moodTense(CatalogMoodTense value) => switch (value) {
      CatalogMoodTense.participlePresent =>
        WordDetailMoodTense.participlePresent,
      CatalogMoodTense.participlePast => WordDetailMoodTense.participlePast,
      CatalogMoodTense.indicativePresent =>
        WordDetailMoodTense.indicativePresent,
      CatalogMoodTense.indicativePreterite =>
        WordDetailMoodTense.indicativePreterite,
      CatalogMoodTense.indicativeImperfect =>
        WordDetailMoodTense.indicativeImperfect,
      CatalogMoodTense.indicativeFuture =>
        WordDetailMoodTense.indicativeFuture,
      CatalogMoodTense.indicativeConditional =>
        WordDetailMoodTense.indicativeConditional,
      CatalogMoodTense.imperative => WordDetailMoodTense.imperative,
      CatalogMoodTense.subjunctivePresent =>
        WordDetailMoodTense.subjunctivePresent,
      CatalogMoodTense.subjunctivePast =>
        WordDetailMoodTense.subjunctivePast,
    };

WordDetailSubject _subject(CatalogSubject value) => switch (value) {
      CatalogSubject.yo => WordDetailSubject.yo,
      CatalogSubject.tu => WordDetailSubject.tu,
      CatalogSubject.el => WordDetailSubject.el,
      CatalogSubject.nosotros => WordDetailSubject.nosotros,
      CatalogSubject.vosotros => WordDetailSubject.vosotros,
      CatalogSubject.ellos => WordDetailSubject.ellos,
    };

WordDetailReadError _readError(Object error, CatalogWordRef requestedWord) =>
    switch (error) {
      CatalogEntryNotFoundError() => WordDetailNotFoundError(
          word: requestedWord,
          message: error.message,
          originalError: error.originalError ?? error,
          stackTrace: error.stackTrace,
        ),
      CatalogDataUnavailableError() => WordDetailDataUnavailableError(
          message: error.message,
          originalError: error.originalError ?? error,
          stackTrace: error.stackTrace,
        ),
      CatalogDataCorruptedError() => WordDetailDataCorruptedError(
          message: error.message,
          originalError: error.originalError ?? error,
          stackTrace: error.stackTrace,
        ),
      CatalogUnexpectedReadError() => WordDetailUnexpectedReadError(
          message: error.message,
          originalError: error.originalError ?? error,
          stackTrace: error.stackTrace,
        ),
      _ => WordDetailUnexpectedReadError(originalError: error),
    };
