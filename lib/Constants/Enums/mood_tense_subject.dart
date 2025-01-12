import 'package:my_dic/Constants/Enums/subject.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';

class MoodTenseSubject {
  final MoodTense tense;
  final Subject subject;

  MoodTenseSubject(this.tense, this.subject);

  @override
  String toString() {
    return '${tense.jap} - ${subject.name}';
  }

  String toColumnString() {
    return '${tense.jap} - ${subject.name}';
  }

  String toConjCol(MoodTense tense, Subject subject) {
    return tense.shorten + subject.name;
  }
}
