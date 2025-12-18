import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchInfinityListView extends ConsumerStatefulWidget {
  const SearchInfinityListView(
      {super.key,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.controller,
      this.physics,
      this.shrinkWrap = false,
      this.padding,
      this.itemExtent,
      required this.itemBuilder,
      required this.itemCount,
      /* required this.fragmentController,
    required this.viewModelProvider, */
      required this.loadNext,
      this.size = 100,
      required this.query});

  //original properties
  /* final InfinityScrollableController fragmentController;
  final ChangeNotifierProvider<InfinityScrollableViewModel<ItemType>>
      viewModelProvider; */
  //loadNext 次も取得できるデータが存在している場合に返り値true
  final Future<void> Function(String, int, int) loadNext;
  final String query;
  //final Future<bool> Function(string,int, int) loadNext;
  final int size;

  //listview properties
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;

  @override
  ConsumerState<SearchInfinityListView> createState() => _InfinityScrollState();
}

class _InfinityScrollState extends ConsumerState<SearchInfinityListView> {
  //state varables
  bool _isLoading = false;
  late bool _hasNext;
  int _preItemLength = -1;
  //0-previous,1-next用のpage
  int _currentPage = -1; //読み込み済みのページ０～、-１初期値
  late final int _size; // 1ページあたりのアイテム数
  bool _isUpdating = false;

  final ScrollController _scrollController = ScrollController();
  /* Timer? _nextThrottle;
  Timer? _previousThrottle; */

  //listview properties
  late final Axis scrollDirection;
  late final bool reverse;
  late final ScrollPhysics? physics;
  late final bool shrinkWrap;
  late final EdgeInsetsGeometry? padding;
  late final double? itemExtent;
  /* late final Widget Function(BuildContext, int) itemBuilder;
  late final int itemCount; */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //final q = widget.query;
    dev.log("##############didchange");
  }

  @override
  void didUpdateWidget(covariant SearchInfinityListView oldWidget) {
    // TODO: ページ切り替えた場合、widget.itemCount - oldWidget.itemCount＝０になってしまう

    super.didUpdateWidget(oldWidget);
    dev.log("VVVVVVVVV updatewidget");
    dev.log("1 o:${oldWidget.itemCount} w:${widget.itemCount} _:$_isUpdating");
    _hasNext = true;
    if (!_isUpdating) {
      if (widget.itemCount - oldWidget.itemCount < _size) {
        _hasNext = false;
        dev.log("size小");
      }
    }
    _isUpdating = false;
    if (oldWidget.query != widget.query) {
      _isUpdating = true;
      _currentPage = -1;
      _hasNext = true;
      dev.log("query d");
      loadNext();
      _scrollController.jumpTo(0.0); //TODO buil中にsetstateが呼ばれている。どこで呼ぶべき？
    }
    dev.log("o:${oldWidget.query} w:${widget.query}");
    dev.log(
        "2 o:${oldWidget.itemCount} w:${widget.itemCount} flag:$_isUpdating");
    dev.log("^^^^^^^^^^^^ updatewidget");
  }

  @override
  void initState() {
    super.initState();
    dev.log("##############initstate");
    _scrollController.addListener(_onScroll);

    //listview properties
    scrollDirection = widget.scrollDirection;
    reverse = widget.reverse;
    physics = widget.physics;
    shrinkWrap = widget.shrinkWrap;
    padding = widget.padding;
    itemExtent = widget.itemExtent;
    _size = widget.size;
    _hasNext = true;
    /* itemBuilder = widget.itemBuilder; 
    _itemCount = widget.itemCount;*/

    /* widget.loadNext(_size, currentPages);
    currentPages[0] = 0;
    currentPages[1] = 0; */
    //loadNext();
  }

  void _onScroll() {
    // 最大スクロール位置の80%を計算
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    final threshold = max(_scrollController.position.maxScrollExtent - 540,
        _scrollController.position.maxScrollExtent * 0.8);
    dev.log("scroll");
    if ( //(!(_nextThrottle?.isActive ?? false)) &&
        _scrollController.position.pixels >= threshold &&
            _hasNext &&
            !_isLoading) {
      /* _nextThrottle = Timer(Duration(milliseconds: 1200), () {
        //２００ｍｓ以内は受け付けない
      }); */
      //次もページ読み込み可能ならtrue返ってくる
      //bool hasNextLatest =
      loadNext();
    }
  }

  /*  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // 初期値 (一番上) の位置
      duration: Duration(milliseconds: 200), // アニメーションの時間
      curve: Curves.easeInOut, // アニメーションの曲線
    );
  } */
  void loadNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //_isLoading = true;
      setState(() {
        _isLoading = true;
      });
      dev.log("loadNext, page: $_currentPage");
      await widget.loadNext(widget.query, _size, _currentPage);
      // _currentPage += 1;
      //setState(() {});

      setState(() {
        _currentPage++;
        _isLoading = false;
      });

      /* _hasNext = false;
      if (widget.itemCount % _size == 0) {
        _hasNext = true;
      } */
      //setState(() {});
    });
  }
  /* void loadNext() async {
    _isLoading = true;
    await widget.loadNext(widget.query, _size, _currentPage);
    _currentPage += 1;
    //setState(() {});

    _hasNext = false;
    if (widget.itemCount % _size == 0) {
      _hasNext = true;
    }
    _isLoading = false;
    setState(() {});
  } */

/*   void checkNext(int preItemLength) {
    if (widget.itemCount - preItemLength < _size) {
      setState(() {
        _hasNext = false;
      });
      ;
    }
    //_setStatePreItemLength(itemCount);
  } */

  @override
  void dispose() {
    _scrollController.dispose();
    //_nextThrottle?.cancel();
    //_previousThrottle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final viewModel = ref.watch(_viewModelProvider);

    dev.log("${widget.query}##############in build");
    return ListView.builder(
      controller: _scrollController,
      //key: key,
      //lisview properties
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      itemCount: widget.itemCount, //widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
