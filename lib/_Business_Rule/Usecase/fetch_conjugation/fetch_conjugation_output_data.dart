import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

class FetchConjugationOutputData {
  Conjugacions? conjugacions;
  int wordId;
  FetchConjugationOutputData(this.conjugacions, this.wordId);
}
