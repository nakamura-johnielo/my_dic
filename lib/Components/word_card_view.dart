import 'package:flutter/material.dart';
import 'package:my_dic/Components/button/my_icon_button.dart';
import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';

class WordCardView extends StatelessWidget {
  const WordCardView(
      {super.key,
      //required this.ranking,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      required this.clickListeners,
      required this.cardColor,
      this.cardShape,
      this.elevation = 0,
      this.cardPadding =
          const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
      this.bookmarkButton = true,
      this.learnedButton = true,
      required this.isLearned,
      required this.isBookmarked,
      this.buttonIconSize = 22,
      required this.child});

  final Color cardColor;
  final ShapeBorder? cardShape;
  final double elevation;
  final EdgeInsetsGeometry cardPadding;
  final bool bookmarkButton;
  final bool learnedButton;
  final bool isLearned;
  final bool isBookmarked;
  final double buttonIconSize;
  final Widget child;

  //final Ranking ranking;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Map<WordCardViewClickListener, VoidCallback> clickListeners;

  /* static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color rankingColor = Colors.black;
  static const Color meaningColor = Colors.black; */

  static const Map<String, IconData> bookmarkIcon = {
    "true": Icons.bookmark_rounded,
    "false": Icons.bookmark_border_rounded,
    "added": Icons.bookmark_added_rounded
  };
  static const Map<String, IconData> learnedIcon = {
    "true": Icons.check_circle_rounded,
    "false": Icons.check_circle_outline_rounded
  };

  @override
  Widget build(BuildContext context) {
    /* cardShape =  RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ); */
    //log("wordID: ${ranking.rankedWord}");
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin,
        color: cardColor,
        elevation: elevation,
        shape: cardShape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
        child: Padding(
          padding: cardPadding,
          child: Row(children: [
            //input child
            child,
            //SizedBox(width: 15),

            if (learnedButton)
              MyIconButton(
                iconSize: buttonIconSize,
                defaultIcon: isLearned
                    ? learnedIcon["true"] ?? Icons.error
                    : learnedIcon["false"] ?? Icons.error,
                hoveredIcon: isLearned
                    ? learnedIcon["true"] ?? Icons.error
                    : learnedIcon["false"] ?? Icons.error,
                hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
                onTap: () {
                  clickListeners[WordCardViewClickListener.learned]!();
                },
              ),

            SizedBox(width: 10),

            if (bookmarkButton)
              MyIconButton(
                iconSize: buttonIconSize,
                defaultIcon: isBookmarked
                    ? bookmarkIcon["true"] ?? Icons.error
                    : bookmarkIcon["false"] ?? Icons.error,
                hoveredIcon: isBookmarked
                    ? bookmarkIcon["true"] ?? Icons.error
                    : bookmarkIcon["false"] ?? Icons.error,
                hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
                onTap: () {
                  clickListeners[WordCardViewClickListener.bookmark]!();
                },
              ),
          ]),
        ),
      ),
    );
  }
}
