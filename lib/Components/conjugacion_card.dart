import 'package:flutter/material.dart';
import 'package:my_dic/core/common/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/tense_conjugacion.dart';

class ConjugacionCard extends StatelessWidget {
  final MoodTense moodTense;
  final TenseConjugacion conjugacion;
  final String query;

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Colors.black;
  //final IconData icon;
  const ConjugacionCard(
      {super.key,
      required this.moodTense,
      required this.conjugacion,
      this.query = ""});

  Widget _highlightMatch(BuildContext context, String text, String query) {
    if (query.isEmpty) {
      return Text(text,
          style: TextStyle(
            fontSize: 16, //color: conjColor
          ),
          textAlign: TextAlign.left);
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start < 0) {
      return Text(text,
          style: TextStyle(
            fontSize: 16, //color: conjColor
          ),
          textAlign: TextAlign.left);
    }
    final end = start + query.length;
    //完全一致か部分一致か
    Color highlightColor = text.length == query.length
        ? Theme.of(context).colorScheme.primary //Colors.indigo[200]!
        : Theme.of(context).colorScheme.primary.withOpacity(0.5);
    Color? highlightTextColor = text.length == query.length
        ? Theme.of(context).colorScheme.onPrimary //Colors.indigo[200]!
        : null;
    //Theme.of(context).colorScheme.onPrimary;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16, //color: conjColor
        ),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
                backgroundColor: highlightColor, color: highlightTextColor),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "【${moodTense.moodName}】 ${moodTense.tenseName}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(children: [
              // Subject
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yo",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Tu",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "El",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Nosotros",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Vosotros",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Ellos",
                        style: TextStyle(
                          fontSize: 16, //color: subjectColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]),
              ),
              SizedBox(width: 20),
              // conjugacion
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _highlightMatch(context, conjugacion.yo, query),
                SizedBox(height: 5),
                _highlightMatch(context, conjugacion.tu, query),
                SizedBox(height: 5),
                _highlightMatch(context, conjugacion.el, query),
                SizedBox(height: 5),
                _highlightMatch(context, conjugacion.nosotros, query),
                SizedBox(height: 5),
                _highlightMatch(context, conjugacion.vosotros, query),
                SizedBox(height: 5),
                _highlightMatch(context, conjugacion.ellos, query),

                // Text(
                //   conjugacion.yo,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
                // SizedBox(height: 5),
                // Text(
                //   conjugacion.tu,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
                // SizedBox(height: 5),
                // Text(
                //   conjugacion.el,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
                // SizedBox(height: 5),
                // Text(
                //   conjugacion.nosotros,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
                // SizedBox(height: 5),
                // Text(
                //   conjugacion.vosotros,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
                // SizedBox(height: 5),
                // Text(
                //   conjugacion.ellos,
                //   style: TextStyle(fontSize: 16, color: conjColor),
                //   textAlign: TextAlign.left,
                // ),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}

class ParticipleCard extends StatelessWidget {
  final MoodTense moodTense;
  final String conjugacion;
  final String query;

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Colors.black;
  //final IconData icon;
  const ParticipleCard(
      {super.key,
      required this.moodTense,
      required this.conjugacion,
      this.query = ""});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Row(
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              moodTense.jap,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              conjugacion,
              style: TextStyle(
                fontSize: 16, //color: conjColor
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
