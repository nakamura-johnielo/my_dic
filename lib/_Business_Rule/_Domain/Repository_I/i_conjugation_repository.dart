import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

abstract class IConjugacionsRepository {
  Future<Conjugacions?> getConjugacionByWordId(int id);
  //Future<List<Conjugacions>> getAllConjugacions();
  //Future<List<Conjugacions>> getSpecificTenseConjugacions();
}
