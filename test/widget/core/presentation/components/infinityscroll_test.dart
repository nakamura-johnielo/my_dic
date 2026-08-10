import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';

void main() {
  testWidgets('does not load when the initial page has no next page',
      (tester) async {
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          initialPage: 1,
          initialHasMore: false,
          itemCount: 20,
          itemBuilder: (_, index) => const SizedBox(height: 100),
          onLoadMore: (page) async {
            requestedPages.add(page);
            return false;
          },
        ),
      ),
    ));

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(requestedPages, isEmpty);
  });

  testWidgets(
      'reset during a load ignores completion from the previous generation',
      (tester) async {
    final controller = InfinityScrollController();
    final first = Completer<bool>();
    final second = Completer<bool>();
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          controller: controller,
          autoLoadFirstPage: true,
          itemCount: 1,
          itemBuilder: (_, __) => const SizedBox(height: 100),
          onLoadMore: (page) {
            requestedPages.add(page);
            return requestedPages.length == 1 ? first.future : second.future;
          },
        ),
      ),
    ));
    await tester.pump();
    expect(requestedPages, [0]);

    controller.reset();
    await tester.pump();
    expect(requestedPages, [0, 0]);

    first.complete(true);
    await tester.pump();

    // The old request must not clear the new generation's in-flight state or
    // advance its page while the replacement request is still pending.
    controller.retryCurrentPage();
    await tester.pump();
    expect(requestedPages, [0, 0]);

    second.complete(true);
    await tester.pump();

    controller.retryCurrentPage();
    await tester.pump();
    expect(requestedPages, [0, 0, 1]);
  });

  testWidgets('retry retries the same zero-based page after failure',
      (tester) async {
    final controller = InfinityScrollController();
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          controller: controller,
          autoLoadFirstPage: true,
          itemCount: 1,
          itemBuilder: (_, __) => const SizedBox(height: 100),
          onLoadMore: (page) async {
            requestedPages.add(page);
            if (requestedPages.length == 1) {
              throw StateError('failed');
            }
            return false;
          },
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();

    controller.retry();
    await tester.pump();

    expect(requestedPages, [0, 0]);
  });

  testWidgets('double retry has one in-flight owner callback', (tester) async {
    final controller = InfinityScrollController();
    final first = Completer<bool>();
    final retry = Completer<bool>();
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          controller: controller,
          autoLoadFirstPage: true,
          itemCount: 1,
          itemBuilder: (_, __) => const SizedBox(height: 100),
          onLoadMore: (page) {
            requestedPages.add(page);
            return requestedPages.length == 1 ? first.future : retry.future;
          },
        ),
      ),
    ));
    await tester.pump();
    first.completeError(StateError('failed'));
    await tester.pump();

    controller.retry();
    controller.retry();
    await tester.pump();
    expect(requestedPages, [0, 0]);

    retry.complete(false);
    await tester.pump();
  });

  testWidgets('reset restores the initial page and hasMore before auto loading',
      (tester) async {
    final controller = InfinityScrollController();
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          controller: controller,
          initialPage: 3,
          initialHasMore: true,
          autoLoadFirstPage: true,
          itemCount: 1,
          itemBuilder: (_, __) => const SizedBox(height: 100),
          onLoadMore: (page) async {
            requestedPages.add(page);
            return false;
          },
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();

    controller.reset();
    await tester.pump();
    await tester.pump();

    expect(requestedPages, [3, 3]);
  });

  testWidgets('auto initial load invokes the owner once', (tester) async {
    final requestedPages = <int>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: InfinityScrollListView(
          autoLoadFirstPage: true,
          itemCount: 1,
          itemBuilder: (_, __) => const SizedBox(height: 100),
          onLoadMore: (page) async {
            requestedPages.add(page);
            return false;
          },
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(requestedPages, [0]);
  });
}
