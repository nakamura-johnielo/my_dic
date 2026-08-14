import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_detail_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_status_composition.dart';
import 'package:my_dic/features/search/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/integration/catalog_search/catalog_search_providers.dart';

/// App-owned adapter that obtains the completed Search capability only while
/// the search route is mounted.
final class SearchRouteEntry extends ConsumerWidget {
  const SearchRouteEntry({
    super.key,
    required this.onOpenWordDetail,
    required this.onOpenQuiz,
  });

  final ValueChanged<CatalogWordRef> onOpenWordDetail;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SearchFragment(
        reader: ref.watch(searchReaderPortProvider),
        onOpenWordDetail: onOpenWordDetail,
        onOpenQuiz: onOpenQuiz,
      );
}

/// App-owned adapter for WordDetail and its embedded WordStatus entry.
final class WordDetailRouteEntry extends ConsumerWidget {
  const WordDetailRouteEntry({
    super.key,
    required this.input,
    required this.onOpenQuiz,
  });

  final WordDetailPresentationInput input;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusPorts = ref.watch(wordStatusPortsProvider);
    return WordDetailEntry(
      input: input,
      reader: ref.watch(wordDetailQueryPortProvider),
      wordStatusRenderer: (word) =>
          DictionaryStatusButtonsEntry(word: word, ports: statusPorts),
      onOpenQuiz: onOpenQuiz,
    );
  }
}
