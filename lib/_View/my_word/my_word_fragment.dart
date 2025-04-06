import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/infinity_scroll_list_view.dart';
import 'package:my_dic/Components/my_word_card.dart';
import 'package:my_dic/Components/my_word_card_modal.dart';
import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Interface_Adapter/Controller/my_word_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/my_word_view_model.dart';
import 'package:my_dic/_View/my_word/create_word_modal.dart';

class MyWordFragment extends ConsumerWidget {
  const MyWordFragment(this._myWordController, {super.key});
  final MyWordController _myWordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWordViewModel = ref.watch(myWordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Word'),
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('This is my word screen'),
          Expanded(
              child: InfinityScrollListView(
            loadNext: _myWordController.loadNext,
            itemCount: myWordViewModel.items.length,
            itemBuilder: (context, index) {
              final myword = myWordViewModel.items[index];

              //!
              //!TODO clicklisternerがmodalとリアルタイムで更新されない
              //!

              final clickListeners = {
                WordCardViewButton.bookmark: () {
                  _myWordController.updateWordStatus(
                    index,
                    myword.wordId,
                    !myword.isBookmarked,
                    myword.isLearned,
                    //myword.hasNote
                  );
                },
                WordCardViewButton.learned: () {
                  _myWordController.updateWordStatus(
                    index,
                    myword.wordId,
                    myword.isBookmarked,
                    !myword.isLearned,
                    //myword.hasNote
                  );
                },
              };
              return MyWordCard(
                onTap: () {
                  openDetailModal(context, clickListeners, index, myword);
                },
                myWord: myword,
                clickListeners: clickListeners,
              );
            },
          )),
        ],
      )),
      floatingActionButton: RegisterButton(),
    );
  }
}

void openDetailModal(
    BuildContext context,
    Map<WordCardViewButton, void Function()> clickListeners,
    int index,
    MyWord myword) {
  showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      //showDragHandle: true,
      barrierColor: Colors.black.withValues(alpha: .5),
      builder: (context) {
        return Center(
          child: MyWordCardModal(
              myWord: myword, clickListeners: clickListeners, index: index),
        );
      });
}

/* class MyWordFragment extends ConsumerStatefulWidget {
  const MyWordFragment(this._myWordController, {super.key});
  final MyWordController _myWordController;

  @override
  ConsumerState<MyWordFragment> createState() => _MyWordFragmentState();
}

class _MyWordFragmentState extends ConsumerState<MyWordFragment> {
  final ScrollController _scrollController = ScrollController();
  /* final RankingController _rankingController;
   _RankingFragmentState(this._rankingController); */
  /* Timer? _nextThrottle;
  Timer? _previousThrottle; */
  late final MyWordController _myWordController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    //final viewModel = ref.read(rankingViewModelProvider);

    /* LoadRankingsControllerInputData inputLoadItems =
        LoadRankingsControllerInputData(
            viewModel.partOfSpeechFilters,
            viewModel.featureTagFilters,
            viewModel.currentPage[1],
            viewModel.size); */
    _myWordController = widget._myWordController;
    widget._myWordController.loadNext();
  }

  void _onScroll() {
    /* final myWordViewModel = ref.read(myWordViewModelProvider);
    // 最大スクロール位置の80%を計算
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    final threshold = _scrollController.position.maxScrollExtent - 540;

    if ( //(!(_nextThrottle?.isActive ?? false)) &&
        _scrollController.position.pixels >= threshold &&
            myWordViewModel.hasNext &&
            !myWordViewModel.isNextLoading) {
     

      myWordViewModel.isNextLoading = true;
     
      widget._myWordController.loadNext();
    }

    final thresholdPre = _scrollController.position.maxScrollExtent * 0.2;
    if ( //(_previousThrottle?.isActive ?? false) &&
        _scrollController.position.pixels <= thresholdPre &&
            myWordViewModel.hasPrevious() &&
            !myWordViewModel.isPreLoading) {
      //_previousThrottle = Timer(Duration(milliseconds: 200), () {});
      
      myWordViewModel.isPreLoading = true;
      //widget._rankingController.loadPrevious();
    } */
  }

  @override
  void dispose() {
    _scrollController.dispose();
    //_nextThrottle?.cancel();
    //_previousThrottle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myWordViewModel = ref.watch(myWordViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Word'),
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('This is my word screen'),
          Expanded(
              child: ListView.builder(
            itemCount: myWordViewModel.items.length,
            itemBuilder: (context, index) {
              return MyWordCard(
                myWord: myWordViewModel.items[index],
                clickListeners: {
                  WordCardViewButton.bookmark: () {},
                  WordCardViewButton.learned: () {},
                },
              );
            },
          )),
        ],
      )),
      floatingActionButton: CreateButton(),
    );
  }
}
 */

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // ボタンが押された時のアクション
        showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            enableDrag: true,
            //showDragHandle: true,
            barrierColor: Colors.black.withValues(alpha: .5),
            builder: (context) {
              return DI<WordRegistrationModal>();
            });
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
    );
  }
}

/* class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // ボタンが押された時のアクション
        showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            enableDrag: true,
            //showDragHandle: true,
            barrierColor: Colors.black.withValues(alpha: .5),
            builder: (context) {
              return DI<RankingFilterModal>();
            });
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.filter_alt_rounded),
    );
  }
}
 */
