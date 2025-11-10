import 'package:flutter/material.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class QuizSearchCard extends StatelessWidget {
  const QuizSearchCard(
      {super.key, required this.word, required this.meaning, this.onTap});

  final String word;
  final String meaning;
  final VoidCallback? onTap;

  static const Color hinshiColor = Color.fromARGB(255, 40, 40, 40);
  static const Color wordColor = Colors.black;
  static const Color meaningColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          border: Border(
            //top: BorderSide(width: 2.0, color: Colors.black), // 上ボーダー
            bottom: BorderSide(
                width: 1,
                color: const Color.fromARGB(255, 157, 157, 157)), // 下ボーダー
          ),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          /* child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 4, 15, 4), */
          child: Column(
            children: [
              Row(children: [
                Text(
                  word,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: wordColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(width: 15),
                Text(
                  meaning,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: meaningColor),
                  textAlign: TextAlign.left,
                ),
                // Text(
                //   partOfSpeech.map((p) => p.display).join(','),
                //   style: TextStyle(fontSize: 12, color: hinshiColor),
                //   textAlign: TextAlign.left,
                // ),
              ]),
              /* Text(
                  meaning,
                  style: TextStyle(fontSize: 11, color: meaningColor),
                  textAlign: TextAlign.left,
                ), */
            ],
          ),

          //),
        ),
      ),
    );
  }
}
