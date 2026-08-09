import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/ui/word_card_view_click_listener.dart';
import 'package:my_dic/features/my_word/presentation/ui_model/my_word_ui_model.dart';
import 'package:my_dic/features/my_word/presentation/view/my_word_card.dart';

void main() {
  testWidgets('routes each status button through its supplied command callback',
      (tester) async {
    var learnedToggles = 0;
    var bookmarkToggles = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MyWordCard(
          item: MyWordItemUiModel(
            wordId: 'word-1',
            word: 'casa',
            contents: 'home',
            editAt: DateTime.utc(2026),
            isLearned: false,
            isBookmarked: false,
          ),
          clickListeners: {
            WordCardViewButton.learned: () => learnedToggles++,
            WordCardViewButton.bookmark: () => bookmarkToggles++,
          },
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.check_circle_outline_rounded));
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pump(const Duration(seconds: 1));

    expect(learnedToggles, 1);
    expect(bookmarkToggles, 1);
  });

  testWidgets('renders the next projection status after a toggle update',
      (tester) async {
    MyWordItemUiModel item(bool learned) => MyWordItemUiModel(
          wordId: 'word-1',
          word: 'casa',
          contents: 'home',
          editAt: DateTime.utc(2026),
          isLearned: learned,
          isBookmarked: false,
        );
    Future<void> pump(MyWordItemUiModel value) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: MyWordCard(
              item: value,
              clickListeners: {
                WordCardViewButton.learned: () {},
                WordCardViewButton.bookmark: () {},
              },
            ),
          ),
        ));

    await pump(item(false));
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    await pump(item(true));
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });
}
