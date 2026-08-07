import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/word_page/application/query/i_load_word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_query.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/jpn_esp_state.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';

class WordPageViewModel extends StateNotifier<WordPageState> {
  WordPageViewModel(this._loadWordDetailQuery) : super(const WordPageState());

  final ILoadWordDetailQuery _loadWordDetailQuery;
  final _logger = Logger('WordPageViewModel');

  Future<void>? _initialization;
  var _generation = 0;

  /// Starts the single request owned by this provider instance.
  Future<void> initialize(WordPageLoadKey key) =>
      _initialization ??= _load(key, ++_generation);

  Future<void> _load(WordPageLoadKey key, int generation) async {
    final previous = state.detail.dataOrNull;
    _setState(
        generation,
        state.copyWith(
          detail: QueryState.loading(previousData: previous),
        ));

    final result = await _loadWordDetailQuery.execute(WordDetailQuery(
      wordId: key.wordId,
      wordType: key.wordType,
      hasConjugation: key.hasConj,
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
        EspJpnWordDetailViewData(dictionaries: final dictionaries) =>
          dictionaries.isEmpty,
        JpnEspWordDetailViewData(dictionaries: final dictionaries) =>
          dictionaries.isEmpty,
      };

  bool _isCurrent(int generation) => mounted && generation == _generation;

  void _setState(int generation, WordPageState next) {
    if (_isCurrent(generation)) state = next;
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
