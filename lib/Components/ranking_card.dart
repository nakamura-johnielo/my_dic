import 'package:flutter/material.dart';

class RankingCard extends StatelessWidget {
  const RankingCard(
      {super.key,
      required this.word,
      //required this.meaning,
      // required this.partOfSpeech,
      this.onTap,
      this.margin = const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      required this.no,
      required this.original});

  final String word;
  final int no;
  final String original;
  //final String meaning;
  // final List<PartOfSpeech> partOfSpeech;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color rankingColor = Colors.black;
  static const Color meaningColor = Colors.black;

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
            SizedBox(
              width: 45,
              child: Text(
                no.toString(),
                style: TextStyle(fontSize: 15, color: rankingColor),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(width: 15),
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
                style: TextStyle(fontSize: 15, color: hinshiColor),
                textAlign: TextAlign.left,
              ),
            ),
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