import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfinityScrollListView extends ConsumerStatefulWidget {
  const InfinityScrollListView({
    super.key,
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
    this.loadPrevious,
  });

  //original properties
  /* final InfinityScrollableController fragmentController;
  final ChangeNotifierProvider<InfinityScrollableViewModel<ItemType>>
      viewModelProvider; */
  //loadNext 次も取得できるデータが存在している場合に返り値true
  final bool Function(int, List<int>) loadNext;
  final bool Function(int, List<int>)? loadPrevious;

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
  ConsumerState<InfinityScrollListView> createState() => _InfinityScrollState();
}

class _InfinityScrollState extends ConsumerState<InfinityScrollListView> {
  //state varables
  bool _isLoadingNext = false;
  bool _isLoadingPrevious = false;
  bool _hasNext = true;
  bool _hasPrevious = false;
  int _preItemLength = -1;
  //0-previous,1-next用のpage
  List<int> currentPages = [-1, -1]; //読み込み済みのページ０～、-１初期値
  final int _size = 100; // 1ページあたりのアイテム数

  final ScrollController _scrollController = ScrollController();
  /* Timer? _nextThrottle;
  Timer? _previousThrottle; */

  //listview properties
  late final Axis scrollDirection;
  late final bool reverse;
  late final ScrollController? controller;
  late final ScrollPhysics? physics;
  late final bool shrinkWrap;
  late final EdgeInsetsGeometry? padding;
  late final double? itemExtent;
  /* late final Widget Function(BuildContext, int) itemBuilder;
  late final int itemCount; */

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    //listview properties
    scrollDirection = widget.scrollDirection;
    reverse = widget.reverse;
    controller = widget.controller;
    physics = widget.physics;
    shrinkWrap = widget.shrinkWrap;
    padding = widget.padding;
    itemExtent = widget.itemExtent;
    /* itemBuilder = widget.itemBuilder;
    itemCount = widget.itemCount; */

    widget.loadNext(_size, currentPages);
  }

  void _onScroll() {
    // 最大スクロール位置の80%を計算
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    final threshold = _scrollController.position.maxScrollExtent - 540;

    if ( //(!(_nextThrottle?.isActive ?? false)) &&
        _scrollController.position.pixels >= threshold &&
            _hasNext &&
            !_isLoadingNext) {
      /* _nextThrottle = Timer(Duration(milliseconds: 1200), () {
        //２００ｍｓ以内は受け付けない
      }); */
      //次もページ読み込み可能ならtrue返ってくる
      //bool hasNextLatest =
      loadNext();
    }

    final thresholdPre = _scrollController.position.maxScrollExtent * 0.2;
    if ( //(_previousThrottle?.isActive ?? false) &&
        _scrollController.position.pixels <= thresholdPre &&
            _hasPrevious &&
            !_isLoadingPrevious) {
      //_previousThrottle = Timer(Duration(milliseconds: 200), () {});
      //_setStateLoadingPrevious(true);
      //widget._rankingController.loadPrevious();
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
    _isLoadingNext = true;
    widget.loadNext(_size, currentPages);
    if (currentPages[1] == -1) {
      //初回のみ両方０にする
      currentPages[0] = 0;
    }
    currentPages[1] = currentPages[1] + 1;
    //checkNext(_preItemLength);
    //_setStatePreItemLength(widget.itemCount);

    _isLoadingNext = false;
    setState(() {});
  }

  void checkNext(int preItemLength) {
    if (widget.itemCount - preItemLength < _size) {
      _setStateHasNext(false);
    }
    //_setStatePreItemLength(itemCount);
  }

  void _setStateCurrentPages(int index, int page) {
    setState(() {
      currentPages[index] = page;
    });
  }

  void _setStatePreItemLength(int l) {
    setState(() {
      _preItemLength = l;
    });
  }

  void _setStateLoadingNext(bool b) {
    setState(() {
      _isLoadingNext = b;
    });
  }

  void _setStateLoadingPrevious(bool b) {
    setState(() {
      _isLoadingPrevious = b;
    });
  }

  void _setStateHasNext(bool b) {
    setState(() {
      _hasNext = b;
    });
  }

  void _setStateHasPrevious(bool b) {
    setState(() {
      _hasPrevious = b;
    });
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
    //final viewModel = ref.watch(_viewModelProvider);

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
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
