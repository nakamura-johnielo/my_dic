import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/port/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';

class WordDetailViewModel extends StateNotifier<WordDetailState> {
  WordDetailViewModel(this._loadWordDetailQuery)
      : super(const WordDetailState());

  final ILoadWordDetailQuery _loadWordDetailQuery;
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

    final result = await _loadWordDetailQuery.execute(WordDetailQuery(
      word: key.word,
    ));
    if (!_isCurrent(generation)) return;

    result.when(
      success: (result) {
        final warnings = result.issue == null
            ? const <QueryWarning>[]
            : [
                QueryWarning(
                    source: result.issue!.source, error: result.issue!.error)
              ];
        _setState(
            generation,
            state.copyWith(
              detail: _isEmpty(result.viewData)
                  ? QueryState.empty(warnings: warnings)
                  : QueryState.data(result.viewData, warnings: warnings),
            ));
      },
      failure: (error) {
        _logger.warning('Failed to load word detail', error);
        _setState(
            generation,
            state.copyWith(
              detail: QueryState.failure(error, previousData: previous),
            ));
      },
    );
  }

  bool _isEmpty(WordDetailViewData data) => switch (data) {
        EspJpnWordDetailViewData(entries: final entries) => entries.isEmpty,
        JpnEspWordDetailViewData(entries: final entries) => entries.isEmpty,
      };

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
