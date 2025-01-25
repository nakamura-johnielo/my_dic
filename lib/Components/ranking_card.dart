import 'package:flutter/material.dart';
import 'package:my_dic/Components/button/my_icon_button.dart';

class RankingCard extends StatelessWidget {
  const RankingCard(
      {super.key,
      required this.word,
      //required this.meaning,
      // required this.partOfSpeech,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      required this.no,
      required this.original,
      required this.isBookmarked,
      required this.isLearned});

  final String word;
  final int no;
  final String original;
  //final String meaning;
  // final List<PartOfSpeech> partOfSpeech;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool isBookmarked;
  final bool isLearned;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color rankingColor = Colors.black;
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
          child: Row(children: [
            //No.
            SizedBox(
              width: 45,
              child: Text(
                no.toString(),
                style: TextStyle(fontSize: 15, color: rankingColor),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* child:  */
                  //Word
                  SizedBox(
                    width: 160,
                    child: Text(
                      word,
                      style: TextStyle(fontSize: 15, color: wordColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(width: 15),
                  SizedBox(
                    width: 160,
                    child: Text(
                      original,
                      style: TextStyle(fontSize: 15, color: wordColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 15),
            Container(
                //width: 34,
                child: Icon(
                    isLearned ? learnedIcon["true"] : learnedIcon["false"])),
            SizedBox(width: 15),

            MyIconButton(
              defaultIcon: Icons.check_circle_rounded,
              hoveredIcon: Icons.check_circle_outline_rounded,
            ),

            Container(
                //width: 34,
                child: Icon(isBookmarked
                    ? bookmarkIcon["true"]
                    : bookmarkIcon["false"])),
          ]),
          /* Text(
                  meaning,
                  style: TextStyle(fontSize: 11, color: meaningColor),
                  textAlign: TextAlign.left,
                ), */
        ),
      ),
    );
  }
}


/* 
Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: const Color.fromARGB(255, 234, 234, 234),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
            child: Row(children: [
              Text(
                no.toString(),
                style: TextStyle(fontSize: 15, color: rankingColor),
                textAlign: TextAlign.left,
              ),
              Text(
                word,
                style: TextStyle(fontSize: 15, color: wordColor),
                textAlign: TextAlign.left,
              ),
              SizedBox(width: 15),
              Text(
                original,
                style: TextStyle(fontSize: 15, color: hinshiColor),
                textAlign: TextAlign.left,
              ),
            ]),
            /* Text(
                  meaning,
                  style: TextStyle(fontSize: 11, color: meaningColor),
                  textAlign: TextAlign.left,
                ), */
          ),
        ),
      ),
    );

 */