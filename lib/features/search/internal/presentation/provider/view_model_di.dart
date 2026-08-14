import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/internal/presentation/view_model/viewmodel.dart';
import 'package:my_dic/features/search/port/search.dart';

final class _SearchViewModelKey {
  const _SearchViewModelKey(this.reader);

  final SearchQueryPort reader;

  @override
  bool operator ==(Object other) =>
      other is _SearchViewModelKey && identical(other.reader, reader);

  @override
  int get hashCode => identityHashCode(reader);
}

final _searchViewModelProvider = StateNotifierProvider.family<SearchViewModel,
    SearchState, _SearchViewModelKey>(
  (ref, key) => SearchViewModel(key.reader),
);

StateNotifierProvider<SearchViewModel, SearchState> searchViewModelProviderFor(
  SearchQueryPort reader,
) =>
    _searchViewModelProvider(_SearchViewModelKey(reader));
