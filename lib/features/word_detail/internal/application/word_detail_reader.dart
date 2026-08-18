import 'package:my_dic/features/word_detail/port/word_detail.dart';

/// WordDetail-owned orchestration of primary dictionary and optional detail.
final class WordDetailApplicationService implements WordDetailQueryPort {
  const WordDetailApplicationService(this._catalog);

  final WordDetailCatalogGateway _catalog;

  @override
  Future<Result<WordDetailResult>> read(WordDetailQuery query) async {
    try {
      final dictionaryResult = await _catalog.readDictionary(query.word);
      if (dictionaryResult case Failure<WordDetailDictionary>(:final error)) {
        return Result.failure(_readError(error));
      }

      final dictionary = dictionaryResult.dataOrNull!;
      if (dictionary.word != query.word) {
        return Result.failure(
          WordDetailContractMismatchError(
            kind: WordDetailContractMismatchKind.identity,
            requestedWord: query.word,
            actualWord: dictionary.word,
          ),
        );
      }

      return switch (dictionary) {
        EspJpnWordDetailDictionary() => _readEspJpn(query, dictionary),
        JpnEspWordDetailDictionary() => _readJpnEsp(query, dictionary),
      };
    } catch (error, stackTrace) {
      return Result.failure(
        WordDetailUnexpectedReadError(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<WordDetailResult>> _readEspJpn(
    WordDetailQuery query,
    EspJpnWordDetailDictionary dictionary,
  ) async {
    if (query.word.catalogId != CatalogId.espJpnMain) {
      return Result.failure(_directionMismatch(query));
    }

    try {
      final conjugationResult = await _catalog.readConjugation(query.word);
      if (conjugationResult
          case Failure<WordDetailConjugation?>(:final error)) {
        return Result.success(
          WordDetailResult(
            data: EspJpnWordDetailData(
              word: query.word,
              entries: dictionary.entries,
            ),
            issues: [WordDetailConjugationIssue(error: _readError(error))],
          ),
        );
      }

      final conjugation = conjugationResult.dataOrNull;
      if (conjugation != null && conjugation.word != query.word) {
        return Result.failure(
          WordDetailContractMismatchError(
            kind: WordDetailContractMismatchKind.identity,
            requestedWord: query.word,
            actualWord: conjugation.word,
          ),
        );
      }

      return Result.success(
        WordDetailResult(
          data: EspJpnWordDetailData(
            word: query.word,
            entries: dictionary.entries,
            conjugation: conjugation,
          ),
        ),
      );
    } catch (error, stackTrace) {
      return Result.success(
        WordDetailResult(
          data: EspJpnWordDetailData(
            word: query.word,
            entries: dictionary.entries,
          ),
          issues: [
            WordDetailConjugationIssue(
              error: WordDetailUnexpectedReadError(
                originalError: error,
                stackTrace: stackTrace,
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<Result<WordDetailResult>> _readJpnEsp(
    WordDetailQuery query,
    JpnEspWordDetailDictionary dictionary,
  ) async {
    if (query.word.catalogId != CatalogId.jpnEspMain) {
      return Result.failure(_directionMismatch(query));
    }
    return Result.success(
      WordDetailResult(
        data: JpnEspWordDetailData(
          word: query.word,
          entries: dictionary.entries,
        ),
      ),
    );
  }
}

WordDetailReadError _readError(Object error) => switch (error) {
      WordDetailReadError() => error,
      _ => WordDetailUnexpectedReadError(originalError: error),
    };

WordDetailContractMismatchError _directionMismatch(WordDetailQuery query) =>
    WordDetailContractMismatchError(
      kind: WordDetailContractMismatchKind.direction,
      requestedWord: query.word,
      actualWord: query.word,
    );
