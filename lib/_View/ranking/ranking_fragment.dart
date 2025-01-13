import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/ranking_card.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class RankingFragment extends ConsumerWidget {
  const RankingFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(rankingViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) {
            Ranking ranking = viewModel.items[index];
            return RankingCard(
              word: ranking.rankedWord,
              original: ranking.lemma,
              no: ranking.rank,
              onTap: () {
                context.push('/${ScreenTab.ranking}/${ScreenPage.detail}',
                    extra: WordPageFragmentInput(
                        wordId: ranking.wordId, isVerb: true //!TODO
                        ));
              },
            );
          },
        ),
      ),
    );
  }
}
