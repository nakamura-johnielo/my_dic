import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/ranking_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/word_status_composition.dart';
import 'package:my_dic/features/ranking/port/presentation_entry.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';

/// 完成した機能群からRankingの入口への、アプリ所有の遅延ブリッジ。
class RankingPresentationEntry extends ConsumerWidget {
  const RankingPresentationEntry({
    super.key,
    required this.onOpenWordDetail,
    required this.onOpenQuiz,
  });

  final ValueChanged<CatalogWordRef> onOpenWordDetail;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingPorts = ref.watch(rankingPortsProvider);
    final wordStatusPorts = ref.watch(wordStatusPortsProvider);
    return RankingFragment(
      ports: rankingPorts,
      wordStatusRenderer: (word) =>
          DictionaryStatusButtonsEntry(word: word, ports: wordStatusPorts),
      onOpenWordDetail: onOpenWordDetail,
      onOpenQuiz: onOpenQuiz,
    );
  }
}
