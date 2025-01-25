import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/_Interface_Adapter/Controller/ranking_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/ranking_view_model.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';

class RankingFilterModal extends ConsumerWidget {
  //const RankingFilterModal({super.key, required this.viewModel});
  const RankingFilterModal(this._rankingController, {super.key});
  final RankingController _rankingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(rankingViewModelProvider);

    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 1,
      child: Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        //margin: EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FilterSection(
                      label: "品詞",
                      filters: viewModel.partOfSpeechFilters,
                      chipsEnum: PartOfSpeech.values,
                      rankingController: _rankingController,
                      viewModel: viewModel,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    PagenationFilterSection(
                      label: "ページ",
                      rankingController: _rankingController,
                      pagenationFilter: viewModel.pagenationFilter,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FilterSection<ChipsEnum extends DisplayEnumMixin>
    extends StatelessWidget {
  const FilterSection(
      {super.key,
      required this.label,
      required this.chipsEnum,
      required this.filters,
      required this.rankingController,
      required this.viewModel});
  final String label;
  final List<ChipsEnum> chipsEnum; //Enum
  final Set<ChipsEnum> filters;
  final RankingController rankingController;
  final RankingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 6,
        ),
        Wrap(
          spacing: 5.0,
          runSpacing: 5,
          children: chipsEnum.map((ChipsEnum chip) {
            return FilterChip(
              label: Text(chip.display),
              selected: filters.contains(chip),
              onSelected: (bool selected) {
                if (selected) {
                  rankingController.addFilter(chip);
                  /* LoadRankingsControllerInputData inputLoadItems =
                      LoadRankingsControllerInputData(
                          viewModel.partOfSpeechFilters,
                          viewModel.featureTagFilters,
                          viewModel.currentPage[1],
                          viewModel.size);
                  rankingController.loadNext(inputLoadItems); */
                  //filters.add(chip);
                  //viewModel.addPartOfSpeechFilter(chip);
                } else {
                  //viewModel.deletePartOfSpeechFilter(chip);
                  rankingController.deleteFilter(chip);
                  /* LoadRankingsControllerInputData inputLoadItems =
                      LoadRankingsControllerInputData(
                          viewModel.partOfSpeechFilters,
                          viewModel.featureTagFilters,
                          viewModel.currentPage[1],
                          viewModel.size);
                  rankingController.loadNext(inputLoadItems); */
                  //filters.remove(chip);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PagenationFilterSection extends StatelessWidget {
  const PagenationFilterSection(
      {super.key,
      required this.label,
      required this.rankingController,
      required this.pagenationFilter});

  final String label; //Enum
  final RankingController rankingController;
  final int pagenationFilter;

  @override
  Widget build(BuildContext context) {
    int size = 100;
    int max = 10000;
    int pageTotal = max ~/ size;
    List<int> pageNum = [];
    for (int i = 0; i < pageTotal; i++) {
      pageNum.add(i);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 6,
        ),
        Wrap(
          spacing: 5.0,
          runSpacing: 5,
          children: pageNum.map((int page) {
            return FilterChip(
              label: Text(page.toString()),
              selected: pagenationFilter == page,
              onSelected: (bool selected) {
                if (selected) {
                  rankingController.locatePage(page);
                } else {
                  //rankingController.deleteFilter(chip);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ChipButtonGroup extends StatelessWidget {
  const ChipButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
