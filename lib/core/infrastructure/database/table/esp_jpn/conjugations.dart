import 'package:drift/drift.dart';

@DataClassName('EspConjugationTableData')
class EspConjugations extends Table {

  @override
  String get tableName => 'conjugations';
  
  IntColumn get wordId =>
      integer().named('word_id')(); // リレーションを簡単に記述// 外部キー制約をカラムに直接設定
  TextColumn get word => text().named('word')();
  TextColumn get meaning => text().named('meaning').nullable()();
  TextColumn get presentParticiple =>
      text().named('present_participle').nullable()();
  TextColumn get pastParticiple =>
      text().named('past_participle').nullable()();
  TextColumn get indicativePresentYo =>
      text().named('indicative_present_yo').nullable()();
  TextColumn get indicativePresentTu =>
      text().named('indicative_present_tu').nullable()();
  TextColumn get indicativePresentEl =>
      text().named('indicative_present_el').nullable()();
  TextColumn get indicativePresentNosotros =>
      text().named('indicative_present_nosotros').nullable()();
  TextColumn get indicativePresentVosotros =>
      text().named('indicative_present_vosotros').nullable()();
  TextColumn get indicativePresentEllos =>
      text().named('indicative_present_ellos').nullable()();
  TextColumn get indicativePreteriteYo =>
      text().named('indicative_preterite_yo').nullable()();
  TextColumn get indicativePreteriteTu =>
      text().named('indicative_preterite_tu').nullable()();
  TextColumn get indicativePreteriteEl =>
      text().named('indicative_preterite_el').nullable()();
  TextColumn get indicativePreteriteNosotros =>
      text().named('indicative_preterite_nosotros').nullable()();
  TextColumn get indicativePreteriteVosotros =>
      text().named('indicative_preterite_vosotros').nullable()();
  TextColumn get indicativePreteriteEllos =>
      text().named('indicative_preterite_ellos').nullable()();
  TextColumn get indicativeImperfectYo =>
      text().named('indicative_imperfect_yo').nullable()();
  TextColumn get indicativeImperfectTu =>
      text().named('indicative_imperfect_tu').nullable()();
  TextColumn get indicativeImperfectEl =>
      text().named('indicative_imperfect_el').nullable()();
  TextColumn get indicativeImperfectNosotros =>
      text().named('indicative_imperfect_nosotros').nullable()();
  TextColumn get indicativeImperfectVosotros =>
      text().named('indicative_imperfect_vosotros').nullable()();
  TextColumn get indicativeImperfectEllos =>
      text().named('indicative_imperfect_ellos').nullable()();
  TextColumn get indicativeFutureYo =>
      text().named('indicative_future_yo').nullable()();
  TextColumn get indicativeFutureTu =>
      text().named('indicative_future_tu').nullable()();
  TextColumn get indicativeFutureEl =>
      text().named('indicative_future_el').nullable()();
  TextColumn get indicativeFutureNosotros =>
      text().named('indicative_future_nosotros').nullable()();
  TextColumn get indicativeFutureVosotros =>
      text().named('indicative_future_vosotros').nullable()();
  TextColumn get indicativeFutureEllos =>
      text().named('indicative_future_ellos').nullable()();
  TextColumn get indicativeConditionalYo =>
      text().named('indicative_conditional_yo').nullable()();
  TextColumn get indicativeConditionalTu =>
      text().named('indicative_conditional_tu').nullable()();
  TextColumn get indicativeConditionalEl =>
      text().named('indicative_conditional_el').nullable()();
  TextColumn get indicativeConditionalNosotros =>
      text().named('indicative_conditional_nosotros').nullable()();
  TextColumn get indicativeConditionalVosotros =>
      text().named('indicative_conditional_vosotros').nullable()();
  TextColumn get indicativeConditionalEllos =>
      text().named('indicative_conditional_ellos').nullable()();
  TextColumn get imperativeTu => text().named('imperative_tu').nullable()();
  TextColumn get imperativeEl => text().named('imperative_el').nullable()();
  TextColumn get imperativeNosotros =>
      text().named('imperative_nosotros').nullable()();
  TextColumn get imperativeVosotros =>
      text().named('imperative_vosotros').nullable()();
  TextColumn get imperativeEllos =>
      text().named('imperative_ellos').nullable()();
  TextColumn get subjunctivePresentYo =>
      text().named('subjunctive_present_yo').nullable()();
  TextColumn get subjunctivePresentTu =>
      text().named('subjunctive_present_tu').nullable()();
  TextColumn get subjunctivePresentEl =>
      text().named('subjunctive_present_el').nullable()();
  TextColumn get subjunctivePresentNosotros =>
      text().named('subjunctive_present_nosotros').nullable()();
  TextColumn get subjunctivePresentVosotros =>
      text().named('subjunctive_present_vosotros').nullable()();
  TextColumn get subjunctivePresentEllos =>
      text().named('subjunctive_present_ellos').nullable()();
  TextColumn get subjunctivePastYo =>
      text().named('subjunctive_past_yo').nullable()();
  TextColumn get subjunctivePastTu =>
      text().named('subjunctive_past_tu').nullable()();
  TextColumn get subjunctivePastEl =>
      text().named('subjunctive_past_el').nullable()();
  TextColumn get subjunctivePastNosotros =>
      text().named('subjunctive_past_nosotros').nullable()();
  TextColumn get subjunctivePastVosotros =>
      text().named('subjunctive_past_vosotros').nullable()();
  TextColumn get subjunctivePastEllos =>
      text().named('subjunctive_past_ellos').nullable()();

  @override
  Set<Column> get primaryKey => {wordId};

  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY(word_id) REFERENCES words(word_id)'];
}
