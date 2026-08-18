import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/invalid_route_page.dart';
import 'package:my_dic/app/routing/route_definitions.dart';

void main() {
  testWidgets(
      'invalid WordDetail URLs stop at InvalidRoutePage without reading feature dependencies',
      (tester) async {
    const invalidLocations = [
      '/root/word/0?catalog=espJpnMain',
      '/root/word/1?catalog=unknown',
      '/root/word/1?type=unknown',
      '/root/word/1?catalog=espJpnMain&type=jpnEsp',
    ];

    for (final location in invalidLocations) {
      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: '/root',
            builder: (context, state) => const SizedBox.shrink(),
            routes: [wordDetailRoute('detail', quizGameRouteName: 'quiz')],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InvalidRoutePage), findsOneWidget, reason: location);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
