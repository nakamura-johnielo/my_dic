import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_state.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

final class WordDetailViewModel extends StateNotifier<WordDetailState> {
  WordDetailViewModel(this._reader) : super(const WordDetailState());

  final WordDetailReaderPort _reader;
  final _logger = Logger('WordDetailViewModel');

  Future<void>? _initialization;
  var _generation = 0;

  /// Starts the single request owned by this provider instance.
  Future<void> initialize(WordDetailLoadKey key) =>
      _initialization ??= _load(key, ++_generation);

  Future<void> _load(WordDetailLoadKey key, int generation) async {
    final previous = state.detail.dataOrNull;
    _setState(
        generation,
        state.copyWith(
          detail: QueryState.loading(previousData: previous),
        ));

    final result = await _reader.read(WordDetailQuery(
      word: key.word,
    ));
    if (!_isCurrent(generation)) return;

    switch (result) {
      case Success<WordDetailResult>(data: final result):
        final warnings = result.issues
            .map(
              (issue) => QueryWarning(
                source: switch (issue) {
                  WordDetailConjugationIssue() => 'conjugation',
                },
                error: issue.error,
              ),
            )
            .toList(growable: false);
        _setState(
            generation,
            state.copyWith(
              detail: result.data.isEmpty
                  ? QueryState.empty(warnings: warnings)
                  : QueryState.data(result.data, warnings: warnings),
            ));
      case Failure<WordDetailResult>(error: final error):
        _logger.warning('Failed to load word detail', error);
        _setState(
            generation,
            state.copyWith(
              detail: QueryState.failure(error, previousData: previous),
            ));
    }
  }

  bool _isCurrent(int generation) => mounted && generation == _generation;

  void _setState(int generation, WordDetailState next) {
    if (_isCurrent(generation)) state = next;
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
