import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';

class InfinityScrollListView extends StatefulWidget {
  const InfinityScrollListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.loadMoreThreshold = 0.8,
    this.scrollController,
    this.padding,
    this.physics,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final double loadMoreThreshold;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<InfinityScrollListView> createState() => _InfinityScrollListViewState();
}

class _InfinityScrollListViewState extends State<InfinityScrollListView> {
  late ScrollController _scrollController;



  @override
  void initState() {
    super.initState();
    dev.log("##############initstate");
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (widget.isLoading || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold =
        max(maxScroll * widget.loadMoreThreshold, maxScroll - 540);

    // 最大スクロール位置の80%を計算F
    //listviewのbottom padding引いてる240
    //final threshold = _scrollController.position.maxScrollExtent * 0.8 - 240;
    // final threshold = max(_scrollController.position.maxScrollExtent - 540,
    //     _scrollController.position.maxScrollExtent * 0.8);
    dev.log("scroll");
    if ( //(!(_nextThrottle?.isActive ?? false)) &&
        currentScroll >= threshold //&& _hasNext && !_isLoading
        ) {
      /* _nextThrottle = Timer(Duration(milliseconds: 1200), () {
        //２００ｍｓ以内は受け付けない
      }); */
      //次もページ読み込み可能ならtrue返ってくる
      //bool hasNextLatest =
      // loadNext();
       widget.onLoadMore();
    }
  }


  @override
  Widget build(BuildContext context) {
    //final viewModel = ref.watch(_viewModelProvider);

    //dev.log("${widget.query}##############in build");
    return ListView.builder(
      controller: _scrollController,
      //key: key,
      //lisview properties
      //scrollDirection: scrollDirection,
      padding: widget.padding,
      physics: widget.physics,
      //itemExtent: itemExtent,
      itemCount: widget.itemCount, //widget.itemCount,
      itemBuilder:(context, index) => widget.itemBuilder(context, index),
    );
  }
}
