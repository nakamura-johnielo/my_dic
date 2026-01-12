import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';

/// 親から reset を呼べるようにするための controller
class InfinityScrollController {
  VoidCallback? _reset;

  /// ページ状態をリセット（次回スクロール/呼び出しで先頭ページからロード）
  void reset() => _reset?.call();
}

class InfinityScrollListView extends StatefulWidget {
  const InfinityScrollListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    this.controller,
    this.initialPage = 0,
    this.autoLoadFirstPage = false,
    this.loadMoreThreshold = 0.8,
    this.scrollController,
    this.padding,
    this.physics,
  });

  //

  /// 親が持っている現在の要素数（Riverpod等の state の length）
  final int itemCount;

  /// itemCount の範囲で描画する builder
  final Widget Function(BuildContext, int) itemBuilder;

  /// page を渡してロードを依頼。戻り値は「まだ次があるか」
  ///
  /// 親はこの中で fetch して state に append してください。
  /// 例: return loadedCount > 0 && loadedCount == pageSize;
  final Future<bool> Function(int page) onLoadMore;

  /// 外部からリセットしたい場合に渡す
  final InfinityScrollController? controller;

  /// 最初にロードするページ番号（0 など）
  final int initialPage;

  /// initState 後に 1ページ目を自動ロードするか
  final bool autoLoadFirstPage;

  final double loadMoreThreshold;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<InfinityScrollListView> createState() => _InfinityScrollListViewState();
}

class _InfinityScrollListViewState extends State<InfinityScrollListView> {
  late final ScrollController _scrollController;

  bool _isLoading = false;
  bool _hasMore = true;

  /// 次に要求するページ
  late int _nextPage;

  @override
  void initState() {
    super.initState();
    dev.log("InfinityScrollListView initState");

    _nextPage = widget.initialPage;

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    // controller を接続
    widget.controller?._reset = _resetInternal;

    if (widget.autoLoadFirstPage) {
      //default false
      // 初回はフレーム後に呼ぶ（position 未attach対策）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMore(); //TODO ifneeded?
      });
    }
  }

  @override
  void didUpdateWidget(covariant InfinityScrollListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reset = null;
      widget.controller?._reset = _resetInternal;
    }

    //print("infiscroll nextPage: $_nextPage" );
  }

  @override
  void dispose() {
    widget.controller?._reset = null;
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _resetScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _resetInternal() {
    print("InfinityScrollListView reset");
    _resetScrollPosition();

    setState(() {
      _isLoading = false;
      _hasMore = true;
      _nextPage = widget.initialPage;
    });

    if (widget.autoLoadFirstPage) {
      //default false
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMore(); //TODO ifneeded?
      });
    }
  }

  void _onScroll() => _loadMoreIfNeeded();

  void _loadMoreIfNeeded() {
    if (!mounted) return;
    if (_isLoading || !_hasMore) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold =
        max(maxScroll * widget.loadMoreThreshold, maxScroll - 540);

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final page = _nextPage;
      final hasMore = await widget.onLoadMore(page);

          print("in infi _nextPage BEFORE : $_nextPage");
      if (!mounted) return;

      setState(() {
        _hasMore = hasMore;
        _isLoading = false;
        if (hasMore) {
          _nextPage = page + 1;
        }
          print("in infi _nextPage: $_nextPage");
      });
    } catch (e, st) {
      dev.log("InfinityScrollListView loadMore error: $e", stackTrace: st);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => widget.itemBuilder(context, index),
    );
  }
}
