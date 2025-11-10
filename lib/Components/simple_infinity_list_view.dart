import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleInfinityListView extends ConsumerStatefulWidget {
  const SimpleInfinityListView({
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
    this.size = 100,
  });

  //original properties
  /* final InfinityScrollableController fragmentController;
  final ChangeNotifierProvider<InfinityScrollableViewModel<ItemType>>
      viewModelProvider; */
  //loadNext 次も取得できるデータが存在している場合に返り値true
  final Future<bool> Function(int, int) loadNext;
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
  ConsumerState<SimpleInfinityListView> createState() => _InfinityScrollState();
}

class _InfinityScrollState extends ConsumerState<SimpleInfinityListView> {
  //state varables
  bool _isLoading = false;
  bool _hasNext = true;
  int _preItemLength = -1;
  //0-previous,1-next用のpage
  int _currentPage = 0; //読み込み済みのページ０～、-１初期値
  late final int _size; // 1ページあたりのアイテム数

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
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    //listview properties
    scrollDirection = widget.scrollDirection;
    reverse = widget.reverse;
    physics = widget.physics;
    shrinkWrap = widget.shrinkWrap;
    padding = widget.padding;
    itemExtent = widget.itemExtent;
    _size = widget.size;
    /* itemBuilder = widget.itemBuilder;
    itemCount = widget.itemCount; */

    /* widget.loadNext(_size, currentPages);
    currentPages[0] = 0;
    currentPages[1] = 0; */
    loadNext();
  }

  void _onScroll() {
    // 最大スクロール位置の80%を計算
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    final threshold = max(_scrollController.position.maxScrollExtent - 540,
        _scrollController.position.maxScrollExtent * 0.8);

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

  void loadNext() async {
    _isLoading = true;
    await widget.loadNext(_size, _currentPage);
    _currentPage += 1;
    //setState(() {});

    _hasNext = false;
    if (widget.itemCount % _size == 0) {
      _hasNext = true;
    }
    _isLoading = false;
    setState(() {});
  }

  void checkNext(int preItemLength) {
    if (widget.itemCount - preItemLength < _size) {
      setState(() {
        _hasNext = false;
      });
      ;
    }
    //_setStatePreItemLength(itemCount);
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
