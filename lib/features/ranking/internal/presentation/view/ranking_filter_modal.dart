import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/features/ranking/internal/domain/ranking_filter_selection.dart';
import 'package:my_dic/features/ranking/internal/presentation/provider/view_model_di.dart';
import 'package:my_dic/features/ranking/internal/presentation/ui_model/ranking_part_of_speech_labels.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

class RankingFilterModal extends ConsumerWidget {
  const RankingFilterModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(sessionScopeKeyProvider);
    if (scope == null) return const SizedBox.shrink();
    final state = ref.watch(rankingViewModelProvider(scope));
    final notifier = ref.read(rankingViewModelProvider(scope).notifier);
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterSection<RankingPartOfSpeech>(
                      label: '品詞',
                      values: RankingPartOfSpeech.values,
                      labelFor: (value) => value.displayLabel,
                      selected: state.filter.includedPartsOfSpeech.contains,
                      onChanged: (value, selected) =>
                          notifier.setPartOfSpeechFilter(
                        value,
                        selected
                            ? RankingFilterSelection.include
                            : RankingFilterSelection.neutral,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection<RankingStatusFilter>(
                      label: 'タグ',
                      values: RankingStatusFilter.values,
                      labelFor: (value) => value.displayLabel,
                      selected: state.filter.includedStatuses.contains,
                      onChanged: (value, selected) => notifier.setStatusFilter(
                        value,
                        selected
                            ? RankingFilterSelection.include
                            : RankingFilterSelection.neutral,
                      ),
                      trailing: FilterChip(
                        label: const Text('ダブり表示なし'),
                        selected: state.filter.groupByCatalogWord,
                        onSelected: notifier.setGroupByCatalogWord,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection<RankingPartOfSpeech>(
                      label: '品詞除外',
                      values: RankingPartOfSpeech.values,
                      labelFor: (value) => value.displayLabel,
                      selected: state.filter.excludedPartsOfSpeech.contains,
                      onChanged: (value, selected) =>
                          notifier.setPartOfSpeechFilter(
                        value,
                        selected
                            ? RankingFilterSelection.exclude
                            : RankingFilterSelection.neutral,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection<RankingStatusFilter>(
                      label: 'タグ除外',
                      values: RankingStatusFilter.values,
                      labelFor: (value) => value.displayLabel,
                      selected: state.filter.excludedStatuses.contains,
                      onChanged: (value, selected) => notifier.setStatusFilter(
                        value,
                        selected
                            ? RankingFilterSelection.exclude
                            : RankingFilterSelection.neutral,
                      ),
                    ),
                    const SizedBox(height: 20),
                    PagenationFilterSection(
                      label: 'ページ',
                      locatePage: notifier.locatePage,
                      pagenationFilter: state.pagenationFilter,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection<T extends Object> extends StatelessWidget {
  const _FilterSection({
    required this.label,
    required this.values,
    required this.labelFor,
    required this.selected,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final List<T> values;
  final String Function(T value) labelFor;
  final bool Function(T value) selected;
  final void Function(T value, bool selected) onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final value in values)
                FilterChip(
                  label: Text(labelFor(value)),
                  selected: selected(value),
                  onSelected: (next) => onChanged(value, next),
                ),
              if (trailing case final widget?) widget,
            ],
          ),
        ],
      );
}

class PagenationFilterSection extends StatelessWidget {
  const PagenationFilterSection({
    super.key,
    required this.label,
    required this.pagenationFilter,
    required this.locatePage,
  });

  static const int _pageSize = 100;
  static const int _maximumRank = 10000;

  final String label;
  final int pagenationFilter;
  final ValueChanged<int> locatePage;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (var page = 0;
                  page < _maximumRank ~/ _pageSize;
                  page++)
                FilterChip(
                  label: Text(page.toString()),
                  selected: pagenationFilter == page,
                  onSelected: (selected) {
                    if (selected) locatePage(page);
                  },
                ),
            ],
          ),
        ],
      );
}
