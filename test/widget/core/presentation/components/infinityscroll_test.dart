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
}
