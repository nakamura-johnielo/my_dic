import 'package:flutter/material.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';

class ConjugacionCard extends StatelessWidget {
  final MoodTense moodTense;
  final TenseConjugacion conjugacion;

  static const Color subjectColor = Color.fromARGB(255, 62, 62, 62);
  static const Color conjColor = Colors.black;
  //final IconData icon;
  const ConjugacionCard(
      {super.key, required this.moodTense, required this.conjugacion});

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
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Tu",
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "El",
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Nosotros",
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Vosotros",
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Ellos",
                        style: TextStyle(fontSize: 16, color: subjectColor),
                        textAlign: TextAlign.center,
                      ),
                    ]),
              ),
              SizedBox(width: 20),
              // conjugacion
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  conjugacion.yo,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                Text(
                  conjugacion.tu,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                Text(
                  conjugacion.el,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                Text(
                  conjugacion.nosotros,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                Text(
                  conjugacion.vosotros,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                Text(
                  conjugacion.ellos,
                  style: TextStyle(fontSize: 16, color: conjColor),
                  textAlign: TextAlign.left,
                ),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}
