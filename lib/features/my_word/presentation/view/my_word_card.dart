
import 'package:flutter/material.dart';
import 'package:my_dic/Components/button/my_icon_button.dart';
import 'package:my_dic/core/common/word_card_view_click_listener.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

const Map<String, IconData> _bookmarkIcon = {
  "true": Icons.bookmark_rounded,
  "false": Icons.bookmark_border_rounded,
  "added": Icons.bookmark_added_rounded
};
const Map<String, IconData> _learnedIcon = {
  "true": Icons.check_circle_rounded,
  "false": Icons.check_circle_outline_rounded
};

//スマホ用
class MyWordCard extends StatelessWidget {
  //
  const MyWordCard(
      {super.key,
      required this.myWord,
      //required this.meaning,
      // required this.partOfSpeech,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      /* required this.word,
      required this.no,
      required this.original,
      required this.isBookmarked,
      required this.isLearned, */
      required this.clickListeners});

  final MyWord myWord;
  //final String word;
  //final int no;
  //final String original;
  //final String meaning;
  // final List<PartOfSpeech> partOfSpeech;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  //final bool isBookmarked;
  //final bool isLearned;
  final Map<WordCardViewButton, VoidCallback> clickListeners;

  // static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  // static const Color wordColor = Colors.black;
  // static const Color headwordColor = Colors.black;
  // static const Color meaningColor = Colors.black;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded
  };
  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded
  };
  //Future<void>? currentAction;

  @override
  Widget build(BuildContext context) {
    Color descriptionColor = Theme.of(context).colorScheme.onSurfaceVariant;
    Color headwordColor = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin,
        // color: const Color.fromARGB(255, 234, 234, 234),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //No.
                      Container(
                        //width: 45,
                        child: Text(
                          myWord.word,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: headwordColor),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      //description
                      Container(
                        //width: 160,
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          myWord.contents,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: descriptionColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),

                // SizedBox(width: 15),
                ButtonSection(
                    //
                    clickListeners: clickListeners,
                    isFlags: {
                      WordCardViewButton.learned: myWord.isLearned,
                      WordCardViewButton.bookmark: myWord.isBookmarked
                    },
                    iconSizes: {
                      WordCardViewButton.learned: 22,
                      WordCardViewButton.bookmark: 24
                    }),
              ]),
        ),
      ),
    );
  }
}

/* class MyWordCard extends StatelessWidget {
  //
  const MyWordCard(
      {super.key,
      required this.myWord,
      //required this.meaning,
      // required this.partOfSpeech,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      /* required this.word,
      required this.no,
      required this.original,
      required this.isBookmarked,
      required this.isLearned, */
      required this.clickListeners});

  final MyWord myWord;
  //final String word;
  //final int no;
  //final String original;
  //final String meaning;
  // final List<PartOfSpeech> partOfSpeech;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  //final bool isBookmarked;
  //final bool isLearned;
  final Map<WordCardViewButton, VoidCallback> clickListeners;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color headwordColor = Colors.black;
  static const Color meaningColor = Colors.black;

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded
  };
  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded
  };
  //Future<void>? currentAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin,
        color: const Color.fromARGB(255, 234, 234, 234),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //No.
                    Container(
                      //width: 45,
                      child: Text(
                        myWord.word,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: headwordColor),
                        textAlign: TextAlign.left,
                      ),
                    ),

                    //Word
                    Container(
                      //width: 160,
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        myWord.contents,
                        style: TextStyle(fontSize: 15, color: wordColor),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),

                // SizedBox(width: 15),
                ButtonSection(
                    //
                    clickListeners: clickListeners,
                    isFlags: {
                      WordCardViewButton.learned: myWord.isLearned,
                      WordCardViewButton.bookmark: myWord.isBookmarked
                    },
                    iconSizes: {
                      WordCardViewButton.learned: 22,
                      WordCardViewButton.bookmark: 24
                    }),
              ]),
        ),
      ),
    );
  }
}
 */

class ButtonSection extends StatelessWidget {
  const ButtonSection({
    super.key,
    required this.clickListeners,
    required this.isFlags,
    required this.iconSizes,
  });
  final Map<WordCardViewButton, VoidCallback> clickListeners;
  final Map<WordCardViewButton, bool> isFlags;
  final Map<WordCardViewButton, double> iconSizes;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Row(
          spacing: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyIconButton(
              iconSize: iconSizes[WordCardViewButton.learned]!,
              defaultIcon: isFlags[WordCardViewButton.learned]!
                  ? _learnedIcon["true"] ?? Icons.error
                  : _learnedIcon["false"] ?? Icons.error,
              hoveredIcon: isFlags[WordCardViewButton.learned]!
                  ? _learnedIcon["true"] ?? Icons.error
                  : _learnedIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                clickListeners[WordCardViewButton.learned]!();
              },
            ),
            MyIconButton(
              iconSize: iconSizes[WordCardViewButton.bookmark]!,
              defaultIcon: isFlags[WordCardViewButton.bookmark]!
                  ? _bookmarkIcon["true"] ?? Icons.error
                  : _bookmarkIcon["false"] ?? Icons.error,
              hoveredIcon: isFlags[WordCardViewButton.bookmark]!
                  ? _bookmarkIcon["true"] ?? Icons.error
                  : _bookmarkIcon["false"] ?? Icons.error,
              hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
              onTap: () {
                clickListeners[WordCardViewButton.bookmark]!();
              },
            ),
          ],
        ));
  }
}
