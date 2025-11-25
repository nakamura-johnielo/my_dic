// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../_Framework_Driver/local/drift/database_provider.dart';

// ignore_for_file: type=lint
class $ConjugationsTable extends Conjugations
    with TableInfo<$ConjugationsTable, Conjugation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConjugationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _meaningMeta =
      const VerificationMeta('meaning');
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
      'meaning', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _presentParticipleMeta =
      const VerificationMeta('presentParticiple');
  @override
  late final GeneratedColumn<String> presentParticiple =
      GeneratedColumn<String>('present_participle', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prastParticipleMeta =
      const VerificationMeta('prastParticiple');
  @override
  late final GeneratedColumn<String> prastParticiple = GeneratedColumn<String>(
      'past_participle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentYoMeta =
      const VerificationMeta('indicativePresentYo');
  @override
  late final GeneratedColumn<String> indicativePresentYo =
      GeneratedColumn<String>('indicative_present_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentTuMeta =
      const VerificationMeta('indicativePresentTu');
  @override
  late final GeneratedColumn<String> indicativePresentTu =
      GeneratedColumn<String>('indicative_present_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentElMeta =
      const VerificationMeta('indicativePresentEl');
  @override
  late final GeneratedColumn<String> indicativePresentEl =
      GeneratedColumn<String>('indicative_present_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentNosotrosMeta =
      const VerificationMeta('indicativePresentNosotros');
  @override
  late final GeneratedColumn<String> indicativePresentNosotros =
      GeneratedColumn<String>('indicative_present_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentVosotrosMeta =
      const VerificationMeta('indicativePresentVosotros');
  @override
  late final GeneratedColumn<String> indicativePresentVosotros =
      GeneratedColumn<String>('indicative_present_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePresentEllosMeta =
      const VerificationMeta('indicativePresentEllos');
  @override
  late final GeneratedColumn<String> indicativePresentEllos =
      GeneratedColumn<String>('indicative_present_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteYoMeta =
      const VerificationMeta('indicativePreteriteYo');
  @override
  late final GeneratedColumn<String> indicativePreteriteYo =
      GeneratedColumn<String>('indicative_preterite_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteTuMeta =
      const VerificationMeta('indicativePreteriteTu');
  @override
  late final GeneratedColumn<String> indicativePreteriteTu =
      GeneratedColumn<String>('indicative_preterite_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteElMeta =
      const VerificationMeta('indicativePreteriteEl');
  @override
  late final GeneratedColumn<String> indicativePreteriteEl =
      GeneratedColumn<String>('indicative_preterite_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteNosotrosMeta =
      const VerificationMeta('indicativePreteriteNosotros');
  @override
  late final GeneratedColumn<String> indicativePreteriteNosotros =
      GeneratedColumn<String>(
          'indicative_preterite_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteVosotrosMeta =
      const VerificationMeta('indicativePreteriteVosotros');
  @override
  late final GeneratedColumn<String> indicativePreteriteVosotros =
      GeneratedColumn<String>(
          'indicative_preterite_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativePreteriteEllosMeta =
      const VerificationMeta('indicativePreteriteEllos');
  @override
  late final GeneratedColumn<String> indicativePreteriteEllos =
      GeneratedColumn<String>('indicative_preterite_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectYoMeta =
      const VerificationMeta('indicativeImperfectYo');
  @override
  late final GeneratedColumn<String> indicativeImperfectYo =
      GeneratedColumn<String>('indicative_imperfect_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectTuMeta =
      const VerificationMeta('indicativeImperfectTu');
  @override
  late final GeneratedColumn<String> indicativeImperfectTu =
      GeneratedColumn<String>('indicative_imperfect_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectElMeta =
      const VerificationMeta('indicativeImperfectEl');
  @override
  late final GeneratedColumn<String> indicativeImperfectEl =
      GeneratedColumn<String>('indicative_imperfect_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectNosotrosMeta =
      const VerificationMeta('indicativeImperfectNosotros');
  @override
  late final GeneratedColumn<String> indicativeImperfectNosotros =
      GeneratedColumn<String>(
          'indicative_imperfect_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectVosotrosMeta =
      const VerificationMeta('indicativeImperfectVosotros');
  @override
  late final GeneratedColumn<String> indicativeImperfectVosotros =
      GeneratedColumn<String>(
          'indicative_imperfect_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeImperfectEllosMeta =
      const VerificationMeta('indicativeImperfectEllos');
  @override
  late final GeneratedColumn<String> indicativeImperfectEllos =
      GeneratedColumn<String>('indicative_imperfect_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureYoMeta =
      const VerificationMeta('indicativeFutureYo');
  @override
  late final GeneratedColumn<String> indicativeFutureYo =
      GeneratedColumn<String>('indicative_future_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureTuMeta =
      const VerificationMeta('indicativeFutureTu');
  @override
  late final GeneratedColumn<String> indicativeFutureTu =
      GeneratedColumn<String>('indicative_future_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureElMeta =
      const VerificationMeta('indicativeFutureEl');
  @override
  late final GeneratedColumn<String> indicativeFutureEl =
      GeneratedColumn<String>('indicative_future_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureNosotrosMeta =
      const VerificationMeta('indicativeFutureNosotros');
  @override
  late final GeneratedColumn<String> indicativeFutureNosotros =
      GeneratedColumn<String>('indicative_future_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureVosotrosMeta =
      const VerificationMeta('indicativeFutureVosotros');
  @override
  late final GeneratedColumn<String> indicativeFutureVosotros =
      GeneratedColumn<String>('indicative_future_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeFutureEllosMeta =
      const VerificationMeta('indicativeFutureEllos');
  @override
  late final GeneratedColumn<String> indicativeFutureEllos =
      GeneratedColumn<String>('indicative_future_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalYoMeta =
      const VerificationMeta('indicativeConditionalYo');
  @override
  late final GeneratedColumn<String> indicativeConditionalYo =
      GeneratedColumn<String>('indicative_conditional_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalTuMeta =
      const VerificationMeta('indicativeConditionalTu');
  @override
  late final GeneratedColumn<String> indicativeConditionalTu =
      GeneratedColumn<String>('indicative_conditional_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalElMeta =
      const VerificationMeta('indicativeConditionalEl');
  @override
  late final GeneratedColumn<String> indicativeConditionalEl =
      GeneratedColumn<String>('indicative_conditional_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalNosotrosMeta =
      const VerificationMeta('indicativeConditionalNosotros');
  @override
  late final GeneratedColumn<String> indicativeConditionalNosotros =
      GeneratedColumn<String>(
          'indicative_conditional_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalVosotrosMeta =
      const VerificationMeta('indicativeConditionalVosotros');
  @override
  late final GeneratedColumn<String> indicativeConditionalVosotros =
      GeneratedColumn<String>(
          'indicative_conditional_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _indicativeConditionalEllosMeta =
      const VerificationMeta('indicativeConditionalEllos');
  @override
  late final GeneratedColumn<String> indicativeConditionalEllos =
      GeneratedColumn<String>('indicative_conditional_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imperativeTuMeta =
      const VerificationMeta('imperativeTu');
  @override
  late final GeneratedColumn<String> imperativeTu = GeneratedColumn<String>(
      'imperative_tu', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imperativeElMeta =
      const VerificationMeta('imperativeEl');
  @override
  late final GeneratedColumn<String> imperativeEl = GeneratedColumn<String>(
      'imperative_el', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imperativeNosotrosMeta =
      const VerificationMeta('imperativeNosotros');
  @override
  late final GeneratedColumn<String> imperativeNosotros =
      GeneratedColumn<String>('imperative_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imperativeVosotrosMeta =
      const VerificationMeta('imperativeVosotros');
  @override
  late final GeneratedColumn<String> imperativeVosotros =
      GeneratedColumn<String>('imperative_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imperativeEllosMeta =
      const VerificationMeta('imperativeEllos');
  @override
  late final GeneratedColumn<String> imperativeEllos = GeneratedColumn<String>(
      'imperative_ellos', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentYoMeta =
      const VerificationMeta('subjunctivePresentYo');
  @override
  late final GeneratedColumn<String> subjunctivePresentYo =
      GeneratedColumn<String>('subjunctive_present_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentTuMeta =
      const VerificationMeta('subjunctivePresentTu');
  @override
  late final GeneratedColumn<String> subjunctivePresentTu =
      GeneratedColumn<String>('subjunctive_present_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentElMeta =
      const VerificationMeta('subjunctivePresentEl');
  @override
  late final GeneratedColumn<String> subjunctivePresentEl =
      GeneratedColumn<String>('subjunctive_present_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentNosotrosMeta =
      const VerificationMeta('subjunctivePresentNosotros');
  @override
  late final GeneratedColumn<String> subjunctivePresentNosotros =
      GeneratedColumn<String>('subjunctive_present_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentVosotrosMeta =
      const VerificationMeta('subjunctivePresentVosotros');
  @override
  late final GeneratedColumn<String> subjunctivePresentVosotros =
      GeneratedColumn<String>('subjunctive_present_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePresentEllosMeta =
      const VerificationMeta('subjunctivePresentEllos');
  @override
  late final GeneratedColumn<String> subjunctivePresentEllos =
      GeneratedColumn<String>('subjunctive_present_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastYoMeta =
      const VerificationMeta('subjunctivePastYo');
  @override
  late final GeneratedColumn<String> subjunctivePastYo =
      GeneratedColumn<String>('subjunctive_past_yo', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastTuMeta =
      const VerificationMeta('subjunctivePastTu');
  @override
  late final GeneratedColumn<String> subjunctivePastTu =
      GeneratedColumn<String>('subjunctive_past_tu', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastElMeta =
      const VerificationMeta('subjunctivePastEl');
  @override
  late final GeneratedColumn<String> subjunctivePastEl =
      GeneratedColumn<String>('subjunctive_past_el', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastNosotrosMeta =
      const VerificationMeta('subjunctivePastNosotros');
  @override
  late final GeneratedColumn<String> subjunctivePastNosotros =
      GeneratedColumn<String>('subjunctive_past_nosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastVosotrosMeta =
      const VerificationMeta('subjunctivePastVosotros');
  @override
  late final GeneratedColumn<String> subjunctivePastVosotros =
      GeneratedColumn<String>('subjunctive_past_vosotros', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjunctivePastEllosMeta =
      const VerificationMeta('subjunctivePastEllos');
  @override
  late final GeneratedColumn<String> subjunctivePastEllos =
      GeneratedColumn<String>('subjunctive_past_ellos', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        wordId,
        word,
        meaning,
        presentParticiple,
        prastParticiple,
        indicativePresentYo,
        indicativePresentTu,
        indicativePresentEl,
        indicativePresentNosotros,
        indicativePresentVosotros,
        indicativePresentEllos,
        indicativePreteriteYo,
        indicativePreteriteTu,
        indicativePreteriteEl,
        indicativePreteriteNosotros,
        indicativePreteriteVosotros,
        indicativePreteriteEllos,
        indicativeImperfectYo,
        indicativeImperfectTu,
        indicativeImperfectEl,
        indicativeImperfectNosotros,
        indicativeImperfectVosotros,
        indicativeImperfectEllos,
        indicativeFutureYo,
        indicativeFutureTu,
        indicativeFutureEl,
        indicativeFutureNosotros,
        indicativeFutureVosotros,
        indicativeFutureEllos,
        indicativeConditionalYo,
        indicativeConditionalTu,
        indicativeConditionalEl,
        indicativeConditionalNosotros,
        indicativeConditionalVosotros,
        indicativeConditionalEllos,
        imperativeTu,
        imperativeEl,
        imperativeNosotros,
        imperativeVosotros,
        imperativeEllos,
        subjunctivePresentYo,
        subjunctivePresentTu,
        subjunctivePresentEl,
        subjunctivePresentNosotros,
        subjunctivePresentVosotros,
        subjunctivePresentEllos,
        subjunctivePastYo,
        subjunctivePastTu,
        subjunctivePastEl,
        subjunctivePastNosotros,
        subjunctivePastVosotros,
        subjunctivePastEllos
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conjugations';
  @override
  VerificationContext validateIntegrity(Insertable<Conjugation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(_meaningMeta,
          meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta));
    }
    if (data.containsKey('present_participle')) {
      context.handle(
          _presentParticipleMeta,
          presentParticiple.isAcceptableOrUnknown(
              data['present_participle']!, _presentParticipleMeta));
    }
    if (data.containsKey('past_participle')) {
      context.handle(
          _prastParticipleMeta,
          prastParticiple.isAcceptableOrUnknown(
              data['past_participle']!, _prastParticipleMeta));
    }
    if (data.containsKey('indicative_present_yo')) {
      context.handle(
          _indicativePresentYoMeta,
          indicativePresentYo.isAcceptableOrUnknown(
              data['indicative_present_yo']!, _indicativePresentYoMeta));
    }
    if (data.containsKey('indicative_present_tu')) {
      context.handle(
          _indicativePresentTuMeta,
          indicativePresentTu.isAcceptableOrUnknown(
              data['indicative_present_tu']!, _indicativePresentTuMeta));
    }
    if (data.containsKey('indicative_present_el')) {
      context.handle(
          _indicativePresentElMeta,
          indicativePresentEl.isAcceptableOrUnknown(
              data['indicative_present_el']!, _indicativePresentElMeta));
    }
    if (data.containsKey('indicative_present_nosotros')) {
      context.handle(
          _indicativePresentNosotrosMeta,
          indicativePresentNosotros.isAcceptableOrUnknown(
              data['indicative_present_nosotros']!,
              _indicativePresentNosotrosMeta));
    }
    if (data.containsKey('indicative_present_vosotros')) {
      context.handle(
          _indicativePresentVosotrosMeta,
          indicativePresentVosotros.isAcceptableOrUnknown(
              data['indicative_present_vosotros']!,
              _indicativePresentVosotrosMeta));
    }
    if (data.containsKey('indicative_present_ellos')) {
      context.handle(
          _indicativePresentEllosMeta,
          indicativePresentEllos.isAcceptableOrUnknown(
              data['indicative_present_ellos']!, _indicativePresentEllosMeta));
    }
    if (data.containsKey('indicative_preterite_yo')) {
      context.handle(
          _indicativePreteriteYoMeta,
          indicativePreteriteYo.isAcceptableOrUnknown(
              data['indicative_preterite_yo']!, _indicativePreteriteYoMeta));
    }
    if (data.containsKey('indicative_preterite_tu')) {
      context.handle(
          _indicativePreteriteTuMeta,
          indicativePreteriteTu.isAcceptableOrUnknown(
              data['indicative_preterite_tu']!, _indicativePreteriteTuMeta));
    }
    if (data.containsKey('indicative_preterite_el')) {
      context.handle(
          _indicativePreteriteElMeta,
          indicativePreteriteEl.isAcceptableOrUnknown(
              data['indicative_preterite_el']!, _indicativePreteriteElMeta));
    }
    if (data.containsKey('indicative_preterite_nosotros')) {
      context.handle(
          _indicativePreteriteNosotrosMeta,
          indicativePreteriteNosotros.isAcceptableOrUnknown(
              data['indicative_preterite_nosotros']!,
              _indicativePreteriteNosotrosMeta));
    }
    if (data.containsKey('indicative_preterite_vosotros')) {
      context.handle(
          _indicativePreteriteVosotrosMeta,
          indicativePreteriteVosotros.isAcceptableOrUnknown(
              data['indicative_preterite_vosotros']!,
              _indicativePreteriteVosotrosMeta));
    }
    if (data.containsKey('indicative_preterite_ellos')) {
      context.handle(
          _indicativePreteriteEllosMeta,
          indicativePreteriteEllos.isAcceptableOrUnknown(
              data['indicative_preterite_ellos']!,
              _indicativePreteriteEllosMeta));
    }
    if (data.containsKey('indicative_imperfect_yo')) {
      context.handle(
          _indicativeImperfectYoMeta,
          indicativeImperfectYo.isAcceptableOrUnknown(
              data['indicative_imperfect_yo']!, _indicativeImperfectYoMeta));
    }
    if (data.containsKey('indicative_imperfect_tu')) {
      context.handle(
          _indicativeImperfectTuMeta,
          indicativeImperfectTu.isAcceptableOrUnknown(
              data['indicative_imperfect_tu']!, _indicativeImperfectTuMeta));
    }
    if (data.containsKey('indicative_imperfect_el')) {
      context.handle(
          _indicativeImperfectElMeta,
          indicativeImperfectEl.isAcceptableOrUnknown(
              data['indicative_imperfect_el']!, _indicativeImperfectElMeta));
    }
    if (data.containsKey('indicative_imperfect_nosotros')) {
      context.handle(
          _indicativeImperfectNosotrosMeta,
          indicativeImperfectNosotros.isAcceptableOrUnknown(
              data['indicative_imperfect_nosotros']!,
              _indicativeImperfectNosotrosMeta));
    }
    if (data.containsKey('indicative_imperfect_vosotros')) {
      context.handle(
          _indicativeImperfectVosotrosMeta,
          indicativeImperfectVosotros.isAcceptableOrUnknown(
              data['indicative_imperfect_vosotros']!,
              _indicativeImperfectVosotrosMeta));
    }
    if (data.containsKey('indicative_imperfect_ellos')) {
      context.handle(
          _indicativeImperfectEllosMeta,
          indicativeImperfectEllos.isAcceptableOrUnknown(
              data['indicative_imperfect_ellos']!,
              _indicativeImperfectEllosMeta));
    }
    if (data.containsKey('indicative_future_yo')) {
      context.handle(
          _indicativeFutureYoMeta,
          indicativeFutureYo.isAcceptableOrUnknown(
              data['indicative_future_yo']!, _indicativeFutureYoMeta));
    }
    if (data.containsKey('indicative_future_tu')) {
      context.handle(
          _indicativeFutureTuMeta,
          indicativeFutureTu.isAcceptableOrUnknown(
              data['indicative_future_tu']!, _indicativeFutureTuMeta));
    }
    if (data.containsKey('indicative_future_el')) {
      context.handle(
          _indicativeFutureElMeta,
          indicativeFutureEl.isAcceptableOrUnknown(
              data['indicative_future_el']!, _indicativeFutureElMeta));
    }
    if (data.containsKey('indicative_future_nosotros')) {
      context.handle(
          _indicativeFutureNosotrosMeta,
          indicativeFutureNosotros.isAcceptableOrUnknown(
              data['indicative_future_nosotros']!,
              _indicativeFutureNosotrosMeta));
    }
    if (data.containsKey('indicative_future_vosotros')) {
      context.handle(
          _indicativeFutureVosotrosMeta,
          indicativeFutureVosotros.isAcceptableOrUnknown(
              data['indicative_future_vosotros']!,
              _indicativeFutureVosotrosMeta));
    }
    if (data.containsKey('indicative_future_ellos')) {
      context.handle(
          _indicativeFutureEllosMeta,
          indicativeFutureEllos.isAcceptableOrUnknown(
              data['indicative_future_ellos']!, _indicativeFutureEllosMeta));
    }
    if (data.containsKey('indicative_conditional_yo')) {
      context.handle(
          _indicativeConditionalYoMeta,
          indicativeConditionalYo.isAcceptableOrUnknown(
              data['indicative_conditional_yo']!,
              _indicativeConditionalYoMeta));
    }
    if (data.containsKey('indicative_conditional_tu')) {
      context.handle(
          _indicativeConditionalTuMeta,
          indicativeConditionalTu.isAcceptableOrUnknown(
              data['indicative_conditional_tu']!,
              _indicativeConditionalTuMeta));
    }
    if (data.containsKey('indicative_conditional_el')) {
      context.handle(
          _indicativeConditionalElMeta,
          indicativeConditionalEl.isAcceptableOrUnknown(
              data['indicative_conditional_el']!,
              _indicativeConditionalElMeta));
    }
    if (data.containsKey('indicative_conditional_nosotros')) {
      context.handle(
          _indicativeConditionalNosotrosMeta,
          indicativeConditionalNosotros.isAcceptableOrUnknown(
              data['indicative_conditional_nosotros']!,
              _indicativeConditionalNosotrosMeta));
    }
    if (data.containsKey('indicative_conditional_vosotros')) {
      context.handle(
          _indicativeConditionalVosotrosMeta,
          indicativeConditionalVosotros.isAcceptableOrUnknown(
              data['indicative_conditional_vosotros']!,
              _indicativeConditionalVosotrosMeta));
    }
    if (data.containsKey('indicative_conditional_ellos')) {
      context.handle(
          _indicativeConditionalEllosMeta,
          indicativeConditionalEllos.isAcceptableOrUnknown(
              data['indicative_conditional_ellos']!,
              _indicativeConditionalEllosMeta));
    }
    if (data.containsKey('imperative_tu')) {
      context.handle(
          _imperativeTuMeta,
          imperativeTu.isAcceptableOrUnknown(
              data['imperative_tu']!, _imperativeTuMeta));
    }
    if (data.containsKey('imperative_el')) {
      context.handle(
          _imperativeElMeta,
          imperativeEl.isAcceptableOrUnknown(
              data['imperative_el']!, _imperativeElMeta));
    }
    if (data.containsKey('imperative_nosotros')) {
      context.handle(
          _imperativeNosotrosMeta,
          imperativeNosotros.isAcceptableOrUnknown(
              data['imperative_nosotros']!, _imperativeNosotrosMeta));
    }
    if (data.containsKey('imperative_vosotros')) {
      context.handle(
          _imperativeVosotrosMeta,
          imperativeVosotros.isAcceptableOrUnknown(
              data['imperative_vosotros']!, _imperativeVosotrosMeta));
    }
    if (data.containsKey('imperative_ellos')) {
      context.handle(
          _imperativeEllosMeta,
          imperativeEllos.isAcceptableOrUnknown(
              data['imperative_ellos']!, _imperativeEllosMeta));
    }
    if (data.containsKey('subjunctive_present_yo')) {
      context.handle(
          _subjunctivePresentYoMeta,
          subjunctivePresentYo.isAcceptableOrUnknown(
              data['subjunctive_present_yo']!, _subjunctivePresentYoMeta));
    }
    if (data.containsKey('subjunctive_present_tu')) {
      context.handle(
          _subjunctivePresentTuMeta,
          subjunctivePresentTu.isAcceptableOrUnknown(
              data['subjunctive_present_tu']!, _subjunctivePresentTuMeta));
    }
    if (data.containsKey('subjunctive_present_el')) {
      context.handle(
          _subjunctivePresentElMeta,
          subjunctivePresentEl.isAcceptableOrUnknown(
              data['subjunctive_present_el']!, _subjunctivePresentElMeta));
    }
    if (data.containsKey('subjunctive_present_nosotros')) {
      context.handle(
          _subjunctivePresentNosotrosMeta,
          subjunctivePresentNosotros.isAcceptableOrUnknown(
              data['subjunctive_present_nosotros']!,
              _subjunctivePresentNosotrosMeta));
    }
    if (data.containsKey('subjunctive_present_vosotros')) {
      context.handle(
          _subjunctivePresentVosotrosMeta,
          subjunctivePresentVosotros.isAcceptableOrUnknown(
              data['subjunctive_present_vosotros']!,
              _subjunctivePresentVosotrosMeta));
    }
    if (data.containsKey('subjunctive_present_ellos')) {
      context.handle(
          _subjunctivePresentEllosMeta,
          subjunctivePresentEllos.isAcceptableOrUnknown(
              data['subjunctive_present_ellos']!,
              _subjunctivePresentEllosMeta));
    }
    if (data.containsKey('subjunctive_past_yo')) {
      context.handle(
          _subjunctivePastYoMeta,
          subjunctivePastYo.isAcceptableOrUnknown(
              data['subjunctive_past_yo']!, _subjunctivePastYoMeta));
    }
    if (data.containsKey('subjunctive_past_tu')) {
      context.handle(
          _subjunctivePastTuMeta,
          subjunctivePastTu.isAcceptableOrUnknown(
              data['subjunctive_past_tu']!, _subjunctivePastTuMeta));
    }
    if (data.containsKey('subjunctive_past_el')) {
      context.handle(
          _subjunctivePastElMeta,
          subjunctivePastEl.isAcceptableOrUnknown(
              data['subjunctive_past_el']!, _subjunctivePastElMeta));
    }
    if (data.containsKey('subjunctive_past_nosotros')) {
      context.handle(
          _subjunctivePastNosotrosMeta,
          subjunctivePastNosotros.isAcceptableOrUnknown(
              data['subjunctive_past_nosotros']!,
              _subjunctivePastNosotrosMeta));
    }
    if (data.containsKey('subjunctive_past_vosotros')) {
      context.handle(
          _subjunctivePastVosotrosMeta,
          subjunctivePastVosotros.isAcceptableOrUnknown(
              data['subjunctive_past_vosotros']!,
              _subjunctivePastVosotrosMeta));
    }
    if (data.containsKey('subjunctive_past_ellos')) {
      context.handle(
          _subjunctivePastEllosMeta,
          subjunctivePastEllos.isAcceptableOrUnknown(
              data['subjunctive_past_ellos']!, _subjunctivePastEllosMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  Conjugation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conjugation(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      meaning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meaning']),
      presentParticiple: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}present_participle']),
      prastParticiple: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}past_participle']),
      indicativePresentYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_present_yo']),
      indicativePresentTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_present_tu']),
      indicativePresentEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_present_el']),
      indicativePresentNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_present_nosotros']),
      indicativePresentVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_present_vosotros']),
      indicativePresentEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_present_ellos']),
      indicativePreteriteYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_yo']),
      indicativePreteriteTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_tu']),
      indicativePreteriteEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_el']),
      indicativePreteriteNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_nosotros']),
      indicativePreteriteVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_vosotros']),
      indicativePreteriteEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_preterite_ellos']),
      indicativeImperfectYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_yo']),
      indicativeImperfectTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_tu']),
      indicativeImperfectEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_el']),
      indicativeImperfectNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_nosotros']),
      indicativeImperfectVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_vosotros']),
      indicativeImperfectEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_imperfect_ellos']),
      indicativeFutureYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_future_yo']),
      indicativeFutureTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_future_tu']),
      indicativeFutureEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}indicative_future_el']),
      indicativeFutureNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_future_nosotros']),
      indicativeFutureVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_future_vosotros']),
      indicativeFutureEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_future_ellos']),
      indicativeConditionalYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_yo']),
      indicativeConditionalTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_tu']),
      indicativeConditionalEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_el']),
      indicativeConditionalNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_nosotros']),
      indicativeConditionalVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_vosotros']),
      indicativeConditionalEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}indicative_conditional_ellos']),
      imperativeTu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imperative_tu']),
      imperativeEl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imperative_el']),
      imperativeNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}imperative_nosotros']),
      imperativeVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}imperative_vosotros']),
      imperativeEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}imperative_ellos']),
      subjunctivePresentYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_yo']),
      subjunctivePresentTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_tu']),
      subjunctivePresentEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_el']),
      subjunctivePresentNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_nosotros']),
      subjunctivePresentVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_vosotros']),
      subjunctivePresentEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_present_ellos']),
      subjunctivePastYo: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subjunctive_past_yo']),
      subjunctivePastTu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subjunctive_past_tu']),
      subjunctivePastEl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subjunctive_past_el']),
      subjunctivePastNosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_past_nosotros']),
      subjunctivePastVosotros: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_past_vosotros']),
      subjunctivePastEllos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subjunctive_past_ellos']),
    );
  }

  @override
  $ConjugationsTable createAlias(String alias) {
    return $ConjugationsTable(attachedDatabase, alias);
  }
}

class Conjugation extends DataClass implements Insertable<Conjugation> {
  final int wordId;
  final String word;
  final String? meaning;
  final String? presentParticiple;
  final String? prastParticiple;
  final String? indicativePresentYo;
  final String? indicativePresentTu;
  final String? indicativePresentEl;
  final String? indicativePresentNosotros;
  final String? indicativePresentVosotros;
  final String? indicativePresentEllos;
  final String? indicativePreteriteYo;
  final String? indicativePreteriteTu;
  final String? indicativePreteriteEl;
  final String? indicativePreteriteNosotros;
  final String? indicativePreteriteVosotros;
  final String? indicativePreteriteEllos;
  final String? indicativeImperfectYo;
  final String? indicativeImperfectTu;
  final String? indicativeImperfectEl;
  final String? indicativeImperfectNosotros;
  final String? indicativeImperfectVosotros;
  final String? indicativeImperfectEllos;
  final String? indicativeFutureYo;
  final String? indicativeFutureTu;
  final String? indicativeFutureEl;
  final String? indicativeFutureNosotros;
  final String? indicativeFutureVosotros;
  final String? indicativeFutureEllos;
  final String? indicativeConditionalYo;
  final String? indicativeConditionalTu;
  final String? indicativeConditionalEl;
  final String? indicativeConditionalNosotros;
  final String? indicativeConditionalVosotros;
  final String? indicativeConditionalEllos;
  final String? imperativeTu;
  final String? imperativeEl;
  final String? imperativeNosotros;
  final String? imperativeVosotros;
  final String? imperativeEllos;
  final String? subjunctivePresentYo;
  final String? subjunctivePresentTu;
  final String? subjunctivePresentEl;
  final String? subjunctivePresentNosotros;
  final String? subjunctivePresentVosotros;
  final String? subjunctivePresentEllos;
  final String? subjunctivePastYo;
  final String? subjunctivePastTu;
  final String? subjunctivePastEl;
  final String? subjunctivePastNosotros;
  final String? subjunctivePastVosotros;
  final String? subjunctivePastEllos;
  const Conjugation(
      {required this.wordId,
      required this.word,
      this.meaning,
      this.presentParticiple,
      this.prastParticiple,
      this.indicativePresentYo,
      this.indicativePresentTu,
      this.indicativePresentEl,
      this.indicativePresentNosotros,
      this.indicativePresentVosotros,
      this.indicativePresentEllos,
      this.indicativePreteriteYo,
      this.indicativePreteriteTu,
      this.indicativePreteriteEl,
      this.indicativePreteriteNosotros,
      this.indicativePreteriteVosotros,
      this.indicativePreteriteEllos,
      this.indicativeImperfectYo,
      this.indicativeImperfectTu,
      this.indicativeImperfectEl,
      this.indicativeImperfectNosotros,
      this.indicativeImperfectVosotros,
      this.indicativeImperfectEllos,
      this.indicativeFutureYo,
      this.indicativeFutureTu,
      this.indicativeFutureEl,
      this.indicativeFutureNosotros,
      this.indicativeFutureVosotros,
      this.indicativeFutureEllos,
      this.indicativeConditionalYo,
      this.indicativeConditionalTu,
      this.indicativeConditionalEl,
      this.indicativeConditionalNosotros,
      this.indicativeConditionalVosotros,
      this.indicativeConditionalEllos,
      this.imperativeTu,
      this.imperativeEl,
      this.imperativeNosotros,
      this.imperativeVosotros,
      this.imperativeEllos,
      this.subjunctivePresentYo,
      this.subjunctivePresentTu,
      this.subjunctivePresentEl,
      this.subjunctivePresentNosotros,
      this.subjunctivePresentVosotros,
      this.subjunctivePresentEllos,
      this.subjunctivePastYo,
      this.subjunctivePastTu,
      this.subjunctivePastEl,
      this.subjunctivePastNosotros,
      this.subjunctivePastVosotros,
      this.subjunctivePastEllos});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || meaning != null) {
      map['meaning'] = Variable<String>(meaning);
    }
    if (!nullToAbsent || presentParticiple != null) {
      map['present_participle'] = Variable<String>(presentParticiple);
    }
    if (!nullToAbsent || prastParticiple != null) {
      map['past_participle'] = Variable<String>(prastParticiple);
    }
    if (!nullToAbsent || indicativePresentYo != null) {
      map['indicative_present_yo'] = Variable<String>(indicativePresentYo);
    }
    if (!nullToAbsent || indicativePresentTu != null) {
      map['indicative_present_tu'] = Variable<String>(indicativePresentTu);
    }
    if (!nullToAbsent || indicativePresentEl != null) {
      map['indicative_present_el'] = Variable<String>(indicativePresentEl);
    }
    if (!nullToAbsent || indicativePresentNosotros != null) {
      map['indicative_present_nosotros'] =
          Variable<String>(indicativePresentNosotros);
    }
    if (!nullToAbsent || indicativePresentVosotros != null) {
      map['indicative_present_vosotros'] =
          Variable<String>(indicativePresentVosotros);
    }
    if (!nullToAbsent || indicativePresentEllos != null) {
      map['indicative_present_ellos'] =
          Variable<String>(indicativePresentEllos);
    }
    if (!nullToAbsent || indicativePreteriteYo != null) {
      map['indicative_preterite_yo'] = Variable<String>(indicativePreteriteYo);
    }
    if (!nullToAbsent || indicativePreteriteTu != null) {
      map['indicative_preterite_tu'] = Variable<String>(indicativePreteriteTu);
    }
    if (!nullToAbsent || indicativePreteriteEl != null) {
      map['indicative_preterite_el'] = Variable<String>(indicativePreteriteEl);
    }
    if (!nullToAbsent || indicativePreteriteNosotros != null) {
      map['indicative_preterite_nosotros'] =
          Variable<String>(indicativePreteriteNosotros);
    }
    if (!nullToAbsent || indicativePreteriteVosotros != null) {
      map['indicative_preterite_vosotros'] =
          Variable<String>(indicativePreteriteVosotros);
    }
    if (!nullToAbsent || indicativePreteriteEllos != null) {
      map['indicative_preterite_ellos'] =
          Variable<String>(indicativePreteriteEllos);
    }
    if (!nullToAbsent || indicativeImperfectYo != null) {
      map['indicative_imperfect_yo'] = Variable<String>(indicativeImperfectYo);
    }
    if (!nullToAbsent || indicativeImperfectTu != null) {
      map['indicative_imperfect_tu'] = Variable<String>(indicativeImperfectTu);
    }
    if (!nullToAbsent || indicativeImperfectEl != null) {
      map['indicative_imperfect_el'] = Variable<String>(indicativeImperfectEl);
    }
    if (!nullToAbsent || indicativeImperfectNosotros != null) {
      map['indicative_imperfect_nosotros'] =
          Variable<String>(indicativeImperfectNosotros);
    }
    if (!nullToAbsent || indicativeImperfectVosotros != null) {
      map['indicative_imperfect_vosotros'] =
          Variable<String>(indicativeImperfectVosotros);
    }
    if (!nullToAbsent || indicativeImperfectEllos != null) {
      map['indicative_imperfect_ellos'] =
          Variable<String>(indicativeImperfectEllos);
    }
    if (!nullToAbsent || indicativeFutureYo != null) {
      map['indicative_future_yo'] = Variable<String>(indicativeFutureYo);
    }
    if (!nullToAbsent || indicativeFutureTu != null) {
      map['indicative_future_tu'] = Variable<String>(indicativeFutureTu);
    }
    if (!nullToAbsent || indicativeFutureEl != null) {
      map['indicative_future_el'] = Variable<String>(indicativeFutureEl);
    }
    if (!nullToAbsent || indicativeFutureNosotros != null) {
      map['indicative_future_nosotros'] =
          Variable<String>(indicativeFutureNosotros);
    }
    if (!nullToAbsent || indicativeFutureVosotros != null) {
      map['indicative_future_vosotros'] =
          Variable<String>(indicativeFutureVosotros);
    }
    if (!nullToAbsent || indicativeFutureEllos != null) {
      map['indicative_future_ellos'] = Variable<String>(indicativeFutureEllos);
    }
    if (!nullToAbsent || indicativeConditionalYo != null) {
      map['indicative_conditional_yo'] =
          Variable<String>(indicativeConditionalYo);
    }
    if (!nullToAbsent || indicativeConditionalTu != null) {
      map['indicative_conditional_tu'] =
          Variable<String>(indicativeConditionalTu);
    }
    if (!nullToAbsent || indicativeConditionalEl != null) {
      map['indicative_conditional_el'] =
          Variable<String>(indicativeConditionalEl);
    }
    if (!nullToAbsent || indicativeConditionalNosotros != null) {
      map['indicative_conditional_nosotros'] =
          Variable<String>(indicativeConditionalNosotros);
    }
    if (!nullToAbsent || indicativeConditionalVosotros != null) {
      map['indicative_conditional_vosotros'] =
          Variable<String>(indicativeConditionalVosotros);
    }
    if (!nullToAbsent || indicativeConditionalEllos != null) {
      map['indicative_conditional_ellos'] =
          Variable<String>(indicativeConditionalEllos);
    }
    if (!nullToAbsent || imperativeTu != null) {
      map['imperative_tu'] = Variable<String>(imperativeTu);
    }
    if (!nullToAbsent || imperativeEl != null) {
      map['imperative_el'] = Variable<String>(imperativeEl);
    }
    if (!nullToAbsent || imperativeNosotros != null) {
      map['imperative_nosotros'] = Variable<String>(imperativeNosotros);
    }
    if (!nullToAbsent || imperativeVosotros != null) {
      map['imperative_vosotros'] = Variable<String>(imperativeVosotros);
    }
    if (!nullToAbsent || imperativeEllos != null) {
      map['imperative_ellos'] = Variable<String>(imperativeEllos);
    }
    if (!nullToAbsent || subjunctivePresentYo != null) {
      map['subjunctive_present_yo'] = Variable<String>(subjunctivePresentYo);
    }
    if (!nullToAbsent || subjunctivePresentTu != null) {
      map['subjunctive_present_tu'] = Variable<String>(subjunctivePresentTu);
    }
    if (!nullToAbsent || subjunctivePresentEl != null) {
      map['subjunctive_present_el'] = Variable<String>(subjunctivePresentEl);
    }
    if (!nullToAbsent || subjunctivePresentNosotros != null) {
      map['subjunctive_present_nosotros'] =
          Variable<String>(subjunctivePresentNosotros);
    }
    if (!nullToAbsent || subjunctivePresentVosotros != null) {
      map['subjunctive_present_vosotros'] =
          Variable<String>(subjunctivePresentVosotros);
    }
    if (!nullToAbsent || subjunctivePresentEllos != null) {
      map['subjunctive_present_ellos'] =
          Variable<String>(subjunctivePresentEllos);
    }
    if (!nullToAbsent || subjunctivePastYo != null) {
      map['subjunctive_past_yo'] = Variable<String>(subjunctivePastYo);
    }
    if (!nullToAbsent || subjunctivePastTu != null) {
      map['subjunctive_past_tu'] = Variable<String>(subjunctivePastTu);
    }
    if (!nullToAbsent || subjunctivePastEl != null) {
      map['subjunctive_past_el'] = Variable<String>(subjunctivePastEl);
    }
    if (!nullToAbsent || subjunctivePastNosotros != null) {
      map['subjunctive_past_nosotros'] =
          Variable<String>(subjunctivePastNosotros);
    }
    if (!nullToAbsent || subjunctivePastVosotros != null) {
      map['subjunctive_past_vosotros'] =
          Variable<String>(subjunctivePastVosotros);
    }
    if (!nullToAbsent || subjunctivePastEllos != null) {
      map['subjunctive_past_ellos'] = Variable<String>(subjunctivePastEllos);
    }
    return map;
  }

  ConjugationsCompanion toCompanion(bool nullToAbsent) {
    return ConjugationsCompanion(
      wordId: Value(wordId),
      word: Value(word),
      meaning: meaning == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning),
      presentParticiple: presentParticiple == null && nullToAbsent
          ? const Value.absent()
          : Value(presentParticiple),
      prastParticiple: prastParticiple == null && nullToAbsent
          ? const Value.absent()
          : Value(prastParticiple),
      indicativePresentYo: indicativePresentYo == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePresentYo),
      indicativePresentTu: indicativePresentTu == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePresentTu),
      indicativePresentEl: indicativePresentEl == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePresentEl),
      indicativePresentNosotros:
          indicativePresentNosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativePresentNosotros),
      indicativePresentVosotros:
          indicativePresentVosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativePresentVosotros),
      indicativePresentEllos: indicativePresentEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePresentEllos),
      indicativePreteriteYo: indicativePreteriteYo == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePreteriteYo),
      indicativePreteriteTu: indicativePreteriteTu == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePreteriteTu),
      indicativePreteriteEl: indicativePreteriteEl == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePreteriteEl),
      indicativePreteriteNosotros:
          indicativePreteriteNosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativePreteriteNosotros),
      indicativePreteriteVosotros:
          indicativePreteriteVosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativePreteriteVosotros),
      indicativePreteriteEllos: indicativePreteriteEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativePreteriteEllos),
      indicativeImperfectYo: indicativeImperfectYo == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeImperfectYo),
      indicativeImperfectTu: indicativeImperfectTu == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeImperfectTu),
      indicativeImperfectEl: indicativeImperfectEl == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeImperfectEl),
      indicativeImperfectNosotros:
          indicativeImperfectNosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativeImperfectNosotros),
      indicativeImperfectVosotros:
          indicativeImperfectVosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativeImperfectVosotros),
      indicativeImperfectEllos: indicativeImperfectEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeImperfectEllos),
      indicativeFutureYo: indicativeFutureYo == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureYo),
      indicativeFutureTu: indicativeFutureTu == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureTu),
      indicativeFutureEl: indicativeFutureEl == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureEl),
      indicativeFutureNosotros: indicativeFutureNosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureNosotros),
      indicativeFutureVosotros: indicativeFutureVosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureVosotros),
      indicativeFutureEllos: indicativeFutureEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeFutureEllos),
      indicativeConditionalYo: indicativeConditionalYo == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeConditionalYo),
      indicativeConditionalTu: indicativeConditionalTu == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeConditionalTu),
      indicativeConditionalEl: indicativeConditionalEl == null && nullToAbsent
          ? const Value.absent()
          : Value(indicativeConditionalEl),
      indicativeConditionalNosotros:
          indicativeConditionalNosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativeConditionalNosotros),
      indicativeConditionalVosotros:
          indicativeConditionalVosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativeConditionalVosotros),
      indicativeConditionalEllos:
          indicativeConditionalEllos == null && nullToAbsent
              ? const Value.absent()
              : Value(indicativeConditionalEllos),
      imperativeTu: imperativeTu == null && nullToAbsent
          ? const Value.absent()
          : Value(imperativeTu),
      imperativeEl: imperativeEl == null && nullToAbsent
          ? const Value.absent()
          : Value(imperativeEl),
      imperativeNosotros: imperativeNosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(imperativeNosotros),
      imperativeVosotros: imperativeVosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(imperativeVosotros),
      imperativeEllos: imperativeEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(imperativeEllos),
      subjunctivePresentYo: subjunctivePresentYo == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePresentYo),
      subjunctivePresentTu: subjunctivePresentTu == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePresentTu),
      subjunctivePresentEl: subjunctivePresentEl == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePresentEl),
      subjunctivePresentNosotros:
          subjunctivePresentNosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(subjunctivePresentNosotros),
      subjunctivePresentVosotros:
          subjunctivePresentVosotros == null && nullToAbsent
              ? const Value.absent()
              : Value(subjunctivePresentVosotros),
      subjunctivePresentEllos: subjunctivePresentEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePresentEllos),
      subjunctivePastYo: subjunctivePastYo == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastYo),
      subjunctivePastTu: subjunctivePastTu == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastTu),
      subjunctivePastEl: subjunctivePastEl == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastEl),
      subjunctivePastNosotros: subjunctivePastNosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastNosotros),
      subjunctivePastVosotros: subjunctivePastVosotros == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastVosotros),
      subjunctivePastEllos: subjunctivePastEllos == null && nullToAbsent
          ? const Value.absent()
          : Value(subjunctivePastEllos),
    );
  }

  factory Conjugation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conjugation(
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
      meaning: serializer.fromJson<String?>(json['meaning']),
      presentParticiple:
          serializer.fromJson<String?>(json['presentParticiple']),
      prastParticiple: serializer.fromJson<String?>(json['prastParticiple']),
      indicativePresentYo:
          serializer.fromJson<String?>(json['indicativePresentYo']),
      indicativePresentTu:
          serializer.fromJson<String?>(json['indicativePresentTu']),
      indicativePresentEl:
          serializer.fromJson<String?>(json['indicativePresentEl']),
      indicativePresentNosotros:
          serializer.fromJson<String?>(json['indicativePresentNosotros']),
      indicativePresentVosotros:
          serializer.fromJson<String?>(json['indicativePresentVosotros']),
      indicativePresentEllos:
          serializer.fromJson<String?>(json['indicativePresentEllos']),
      indicativePreteriteYo:
          serializer.fromJson<String?>(json['indicativePreteriteYo']),
      indicativePreteriteTu:
          serializer.fromJson<String?>(json['indicativePreteriteTu']),
      indicativePreteriteEl:
          serializer.fromJson<String?>(json['indicativePreteriteEl']),
      indicativePreteriteNosotros:
          serializer.fromJson<String?>(json['indicativePreteriteNosotros']),
      indicativePreteriteVosotros:
          serializer.fromJson<String?>(json['indicativePreteriteVosotros']),
      indicativePreteriteEllos:
          serializer.fromJson<String?>(json['indicativePreteriteEllos']),
      indicativeImperfectYo:
          serializer.fromJson<String?>(json['indicativeImperfectYo']),
      indicativeImperfectTu:
          serializer.fromJson<String?>(json['indicativeImperfectTu']),
      indicativeImperfectEl:
          serializer.fromJson<String?>(json['indicativeImperfectEl']),
      indicativeImperfectNosotros:
          serializer.fromJson<String?>(json['indicativeImperfectNosotros']),
      indicativeImperfectVosotros:
          serializer.fromJson<String?>(json['indicativeImperfectVosotros']),
      indicativeImperfectEllos:
          serializer.fromJson<String?>(json['indicativeImperfectEllos']),
      indicativeFutureYo:
          serializer.fromJson<String?>(json['indicativeFutureYo']),
      indicativeFutureTu:
          serializer.fromJson<String?>(json['indicativeFutureTu']),
      indicativeFutureEl:
          serializer.fromJson<String?>(json['indicativeFutureEl']),
      indicativeFutureNosotros:
          serializer.fromJson<String?>(json['indicativeFutureNosotros']),
      indicativeFutureVosotros:
          serializer.fromJson<String?>(json['indicativeFutureVosotros']),
      indicativeFutureEllos:
          serializer.fromJson<String?>(json['indicativeFutureEllos']),
      indicativeConditionalYo:
          serializer.fromJson<String?>(json['indicativeConditionalYo']),
      indicativeConditionalTu:
          serializer.fromJson<String?>(json['indicativeConditionalTu']),
      indicativeConditionalEl:
          serializer.fromJson<String?>(json['indicativeConditionalEl']),
      indicativeConditionalNosotros:
          serializer.fromJson<String?>(json['indicativeConditionalNosotros']),
      indicativeConditionalVosotros:
          serializer.fromJson<String?>(json['indicativeConditionalVosotros']),
      indicativeConditionalEllos:
          serializer.fromJson<String?>(json['indicativeConditionalEllos']),
      imperativeTu: serializer.fromJson<String?>(json['imperativeTu']),
      imperativeEl: serializer.fromJson<String?>(json['imperativeEl']),
      imperativeNosotros:
          serializer.fromJson<String?>(json['imperativeNosotros']),
      imperativeVosotros:
          serializer.fromJson<String?>(json['imperativeVosotros']),
      imperativeEllos: serializer.fromJson<String?>(json['imperativeEllos']),
      subjunctivePresentYo:
          serializer.fromJson<String?>(json['subjunctivePresentYo']),
      subjunctivePresentTu:
          serializer.fromJson<String?>(json['subjunctivePresentTu']),
      subjunctivePresentEl:
          serializer.fromJson<String?>(json['subjunctivePresentEl']),
      subjunctivePresentNosotros:
          serializer.fromJson<String?>(json['subjunctivePresentNosotros']),
      subjunctivePresentVosotros:
          serializer.fromJson<String?>(json['subjunctivePresentVosotros']),
      subjunctivePresentEllos:
          serializer.fromJson<String?>(json['subjunctivePresentEllos']),
      subjunctivePastYo:
          serializer.fromJson<String?>(json['subjunctivePastYo']),
      subjunctivePastTu:
          serializer.fromJson<String?>(json['subjunctivePastTu']),
      subjunctivePastEl:
          serializer.fromJson<String?>(json['subjunctivePastEl']),
      subjunctivePastNosotros:
          serializer.fromJson<String?>(json['subjunctivePastNosotros']),
      subjunctivePastVosotros:
          serializer.fromJson<String?>(json['subjunctivePastVosotros']),
      subjunctivePastEllos:
          serializer.fromJson<String?>(json['subjunctivePastEllos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String>(word),
      'meaning': serializer.toJson<String?>(meaning),
      'presentParticiple': serializer.toJson<String?>(presentParticiple),
      'prastParticiple': serializer.toJson<String?>(prastParticiple),
      'indicativePresentYo': serializer.toJson<String?>(indicativePresentYo),
      'indicativePresentTu': serializer.toJson<String?>(indicativePresentTu),
      'indicativePresentEl': serializer.toJson<String?>(indicativePresentEl),
      'indicativePresentNosotros':
          serializer.toJson<String?>(indicativePresentNosotros),
      'indicativePresentVosotros':
          serializer.toJson<String?>(indicativePresentVosotros),
      'indicativePresentEllos':
          serializer.toJson<String?>(indicativePresentEllos),
      'indicativePreteriteYo':
          serializer.toJson<String?>(indicativePreteriteYo),
      'indicativePreteriteTu':
          serializer.toJson<String?>(indicativePreteriteTu),
      'indicativePreteriteEl':
          serializer.toJson<String?>(indicativePreteriteEl),
      'indicativePreteriteNosotros':
          serializer.toJson<String?>(indicativePreteriteNosotros),
      'indicativePreteriteVosotros':
          serializer.toJson<String?>(indicativePreteriteVosotros),
      'indicativePreteriteEllos':
          serializer.toJson<String?>(indicativePreteriteEllos),
      'indicativeImperfectYo':
          serializer.toJson<String?>(indicativeImperfectYo),
      'indicativeImperfectTu':
          serializer.toJson<String?>(indicativeImperfectTu),
      'indicativeImperfectEl':
          serializer.toJson<String?>(indicativeImperfectEl),
      'indicativeImperfectNosotros':
          serializer.toJson<String?>(indicativeImperfectNosotros),
      'indicativeImperfectVosotros':
          serializer.toJson<String?>(indicativeImperfectVosotros),
      'indicativeImperfectEllos':
          serializer.toJson<String?>(indicativeImperfectEllos),
      'indicativeFutureYo': serializer.toJson<String?>(indicativeFutureYo),
      'indicativeFutureTu': serializer.toJson<String?>(indicativeFutureTu),
      'indicativeFutureEl': serializer.toJson<String?>(indicativeFutureEl),
      'indicativeFutureNosotros':
          serializer.toJson<String?>(indicativeFutureNosotros),
      'indicativeFutureVosotros':
          serializer.toJson<String?>(indicativeFutureVosotros),
      'indicativeFutureEllos':
          serializer.toJson<String?>(indicativeFutureEllos),
      'indicativeConditionalYo':
          serializer.toJson<String?>(indicativeConditionalYo),
      'indicativeConditionalTu':
          serializer.toJson<String?>(indicativeConditionalTu),
      'indicativeConditionalEl':
          serializer.toJson<String?>(indicativeConditionalEl),
      'indicativeConditionalNosotros':
          serializer.toJson<String?>(indicativeConditionalNosotros),
      'indicativeConditionalVosotros':
          serializer.toJson<String?>(indicativeConditionalVosotros),
      'indicativeConditionalEllos':
          serializer.toJson<String?>(indicativeConditionalEllos),
      'imperativeTu': serializer.toJson<String?>(imperativeTu),
      'imperativeEl': serializer.toJson<String?>(imperativeEl),
      'imperativeNosotros': serializer.toJson<String?>(imperativeNosotros),
      'imperativeVosotros': serializer.toJson<String?>(imperativeVosotros),
      'imperativeEllos': serializer.toJson<String?>(imperativeEllos),
      'subjunctivePresentYo': serializer.toJson<String?>(subjunctivePresentYo),
      'subjunctivePresentTu': serializer.toJson<String?>(subjunctivePresentTu),
      'subjunctivePresentEl': serializer.toJson<String?>(subjunctivePresentEl),
      'subjunctivePresentNosotros':
          serializer.toJson<String?>(subjunctivePresentNosotros),
      'subjunctivePresentVosotros':
          serializer.toJson<String?>(subjunctivePresentVosotros),
      'subjunctivePresentEllos':
          serializer.toJson<String?>(subjunctivePresentEllos),
      'subjunctivePastYo': serializer.toJson<String?>(subjunctivePastYo),
      'subjunctivePastTu': serializer.toJson<String?>(subjunctivePastTu),
      'subjunctivePastEl': serializer.toJson<String?>(subjunctivePastEl),
      'subjunctivePastNosotros':
          serializer.toJson<String?>(subjunctivePastNosotros),
      'subjunctivePastVosotros':
          serializer.toJson<String?>(subjunctivePastVosotros),
      'subjunctivePastEllos': serializer.toJson<String?>(subjunctivePastEllos),
    };
  }

  Conjugation copyWith(
          {int? wordId,
          String? word,
          Value<String?> meaning = const Value.absent(),
          Value<String?> presentParticiple = const Value.absent(),
          Value<String?> prastParticiple = const Value.absent(),
          Value<String?> indicativePresentYo = const Value.absent(),
          Value<String?> indicativePresentTu = const Value.absent(),
          Value<String?> indicativePresentEl = const Value.absent(),
          Value<String?> indicativePresentNosotros = const Value.absent(),
          Value<String?> indicativePresentVosotros = const Value.absent(),
          Value<String?> indicativePresentEllos = const Value.absent(),
          Value<String?> indicativePreteriteYo = const Value.absent(),
          Value<String?> indicativePreteriteTu = const Value.absent(),
          Value<String?> indicativePreteriteEl = const Value.absent(),
          Value<String?> indicativePreteriteNosotros = const Value.absent(),
          Value<String?> indicativePreteriteVosotros = const Value.absent(),
          Value<String?> indicativePreteriteEllos = const Value.absent(),
          Value<String?> indicativeImperfectYo = const Value.absent(),
          Value<String?> indicativeImperfectTu = const Value.absent(),
          Value<String?> indicativeImperfectEl = const Value.absent(),
          Value<String?> indicativeImperfectNosotros = const Value.absent(),
          Value<String?> indicativeImperfectVosotros = const Value.absent(),
          Value<String?> indicativeImperfectEllos = const Value.absent(),
          Value<String?> indicativeFutureYo = const Value.absent(),
          Value<String?> indicativeFutureTu = const Value.absent(),
          Value<String?> indicativeFutureEl = const Value.absent(),
          Value<String?> indicativeFutureNosotros = const Value.absent(),
          Value<String?> indicativeFutureVosotros = const Value.absent(),
          Value<String?> indicativeFutureEllos = const Value.absent(),
          Value<String?> indicativeConditionalYo = const Value.absent(),
          Value<String?> indicativeConditionalTu = const Value.absent(),
          Value<String?> indicativeConditionalEl = const Value.absent(),
          Value<String?> indicativeConditionalNosotros = const Value.absent(),
          Value<String?> indicativeConditionalVosotros = const Value.absent(),
          Value<String?> indicativeConditionalEllos = const Value.absent(),
          Value<String?> imperativeTu = const Value.absent(),
          Value<String?> imperativeEl = const Value.absent(),
          Value<String?> imperativeNosotros = const Value.absent(),
          Value<String?> imperativeVosotros = const Value.absent(),
          Value<String?> imperativeEllos = const Value.absent(),
          Value<String?> subjunctivePresentYo = const Value.absent(),
          Value<String?> subjunctivePresentTu = const Value.absent(),
          Value<String?> subjunctivePresentEl = const Value.absent(),
          Value<String?> subjunctivePresentNosotros = const Value.absent(),
          Value<String?> subjunctivePresentVosotros = const Value.absent(),
          Value<String?> subjunctivePresentEllos = const Value.absent(),
          Value<String?> subjunctivePastYo = const Value.absent(),
          Value<String?> subjunctivePastTu = const Value.absent(),
          Value<String?> subjunctivePastEl = const Value.absent(),
          Value<String?> subjunctivePastNosotros = const Value.absent(),
          Value<String?> subjunctivePastVosotros = const Value.absent(),
          Value<String?> subjunctivePastEllos = const Value.absent()}) =>
      Conjugation(
        wordId: wordId ?? this.wordId,
        word: word ?? this.word,
        meaning: meaning.present ? meaning.value : this.meaning,
        presentParticiple: presentParticiple.present
            ? presentParticiple.value
            : this.presentParticiple,
        prastParticiple: prastParticiple.present
            ? prastParticiple.value
            : this.prastParticiple,
        indicativePresentYo: indicativePresentYo.present
            ? indicativePresentYo.value
            : this.indicativePresentYo,
        indicativePresentTu: indicativePresentTu.present
            ? indicativePresentTu.value
            : this.indicativePresentTu,
        indicativePresentEl: indicativePresentEl.present
            ? indicativePresentEl.value
            : this.indicativePresentEl,
        indicativePresentNosotros: indicativePresentNosotros.present
            ? indicativePresentNosotros.value
            : this.indicativePresentNosotros,
        indicativePresentVosotros: indicativePresentVosotros.present
            ? indicativePresentVosotros.value
            : this.indicativePresentVosotros,
        indicativePresentEllos: indicativePresentEllos.present
            ? indicativePresentEllos.value
            : this.indicativePresentEllos,
        indicativePreteriteYo: indicativePreteriteYo.present
            ? indicativePreteriteYo.value
            : this.indicativePreteriteYo,
        indicativePreteriteTu: indicativePreteriteTu.present
            ? indicativePreteriteTu.value
            : this.indicativePreteriteTu,
        indicativePreteriteEl: indicativePreteriteEl.present
            ? indicativePreteriteEl.value
            : this.indicativePreteriteEl,
        indicativePreteriteNosotros: indicativePreteriteNosotros.present
            ? indicativePreteriteNosotros.value
            : this.indicativePreteriteNosotros,
        indicativePreteriteVosotros: indicativePreteriteVosotros.present
            ? indicativePreteriteVosotros.value
            : this.indicativePreteriteVosotros,
        indicativePreteriteEllos: indicativePreteriteEllos.present
            ? indicativePreteriteEllos.value
            : this.indicativePreteriteEllos,
        indicativeImperfectYo: indicativeImperfectYo.present
            ? indicativeImperfectYo.value
            : this.indicativeImperfectYo,
        indicativeImperfectTu: indicativeImperfectTu.present
            ? indicativeImperfectTu.value
            : this.indicativeImperfectTu,
        indicativeImperfectEl: indicativeImperfectEl.present
            ? indicativeImperfectEl.value
            : this.indicativeImperfectEl,
        indicativeImperfectNosotros: indicativeImperfectNosotros.present
            ? indicativeImperfectNosotros.value
            : this.indicativeImperfectNosotros,
        indicativeImperfectVosotros: indicativeImperfectVosotros.present
            ? indicativeImperfectVosotros.value
            : this.indicativeImperfectVosotros,
        indicativeImperfectEllos: indicativeImperfectEllos.present
            ? indicativeImperfectEllos.value
            : this.indicativeImperfectEllos,
        indicativeFutureYo: indicativeFutureYo.present
            ? indicativeFutureYo.value
            : this.indicativeFutureYo,
        indicativeFutureTu: indicativeFutureTu.present
            ? indicativeFutureTu.value
            : this.indicativeFutureTu,
        indicativeFutureEl: indicativeFutureEl.present
            ? indicativeFutureEl.value
            : this.indicativeFutureEl,
        indicativeFutureNosotros: indicativeFutureNosotros.present
            ? indicativeFutureNosotros.value
            : this.indicativeFutureNosotros,
        indicativeFutureVosotros: indicativeFutureVosotros.present
            ? indicativeFutureVosotros.value
            : this.indicativeFutureVosotros,
        indicativeFutureEllos: indicativeFutureEllos.present
            ? indicativeFutureEllos.value
            : this.indicativeFutureEllos,
        indicativeConditionalYo: indicativeConditionalYo.present
            ? indicativeConditionalYo.value
            : this.indicativeConditionalYo,
        indicativeConditionalTu: indicativeConditionalTu.present
            ? indicativeConditionalTu.value
            : this.indicativeConditionalTu,
        indicativeConditionalEl: indicativeConditionalEl.present
            ? indicativeConditionalEl.value
            : this.indicativeConditionalEl,
        indicativeConditionalNosotros: indicativeConditionalNosotros.present
            ? indicativeConditionalNosotros.value
            : this.indicativeConditionalNosotros,
        indicativeConditionalVosotros: indicativeConditionalVosotros.present
            ? indicativeConditionalVosotros.value
            : this.indicativeConditionalVosotros,
        indicativeConditionalEllos: indicativeConditionalEllos.present
            ? indicativeConditionalEllos.value
            : this.indicativeConditionalEllos,
        imperativeTu:
            imperativeTu.present ? imperativeTu.value : this.imperativeTu,
        imperativeEl:
            imperativeEl.present ? imperativeEl.value : this.imperativeEl,
        imperativeNosotros: imperativeNosotros.present
            ? imperativeNosotros.value
            : this.imperativeNosotros,
        imperativeVosotros: imperativeVosotros.present
            ? imperativeVosotros.value
            : this.imperativeVosotros,
        imperativeEllos: imperativeEllos.present
            ? imperativeEllos.value
            : this.imperativeEllos,
        subjunctivePresentYo: subjunctivePresentYo.present
            ? subjunctivePresentYo.value
            : this.subjunctivePresentYo,
        subjunctivePresentTu: subjunctivePresentTu.present
            ? subjunctivePresentTu.value
            : this.subjunctivePresentTu,
        subjunctivePresentEl: subjunctivePresentEl.present
            ? subjunctivePresentEl.value
            : this.subjunctivePresentEl,
        subjunctivePresentNosotros: subjunctivePresentNosotros.present
            ? subjunctivePresentNosotros.value
            : this.subjunctivePresentNosotros,
        subjunctivePresentVosotros: subjunctivePresentVosotros.present
            ? subjunctivePresentVosotros.value
            : this.subjunctivePresentVosotros,
        subjunctivePresentEllos: subjunctivePresentEllos.present
            ? subjunctivePresentEllos.value
            : this.subjunctivePresentEllos,
        subjunctivePastYo: subjunctivePastYo.present
            ? subjunctivePastYo.value
            : this.subjunctivePastYo,
        subjunctivePastTu: subjunctivePastTu.present
            ? subjunctivePastTu.value
            : this.subjunctivePastTu,
        subjunctivePastEl: subjunctivePastEl.present
            ? subjunctivePastEl.value
            : this.subjunctivePastEl,
        subjunctivePastNosotros: subjunctivePastNosotros.present
            ? subjunctivePastNosotros.value
            : this.subjunctivePastNosotros,
        subjunctivePastVosotros: subjunctivePastVosotros.present
            ? subjunctivePastVosotros.value
            : this.subjunctivePastVosotros,
        subjunctivePastEllos: subjunctivePastEllos.present
            ? subjunctivePastEllos.value
            : this.subjunctivePastEllos,
      );
  Conjugation copyWithCompanion(ConjugationsCompanion data) {
    return Conjugation(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      presentParticiple: data.presentParticiple.present
          ? data.presentParticiple.value
          : this.presentParticiple,
      prastParticiple: data.prastParticiple.present
          ? data.prastParticiple.value
          : this.prastParticiple,
      indicativePresentYo: data.indicativePresentYo.present
          ? data.indicativePresentYo.value
          : this.indicativePresentYo,
      indicativePresentTu: data.indicativePresentTu.present
          ? data.indicativePresentTu.value
          : this.indicativePresentTu,
      indicativePresentEl: data.indicativePresentEl.present
          ? data.indicativePresentEl.value
          : this.indicativePresentEl,
      indicativePresentNosotros: data.indicativePresentNosotros.present
          ? data.indicativePresentNosotros.value
          : this.indicativePresentNosotros,
      indicativePresentVosotros: data.indicativePresentVosotros.present
          ? data.indicativePresentVosotros.value
          : this.indicativePresentVosotros,
      indicativePresentEllos: data.indicativePresentEllos.present
          ? data.indicativePresentEllos.value
          : this.indicativePresentEllos,
      indicativePreteriteYo: data.indicativePreteriteYo.present
          ? data.indicativePreteriteYo.value
          : this.indicativePreteriteYo,
      indicativePreteriteTu: data.indicativePreteriteTu.present
          ? data.indicativePreteriteTu.value
          : this.indicativePreteriteTu,
      indicativePreteriteEl: data.indicativePreteriteEl.present
          ? data.indicativePreteriteEl.value
          : this.indicativePreteriteEl,
      indicativePreteriteNosotros: data.indicativePreteriteNosotros.present
          ? data.indicativePreteriteNosotros.value
          : this.indicativePreteriteNosotros,
      indicativePreteriteVosotros: data.indicativePreteriteVosotros.present
          ? data.indicativePreteriteVosotros.value
          : this.indicativePreteriteVosotros,
      indicativePreteriteEllos: data.indicativePreteriteEllos.present
          ? data.indicativePreteriteEllos.value
          : this.indicativePreteriteEllos,
      indicativeImperfectYo: data.indicativeImperfectYo.present
          ? data.indicativeImperfectYo.value
          : this.indicativeImperfectYo,
      indicativeImperfectTu: data.indicativeImperfectTu.present
          ? data.indicativeImperfectTu.value
          : this.indicativeImperfectTu,
      indicativeImperfectEl: data.indicativeImperfectEl.present
          ? data.indicativeImperfectEl.value
          : this.indicativeImperfectEl,
      indicativeImperfectNosotros: data.indicativeImperfectNosotros.present
          ? data.indicativeImperfectNosotros.value
          : this.indicativeImperfectNosotros,
      indicativeImperfectVosotros: data.indicativeImperfectVosotros.present
          ? data.indicativeImperfectVosotros.value
          : this.indicativeImperfectVosotros,
      indicativeImperfectEllos: data.indicativeImperfectEllos.present
          ? data.indicativeImperfectEllos.value
          : this.indicativeImperfectEllos,
      indicativeFutureYo: data.indicativeFutureYo.present
          ? data.indicativeFutureYo.value
          : this.indicativeFutureYo,
      indicativeFutureTu: data.indicativeFutureTu.present
          ? data.indicativeFutureTu.value
          : this.indicativeFutureTu,
      indicativeFutureEl: data.indicativeFutureEl.present
          ? data.indicativeFutureEl.value
          : this.indicativeFutureEl,
      indicativeFutureNosotros: data.indicativeFutureNosotros.present
          ? data.indicativeFutureNosotros.value
          : this.indicativeFutureNosotros,
      indicativeFutureVosotros: data.indicativeFutureVosotros.present
          ? data.indicativeFutureVosotros.value
          : this.indicativeFutureVosotros,
      indicativeFutureEllos: data.indicativeFutureEllos.present
          ? data.indicativeFutureEllos.value
          : this.indicativeFutureEllos,
      indicativeConditionalYo: data.indicativeConditionalYo.present
          ? data.indicativeConditionalYo.value
          : this.indicativeConditionalYo,
      indicativeConditionalTu: data.indicativeConditionalTu.present
          ? data.indicativeConditionalTu.value
          : this.indicativeConditionalTu,
      indicativeConditionalEl: data.indicativeConditionalEl.present
          ? data.indicativeConditionalEl.value
          : this.indicativeConditionalEl,
      indicativeConditionalNosotros: data.indicativeConditionalNosotros.present
          ? data.indicativeConditionalNosotros.value
          : this.indicativeConditionalNosotros,
      indicativeConditionalVosotros: data.indicativeConditionalVosotros.present
          ? data.indicativeConditionalVosotros.value
          : this.indicativeConditionalVosotros,
      indicativeConditionalEllos: data.indicativeConditionalEllos.present
          ? data.indicativeConditionalEllos.value
          : this.indicativeConditionalEllos,
      imperativeTu: data.imperativeTu.present
          ? data.imperativeTu.value
          : this.imperativeTu,
      imperativeEl: data.imperativeEl.present
          ? data.imperativeEl.value
          : this.imperativeEl,
      imperativeNosotros: data.imperativeNosotros.present
          ? data.imperativeNosotros.value
          : this.imperativeNosotros,
      imperativeVosotros: data.imperativeVosotros.present
          ? data.imperativeVosotros.value
          : this.imperativeVosotros,
      imperativeEllos: data.imperativeEllos.present
          ? data.imperativeEllos.value
          : this.imperativeEllos,
      subjunctivePresentYo: data.subjunctivePresentYo.present
          ? data.subjunctivePresentYo.value
          : this.subjunctivePresentYo,
      subjunctivePresentTu: data.subjunctivePresentTu.present
          ? data.subjunctivePresentTu.value
          : this.subjunctivePresentTu,
      subjunctivePresentEl: data.subjunctivePresentEl.present
          ? data.subjunctivePresentEl.value
          : this.subjunctivePresentEl,
      subjunctivePresentNosotros: data.subjunctivePresentNosotros.present
          ? data.subjunctivePresentNosotros.value
          : this.subjunctivePresentNosotros,
      subjunctivePresentVosotros: data.subjunctivePresentVosotros.present
          ? data.subjunctivePresentVosotros.value
          : this.subjunctivePresentVosotros,
      subjunctivePresentEllos: data.subjunctivePresentEllos.present
          ? data.subjunctivePresentEllos.value
          : this.subjunctivePresentEllos,
      subjunctivePastYo: data.subjunctivePastYo.present
          ? data.subjunctivePastYo.value
          : this.subjunctivePastYo,
      subjunctivePastTu: data.subjunctivePastTu.present
          ? data.subjunctivePastTu.value
          : this.subjunctivePastTu,
      subjunctivePastEl: data.subjunctivePastEl.present
          ? data.subjunctivePastEl.value
          : this.subjunctivePastEl,
      subjunctivePastNosotros: data.subjunctivePastNosotros.present
          ? data.subjunctivePastNosotros.value
          : this.subjunctivePastNosotros,
      subjunctivePastVosotros: data.subjunctivePastVosotros.present
          ? data.subjunctivePastVosotros.value
          : this.subjunctivePastVosotros,
      subjunctivePastEllos: data.subjunctivePastEllos.present
          ? data.subjunctivePastEllos.value
          : this.subjunctivePastEllos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conjugation(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('presentParticiple: $presentParticiple, ')
          ..write('prastParticiple: $prastParticiple, ')
          ..write('indicativePresentYo: $indicativePresentYo, ')
          ..write('indicativePresentTu: $indicativePresentTu, ')
          ..write('indicativePresentEl: $indicativePresentEl, ')
          ..write('indicativePresentNosotros: $indicativePresentNosotros, ')
          ..write('indicativePresentVosotros: $indicativePresentVosotros, ')
          ..write('indicativePresentEllos: $indicativePresentEllos, ')
          ..write('indicativePreteriteYo: $indicativePreteriteYo, ')
          ..write('indicativePreteriteTu: $indicativePreteriteTu, ')
          ..write('indicativePreteriteEl: $indicativePreteriteEl, ')
          ..write('indicativePreteriteNosotros: $indicativePreteriteNosotros, ')
          ..write('indicativePreteriteVosotros: $indicativePreteriteVosotros, ')
          ..write('indicativePreteriteEllos: $indicativePreteriteEllos, ')
          ..write('indicativeImperfectYo: $indicativeImperfectYo, ')
          ..write('indicativeImperfectTu: $indicativeImperfectTu, ')
          ..write('indicativeImperfectEl: $indicativeImperfectEl, ')
          ..write('indicativeImperfectNosotros: $indicativeImperfectNosotros, ')
          ..write('indicativeImperfectVosotros: $indicativeImperfectVosotros, ')
          ..write('indicativeImperfectEllos: $indicativeImperfectEllos, ')
          ..write('indicativeFutureYo: $indicativeFutureYo, ')
          ..write('indicativeFutureTu: $indicativeFutureTu, ')
          ..write('indicativeFutureEl: $indicativeFutureEl, ')
          ..write('indicativeFutureNosotros: $indicativeFutureNosotros, ')
          ..write('indicativeFutureVosotros: $indicativeFutureVosotros, ')
          ..write('indicativeFutureEllos: $indicativeFutureEllos, ')
          ..write('indicativeConditionalYo: $indicativeConditionalYo, ')
          ..write('indicativeConditionalTu: $indicativeConditionalTu, ')
          ..write('indicativeConditionalEl: $indicativeConditionalEl, ')
          ..write(
              'indicativeConditionalNosotros: $indicativeConditionalNosotros, ')
          ..write(
              'indicativeConditionalVosotros: $indicativeConditionalVosotros, ')
          ..write('indicativeConditionalEllos: $indicativeConditionalEllos, ')
          ..write('imperativeTu: $imperativeTu, ')
          ..write('imperativeEl: $imperativeEl, ')
          ..write('imperativeNosotros: $imperativeNosotros, ')
          ..write('imperativeVosotros: $imperativeVosotros, ')
          ..write('imperativeEllos: $imperativeEllos, ')
          ..write('subjunctivePresentYo: $subjunctivePresentYo, ')
          ..write('subjunctivePresentTu: $subjunctivePresentTu, ')
          ..write('subjunctivePresentEl: $subjunctivePresentEl, ')
          ..write('subjunctivePresentNosotros: $subjunctivePresentNosotros, ')
          ..write('subjunctivePresentVosotros: $subjunctivePresentVosotros, ')
          ..write('subjunctivePresentEllos: $subjunctivePresentEllos, ')
          ..write('subjunctivePastYo: $subjunctivePastYo, ')
          ..write('subjunctivePastTu: $subjunctivePastTu, ')
          ..write('subjunctivePastEl: $subjunctivePastEl, ')
          ..write('subjunctivePastNosotros: $subjunctivePastNosotros, ')
          ..write('subjunctivePastVosotros: $subjunctivePastVosotros, ')
          ..write('subjunctivePastEllos: $subjunctivePastEllos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        wordId,
        word,
        meaning,
        presentParticiple,
        prastParticiple,
        indicativePresentYo,
        indicativePresentTu,
        indicativePresentEl,
        indicativePresentNosotros,
        indicativePresentVosotros,
        indicativePresentEllos,
        indicativePreteriteYo,
        indicativePreteriteTu,
        indicativePreteriteEl,
        indicativePreteriteNosotros,
        indicativePreteriteVosotros,
        indicativePreteriteEllos,
        indicativeImperfectYo,
        indicativeImperfectTu,
        indicativeImperfectEl,
        indicativeImperfectNosotros,
        indicativeImperfectVosotros,
        indicativeImperfectEllos,
        indicativeFutureYo,
        indicativeFutureTu,
        indicativeFutureEl,
        indicativeFutureNosotros,
        indicativeFutureVosotros,
        indicativeFutureEllos,
        indicativeConditionalYo,
        indicativeConditionalTu,
        indicativeConditionalEl,
        indicativeConditionalNosotros,
        indicativeConditionalVosotros,
        indicativeConditionalEllos,
        imperativeTu,
        imperativeEl,
        imperativeNosotros,
        imperativeVosotros,
        imperativeEllos,
        subjunctivePresentYo,
        subjunctivePresentTu,
        subjunctivePresentEl,
        subjunctivePresentNosotros,
        subjunctivePresentVosotros,
        subjunctivePresentEllos,
        subjunctivePastYo,
        subjunctivePastTu,
        subjunctivePastEl,
        subjunctivePastNosotros,
        subjunctivePastVosotros,
        subjunctivePastEllos
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conjugation &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.meaning == this.meaning &&
          other.presentParticiple == this.presentParticiple &&
          other.prastParticiple == this.prastParticiple &&
          other.indicativePresentYo == this.indicativePresentYo &&
          other.indicativePresentTu == this.indicativePresentTu &&
          other.indicativePresentEl == this.indicativePresentEl &&
          other.indicativePresentNosotros == this.indicativePresentNosotros &&
          other.indicativePresentVosotros == this.indicativePresentVosotros &&
          other.indicativePresentEllos == this.indicativePresentEllos &&
          other.indicativePreteriteYo == this.indicativePreteriteYo &&
          other.indicativePreteriteTu == this.indicativePreteriteTu &&
          other.indicativePreteriteEl == this.indicativePreteriteEl &&
          other.indicativePreteriteNosotros ==
              this.indicativePreteriteNosotros &&
          other.indicativePreteriteVosotros ==
              this.indicativePreteriteVosotros &&
          other.indicativePreteriteEllos == this.indicativePreteriteEllos &&
          other.indicativeImperfectYo == this.indicativeImperfectYo &&
          other.indicativeImperfectTu == this.indicativeImperfectTu &&
          other.indicativeImperfectEl == this.indicativeImperfectEl &&
          other.indicativeImperfectNosotros ==
              this.indicativeImperfectNosotros &&
          other.indicativeImperfectVosotros ==
              this.indicativeImperfectVosotros &&
          other.indicativeImperfectEllos == this.indicativeImperfectEllos &&
          other.indicativeFutureYo == this.indicativeFutureYo &&
          other.indicativeFutureTu == this.indicativeFutureTu &&
          other.indicativeFutureEl == this.indicativeFutureEl &&
          other.indicativeFutureNosotros == this.indicativeFutureNosotros &&
          other.indicativeFutureVosotros == this.indicativeFutureVosotros &&
          other.indicativeFutureEllos == this.indicativeFutureEllos &&
          other.indicativeConditionalYo == this.indicativeConditionalYo &&
          other.indicativeConditionalTu == this.indicativeConditionalTu &&
          other.indicativeConditionalEl == this.indicativeConditionalEl &&
          other.indicativeConditionalNosotros ==
              this.indicativeConditionalNosotros &&
          other.indicativeConditionalVosotros ==
              this.indicativeConditionalVosotros &&
          other.indicativeConditionalEllos == this.indicativeConditionalEllos &&
          other.imperativeTu == this.imperativeTu &&
          other.imperativeEl == this.imperativeEl &&
          other.imperativeNosotros == this.imperativeNosotros &&
          other.imperativeVosotros == this.imperativeVosotros &&
          other.imperativeEllos == this.imperativeEllos &&
          other.subjunctivePresentYo == this.subjunctivePresentYo &&
          other.subjunctivePresentTu == this.subjunctivePresentTu &&
          other.subjunctivePresentEl == this.subjunctivePresentEl &&
          other.subjunctivePresentNosotros == this.subjunctivePresentNosotros &&
          other.subjunctivePresentVosotros == this.subjunctivePresentVosotros &&
          other.subjunctivePresentEllos == this.subjunctivePresentEllos &&
          other.subjunctivePastYo == this.subjunctivePastYo &&
          other.subjunctivePastTu == this.subjunctivePastTu &&
          other.subjunctivePastEl == this.subjunctivePastEl &&
          other.subjunctivePastNosotros == this.subjunctivePastNosotros &&
          other.subjunctivePastVosotros == this.subjunctivePastVosotros &&
          other.subjunctivePastEllos == this.subjunctivePastEllos);
}

class ConjugationsCompanion extends UpdateCompanion<Conjugation> {
  final Value<int> wordId;
  final Value<String> word;
  final Value<String?> meaning;
  final Value<String?> presentParticiple;
  final Value<String?> prastParticiple;
  final Value<String?> indicativePresentYo;
  final Value<String?> indicativePresentTu;
  final Value<String?> indicativePresentEl;
  final Value<String?> indicativePresentNosotros;
  final Value<String?> indicativePresentVosotros;
  final Value<String?> indicativePresentEllos;
  final Value<String?> indicativePreteriteYo;
  final Value<String?> indicativePreteriteTu;
  final Value<String?> indicativePreteriteEl;
  final Value<String?> indicativePreteriteNosotros;
  final Value<String?> indicativePreteriteVosotros;
  final Value<String?> indicativePreteriteEllos;
  final Value<String?> indicativeImperfectYo;
  final Value<String?> indicativeImperfectTu;
  final Value<String?> indicativeImperfectEl;
  final Value<String?> indicativeImperfectNosotros;
  final Value<String?> indicativeImperfectVosotros;
  final Value<String?> indicativeImperfectEllos;
  final Value<String?> indicativeFutureYo;
  final Value<String?> indicativeFutureTu;
  final Value<String?> indicativeFutureEl;
  final Value<String?> indicativeFutureNosotros;
  final Value<String?> indicativeFutureVosotros;
  final Value<String?> indicativeFutureEllos;
  final Value<String?> indicativeConditionalYo;
  final Value<String?> indicativeConditionalTu;
  final Value<String?> indicativeConditionalEl;
  final Value<String?> indicativeConditionalNosotros;
  final Value<String?> indicativeConditionalVosotros;
  final Value<String?> indicativeConditionalEllos;
  final Value<String?> imperativeTu;
  final Value<String?> imperativeEl;
  final Value<String?> imperativeNosotros;
  final Value<String?> imperativeVosotros;
  final Value<String?> imperativeEllos;
  final Value<String?> subjunctivePresentYo;
  final Value<String?> subjunctivePresentTu;
  final Value<String?> subjunctivePresentEl;
  final Value<String?> subjunctivePresentNosotros;
  final Value<String?> subjunctivePresentVosotros;
  final Value<String?> subjunctivePresentEllos;
  final Value<String?> subjunctivePastYo;
  final Value<String?> subjunctivePastTu;
  final Value<String?> subjunctivePastEl;
  final Value<String?> subjunctivePastNosotros;
  final Value<String?> subjunctivePastVosotros;
  final Value<String?> subjunctivePastEllos;
  const ConjugationsCompanion({
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.meaning = const Value.absent(),
    this.presentParticiple = const Value.absent(),
    this.prastParticiple = const Value.absent(),
    this.indicativePresentYo = const Value.absent(),
    this.indicativePresentTu = const Value.absent(),
    this.indicativePresentEl = const Value.absent(),
    this.indicativePresentNosotros = const Value.absent(),
    this.indicativePresentVosotros = const Value.absent(),
    this.indicativePresentEllos = const Value.absent(),
    this.indicativePreteriteYo = const Value.absent(),
    this.indicativePreteriteTu = const Value.absent(),
    this.indicativePreteriteEl = const Value.absent(),
    this.indicativePreteriteNosotros = const Value.absent(),
    this.indicativePreteriteVosotros = const Value.absent(),
    this.indicativePreteriteEllos = const Value.absent(),
    this.indicativeImperfectYo = const Value.absent(),
    this.indicativeImperfectTu = const Value.absent(),
    this.indicativeImperfectEl = const Value.absent(),
    this.indicativeImperfectNosotros = const Value.absent(),
    this.indicativeImperfectVosotros = const Value.absent(),
    this.indicativeImperfectEllos = const Value.absent(),
    this.indicativeFutureYo = const Value.absent(),
    this.indicativeFutureTu = const Value.absent(),
    this.indicativeFutureEl = const Value.absent(),
    this.indicativeFutureNosotros = const Value.absent(),
    this.indicativeFutureVosotros = const Value.absent(),
    this.indicativeFutureEllos = const Value.absent(),
    this.indicativeConditionalYo = const Value.absent(),
    this.indicativeConditionalTu = const Value.absent(),
    this.indicativeConditionalEl = const Value.absent(),
    this.indicativeConditionalNosotros = const Value.absent(),
    this.indicativeConditionalVosotros = const Value.absent(),
    this.indicativeConditionalEllos = const Value.absent(),
    this.imperativeTu = const Value.absent(),
    this.imperativeEl = const Value.absent(),
    this.imperativeNosotros = const Value.absent(),
    this.imperativeVosotros = const Value.absent(),
    this.imperativeEllos = const Value.absent(),
    this.subjunctivePresentYo = const Value.absent(),
    this.subjunctivePresentTu = const Value.absent(),
    this.subjunctivePresentEl = const Value.absent(),
    this.subjunctivePresentNosotros = const Value.absent(),
    this.subjunctivePresentVosotros = const Value.absent(),
    this.subjunctivePresentEllos = const Value.absent(),
    this.subjunctivePastYo = const Value.absent(),
    this.subjunctivePastTu = const Value.absent(),
    this.subjunctivePastEl = const Value.absent(),
    this.subjunctivePastNosotros = const Value.absent(),
    this.subjunctivePastVosotros = const Value.absent(),
    this.subjunctivePastEllos = const Value.absent(),
  });
  ConjugationsCompanion.insert({
    this.wordId = const Value.absent(),
    required String word,
    this.meaning = const Value.absent(),
    this.presentParticiple = const Value.absent(),
    this.prastParticiple = const Value.absent(),
    this.indicativePresentYo = const Value.absent(),
    this.indicativePresentTu = const Value.absent(),
    this.indicativePresentEl = const Value.absent(),
    this.indicativePresentNosotros = const Value.absent(),
    this.indicativePresentVosotros = const Value.absent(),
    this.indicativePresentEllos = const Value.absent(),
    this.indicativePreteriteYo = const Value.absent(),
    this.indicativePreteriteTu = const Value.absent(),
    this.indicativePreteriteEl = const Value.absent(),
    this.indicativePreteriteNosotros = const Value.absent(),
    this.indicativePreteriteVosotros = const Value.absent(),
    this.indicativePreteriteEllos = const Value.absent(),
    this.indicativeImperfectYo = const Value.absent(),
    this.indicativeImperfectTu = const Value.absent(),
    this.indicativeImperfectEl = const Value.absent(),
    this.indicativeImperfectNosotros = const Value.absent(),
    this.indicativeImperfectVosotros = const Value.absent(),
    this.indicativeImperfectEllos = const Value.absent(),
    this.indicativeFutureYo = const Value.absent(),
    this.indicativeFutureTu = const Value.absent(),
    this.indicativeFutureEl = const Value.absent(),
    this.indicativeFutureNosotros = const Value.absent(),
    this.indicativeFutureVosotros = const Value.absent(),
    this.indicativeFutureEllos = const Value.absent(),
    this.indicativeConditionalYo = const Value.absent(),
    this.indicativeConditionalTu = const Value.absent(),
    this.indicativeConditionalEl = const Value.absent(),
    this.indicativeConditionalNosotros = const Value.absent(),
    this.indicativeConditionalVosotros = const Value.absent(),
    this.indicativeConditionalEllos = const Value.absent(),
    this.imperativeTu = const Value.absent(),
    this.imperativeEl = const Value.absent(),
    this.imperativeNosotros = const Value.absent(),
    this.imperativeVosotros = const Value.absent(),
    this.imperativeEllos = const Value.absent(),
    this.subjunctivePresentYo = const Value.absent(),
    this.subjunctivePresentTu = const Value.absent(),
    this.subjunctivePresentEl = const Value.absent(),
    this.subjunctivePresentNosotros = const Value.absent(),
    this.subjunctivePresentVosotros = const Value.absent(),
    this.subjunctivePresentEllos = const Value.absent(),
    this.subjunctivePastYo = const Value.absent(),
    this.subjunctivePastTu = const Value.absent(),
    this.subjunctivePastEl = const Value.absent(),
    this.subjunctivePastNosotros = const Value.absent(),
    this.subjunctivePastVosotros = const Value.absent(),
    this.subjunctivePastEllos = const Value.absent(),
  }) : word = Value(word);
  static Insertable<Conjugation> custom({
    Expression<int>? wordId,
    Expression<String>? word,
    Expression<String>? meaning,
    Expression<String>? presentParticiple,
    Expression<String>? prastParticiple,
    Expression<String>? indicativePresentYo,
    Expression<String>? indicativePresentTu,
    Expression<String>? indicativePresentEl,
    Expression<String>? indicativePresentNosotros,
    Expression<String>? indicativePresentVosotros,
    Expression<String>? indicativePresentEllos,
    Expression<String>? indicativePreteriteYo,
    Expression<String>? indicativePreteriteTu,
    Expression<String>? indicativePreteriteEl,
    Expression<String>? indicativePreteriteNosotros,
    Expression<String>? indicativePreteriteVosotros,
    Expression<String>? indicativePreteriteEllos,
    Expression<String>? indicativeImperfectYo,
    Expression<String>? indicativeImperfectTu,
    Expression<String>? indicativeImperfectEl,
    Expression<String>? indicativeImperfectNosotros,
    Expression<String>? indicativeImperfectVosotros,
    Expression<String>? indicativeImperfectEllos,
    Expression<String>? indicativeFutureYo,
    Expression<String>? indicativeFutureTu,
    Expression<String>? indicativeFutureEl,
    Expression<String>? indicativeFutureNosotros,
    Expression<String>? indicativeFutureVosotros,
    Expression<String>? indicativeFutureEllos,
    Expression<String>? indicativeConditionalYo,
    Expression<String>? indicativeConditionalTu,
    Expression<String>? indicativeConditionalEl,
    Expression<String>? indicativeConditionalNosotros,
    Expression<String>? indicativeConditionalVosotros,
    Expression<String>? indicativeConditionalEllos,
    Expression<String>? imperativeTu,
    Expression<String>? imperativeEl,
    Expression<String>? imperativeNosotros,
    Expression<String>? imperativeVosotros,
    Expression<String>? imperativeEllos,
    Expression<String>? subjunctivePresentYo,
    Expression<String>? subjunctivePresentTu,
    Expression<String>? subjunctivePresentEl,
    Expression<String>? subjunctivePresentNosotros,
    Expression<String>? subjunctivePresentVosotros,
    Expression<String>? subjunctivePresentEllos,
    Expression<String>? subjunctivePastYo,
    Expression<String>? subjunctivePastTu,
    Expression<String>? subjunctivePastEl,
    Expression<String>? subjunctivePastNosotros,
    Expression<String>? subjunctivePastVosotros,
    Expression<String>? subjunctivePastEllos,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (word != null) 'word': word,
      if (meaning != null) 'meaning': meaning,
      if (presentParticiple != null) 'present_participle': presentParticiple,
      if (prastParticiple != null) 'past_participle': prastParticiple,
      if (indicativePresentYo != null)
        'indicative_present_yo': indicativePresentYo,
      if (indicativePresentTu != null)
        'indicative_present_tu': indicativePresentTu,
      if (indicativePresentEl != null)
        'indicative_present_el': indicativePresentEl,
      if (indicativePresentNosotros != null)
        'indicative_present_nosotros': indicativePresentNosotros,
      if (indicativePresentVosotros != null)
        'indicative_present_vosotros': indicativePresentVosotros,
      if (indicativePresentEllos != null)
        'indicative_present_ellos': indicativePresentEllos,
      if (indicativePreteriteYo != null)
        'indicative_preterite_yo': indicativePreteriteYo,
      if (indicativePreteriteTu != null)
        'indicative_preterite_tu': indicativePreteriteTu,
      if (indicativePreteriteEl != null)
        'indicative_preterite_el': indicativePreteriteEl,
      if (indicativePreteriteNosotros != null)
        'indicative_preterite_nosotros': indicativePreteriteNosotros,
      if (indicativePreteriteVosotros != null)
        'indicative_preterite_vosotros': indicativePreteriteVosotros,
      if (indicativePreteriteEllos != null)
        'indicative_preterite_ellos': indicativePreteriteEllos,
      if (indicativeImperfectYo != null)
        'indicative_imperfect_yo': indicativeImperfectYo,
      if (indicativeImperfectTu != null)
        'indicative_imperfect_tu': indicativeImperfectTu,
      if (indicativeImperfectEl != null)
        'indicative_imperfect_el': indicativeImperfectEl,
      if (indicativeImperfectNosotros != null)
        'indicative_imperfect_nosotros': indicativeImperfectNosotros,
      if (indicativeImperfectVosotros != null)
        'indicative_imperfect_vosotros': indicativeImperfectVosotros,
      if (indicativeImperfectEllos != null)
        'indicative_imperfect_ellos': indicativeImperfectEllos,
      if (indicativeFutureYo != null)
        'indicative_future_yo': indicativeFutureYo,
      if (indicativeFutureTu != null)
        'indicative_future_tu': indicativeFutureTu,
      if (indicativeFutureEl != null)
        'indicative_future_el': indicativeFutureEl,
      if (indicativeFutureNosotros != null)
        'indicative_future_nosotros': indicativeFutureNosotros,
      if (indicativeFutureVosotros != null)
        'indicative_future_vosotros': indicativeFutureVosotros,
      if (indicativeFutureEllos != null)
        'indicative_future_ellos': indicativeFutureEllos,
      if (indicativeConditionalYo != null)
        'indicative_conditional_yo': indicativeConditionalYo,
      if (indicativeConditionalTu != null)
        'indicative_conditional_tu': indicativeConditionalTu,
      if (indicativeConditionalEl != null)
        'indicative_conditional_el': indicativeConditionalEl,
      if (indicativeConditionalNosotros != null)
        'indicative_conditional_nosotros': indicativeConditionalNosotros,
      if (indicativeConditionalVosotros != null)
        'indicative_conditional_vosotros': indicativeConditionalVosotros,
      if (indicativeConditionalEllos != null)
        'indicative_conditional_ellos': indicativeConditionalEllos,
      if (imperativeTu != null) 'imperative_tu': imperativeTu,
      if (imperativeEl != null) 'imperative_el': imperativeEl,
      if (imperativeNosotros != null) 'imperative_nosotros': imperativeNosotros,
      if (imperativeVosotros != null) 'imperative_vosotros': imperativeVosotros,
      if (imperativeEllos != null) 'imperative_ellos': imperativeEllos,
      if (subjunctivePresentYo != null)
        'subjunctive_present_yo': subjunctivePresentYo,
      if (subjunctivePresentTu != null)
        'subjunctive_present_tu': subjunctivePresentTu,
      if (subjunctivePresentEl != null)
        'subjunctive_present_el': subjunctivePresentEl,
      if (subjunctivePresentNosotros != null)
        'subjunctive_present_nosotros': subjunctivePresentNosotros,
      if (subjunctivePresentVosotros != null)
        'subjunctive_present_vosotros': subjunctivePresentVosotros,
      if (subjunctivePresentEllos != null)
        'subjunctive_present_ellos': subjunctivePresentEllos,
      if (subjunctivePastYo != null) 'subjunctive_past_yo': subjunctivePastYo,
      if (subjunctivePastTu != null) 'subjunctive_past_tu': subjunctivePastTu,
      if (subjunctivePastEl != null) 'subjunctive_past_el': subjunctivePastEl,
      if (subjunctivePastNosotros != null)
        'subjunctive_past_nosotros': subjunctivePastNosotros,
      if (subjunctivePastVosotros != null)
        'subjunctive_past_vosotros': subjunctivePastVosotros,
      if (subjunctivePastEllos != null)
        'subjunctive_past_ellos': subjunctivePastEllos,
    });
  }

  ConjugationsCompanion copyWith(
      {Value<int>? wordId,
      Value<String>? word,
      Value<String?>? meaning,
      Value<String?>? presentParticiple,
      Value<String?>? prastParticiple,
      Value<String?>? indicativePresentYo,
      Value<String?>? indicativePresentTu,
      Value<String?>? indicativePresentEl,
      Value<String?>? indicativePresentNosotros,
      Value<String?>? indicativePresentVosotros,
      Value<String?>? indicativePresentEllos,
      Value<String?>? indicativePreteriteYo,
      Value<String?>? indicativePreteriteTu,
      Value<String?>? indicativePreteriteEl,
      Value<String?>? indicativePreteriteNosotros,
      Value<String?>? indicativePreteriteVosotros,
      Value<String?>? indicativePreteriteEllos,
      Value<String?>? indicativeImperfectYo,
      Value<String?>? indicativeImperfectTu,
      Value<String?>? indicativeImperfectEl,
      Value<String?>? indicativeImperfectNosotros,
      Value<String?>? indicativeImperfectVosotros,
      Value<String?>? indicativeImperfectEllos,
      Value<String?>? indicativeFutureYo,
      Value<String?>? indicativeFutureTu,
      Value<String?>? indicativeFutureEl,
      Value<String?>? indicativeFutureNosotros,
      Value<String?>? indicativeFutureVosotros,
      Value<String?>? indicativeFutureEllos,
      Value<String?>? indicativeConditionalYo,
      Value<String?>? indicativeConditionalTu,
      Value<String?>? indicativeConditionalEl,
      Value<String?>? indicativeConditionalNosotros,
      Value<String?>? indicativeConditionalVosotros,
      Value<String?>? indicativeConditionalEllos,
      Value<String?>? imperativeTu,
      Value<String?>? imperativeEl,
      Value<String?>? imperativeNosotros,
      Value<String?>? imperativeVosotros,
      Value<String?>? imperativeEllos,
      Value<String?>? subjunctivePresentYo,
      Value<String?>? subjunctivePresentTu,
      Value<String?>? subjunctivePresentEl,
      Value<String?>? subjunctivePresentNosotros,
      Value<String?>? subjunctivePresentVosotros,
      Value<String?>? subjunctivePresentEllos,
      Value<String?>? subjunctivePastYo,
      Value<String?>? subjunctivePastTu,
      Value<String?>? subjunctivePastEl,
      Value<String?>? subjunctivePastNosotros,
      Value<String?>? subjunctivePastVosotros,
      Value<String?>? subjunctivePastEllos}) {
    return ConjugationsCompanion(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      presentParticiple: presentParticiple ?? this.presentParticiple,
      prastParticiple: prastParticiple ?? this.prastParticiple,
      indicativePresentYo: indicativePresentYo ?? this.indicativePresentYo,
      indicativePresentTu: indicativePresentTu ?? this.indicativePresentTu,
      indicativePresentEl: indicativePresentEl ?? this.indicativePresentEl,
      indicativePresentNosotros:
          indicativePresentNosotros ?? this.indicativePresentNosotros,
      indicativePresentVosotros:
          indicativePresentVosotros ?? this.indicativePresentVosotros,
      indicativePresentEllos:
          indicativePresentEllos ?? this.indicativePresentEllos,
      indicativePreteriteYo:
          indicativePreteriteYo ?? this.indicativePreteriteYo,
      indicativePreteriteTu:
          indicativePreteriteTu ?? this.indicativePreteriteTu,
      indicativePreteriteEl:
          indicativePreteriteEl ?? this.indicativePreteriteEl,
      indicativePreteriteNosotros:
          indicativePreteriteNosotros ?? this.indicativePreteriteNosotros,
      indicativePreteriteVosotros:
          indicativePreteriteVosotros ?? this.indicativePreteriteVosotros,
      indicativePreteriteEllos:
          indicativePreteriteEllos ?? this.indicativePreteriteEllos,
      indicativeImperfectYo:
          indicativeImperfectYo ?? this.indicativeImperfectYo,
      indicativeImperfectTu:
          indicativeImperfectTu ?? this.indicativeImperfectTu,
      indicativeImperfectEl:
          indicativeImperfectEl ?? this.indicativeImperfectEl,
      indicativeImperfectNosotros:
          indicativeImperfectNosotros ?? this.indicativeImperfectNosotros,
      indicativeImperfectVosotros:
          indicativeImperfectVosotros ?? this.indicativeImperfectVosotros,
      indicativeImperfectEllos:
          indicativeImperfectEllos ?? this.indicativeImperfectEllos,
      indicativeFutureYo: indicativeFutureYo ?? this.indicativeFutureYo,
      indicativeFutureTu: indicativeFutureTu ?? this.indicativeFutureTu,
      indicativeFutureEl: indicativeFutureEl ?? this.indicativeFutureEl,
      indicativeFutureNosotros:
          indicativeFutureNosotros ?? this.indicativeFutureNosotros,
      indicativeFutureVosotros:
          indicativeFutureVosotros ?? this.indicativeFutureVosotros,
      indicativeFutureEllos:
          indicativeFutureEllos ?? this.indicativeFutureEllos,
      indicativeConditionalYo:
          indicativeConditionalYo ?? this.indicativeConditionalYo,
      indicativeConditionalTu:
          indicativeConditionalTu ?? this.indicativeConditionalTu,
      indicativeConditionalEl:
          indicativeConditionalEl ?? this.indicativeConditionalEl,
      indicativeConditionalNosotros:
          indicativeConditionalNosotros ?? this.indicativeConditionalNosotros,
      indicativeConditionalVosotros:
          indicativeConditionalVosotros ?? this.indicativeConditionalVosotros,
      indicativeConditionalEllos:
          indicativeConditionalEllos ?? this.indicativeConditionalEllos,
      imperativeTu: imperativeTu ?? this.imperativeTu,
      imperativeEl: imperativeEl ?? this.imperativeEl,
      imperativeNosotros: imperativeNosotros ?? this.imperativeNosotros,
      imperativeVosotros: imperativeVosotros ?? this.imperativeVosotros,
      imperativeEllos: imperativeEllos ?? this.imperativeEllos,
      subjunctivePresentYo: subjunctivePresentYo ?? this.subjunctivePresentYo,
      subjunctivePresentTu: subjunctivePresentTu ?? this.subjunctivePresentTu,
      subjunctivePresentEl: subjunctivePresentEl ?? this.subjunctivePresentEl,
      subjunctivePresentNosotros:
          subjunctivePresentNosotros ?? this.subjunctivePresentNosotros,
      subjunctivePresentVosotros:
          subjunctivePresentVosotros ?? this.subjunctivePresentVosotros,
      subjunctivePresentEllos:
          subjunctivePresentEllos ?? this.subjunctivePresentEllos,
      subjunctivePastYo: subjunctivePastYo ?? this.subjunctivePastYo,
      subjunctivePastTu: subjunctivePastTu ?? this.subjunctivePastTu,
      subjunctivePastEl: subjunctivePastEl ?? this.subjunctivePastEl,
      subjunctivePastNosotros:
          subjunctivePastNosotros ?? this.subjunctivePastNosotros,
      subjunctivePastVosotros:
          subjunctivePastVosotros ?? this.subjunctivePastVosotros,
      subjunctivePastEllos: subjunctivePastEllos ?? this.subjunctivePastEllos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (presentParticiple.present) {
      map['present_participle'] = Variable<String>(presentParticiple.value);
    }
    if (prastParticiple.present) {
      map['past_participle'] = Variable<String>(prastParticiple.value);
    }
    if (indicativePresentYo.present) {
      map['indicative_present_yo'] =
          Variable<String>(indicativePresentYo.value);
    }
    if (indicativePresentTu.present) {
      map['indicative_present_tu'] =
          Variable<String>(indicativePresentTu.value);
    }
    if (indicativePresentEl.present) {
      map['indicative_present_el'] =
          Variable<String>(indicativePresentEl.value);
    }
    if (indicativePresentNosotros.present) {
      map['indicative_present_nosotros'] =
          Variable<String>(indicativePresentNosotros.value);
    }
    if (indicativePresentVosotros.present) {
      map['indicative_present_vosotros'] =
          Variable<String>(indicativePresentVosotros.value);
    }
    if (indicativePresentEllos.present) {
      map['indicative_present_ellos'] =
          Variable<String>(indicativePresentEllos.value);
    }
    if (indicativePreteriteYo.present) {
      map['indicative_preterite_yo'] =
          Variable<String>(indicativePreteriteYo.value);
    }
    if (indicativePreteriteTu.present) {
      map['indicative_preterite_tu'] =
          Variable<String>(indicativePreteriteTu.value);
    }
    if (indicativePreteriteEl.present) {
      map['indicative_preterite_el'] =
          Variable<String>(indicativePreteriteEl.value);
    }
    if (indicativePreteriteNosotros.present) {
      map['indicative_preterite_nosotros'] =
          Variable<String>(indicativePreteriteNosotros.value);
    }
    if (indicativePreteriteVosotros.present) {
      map['indicative_preterite_vosotros'] =
          Variable<String>(indicativePreteriteVosotros.value);
    }
    if (indicativePreteriteEllos.present) {
      map['indicative_preterite_ellos'] =
          Variable<String>(indicativePreteriteEllos.value);
    }
    if (indicativeImperfectYo.present) {
      map['indicative_imperfect_yo'] =
          Variable<String>(indicativeImperfectYo.value);
    }
    if (indicativeImperfectTu.present) {
      map['indicative_imperfect_tu'] =
          Variable<String>(indicativeImperfectTu.value);
    }
    if (indicativeImperfectEl.present) {
      map['indicative_imperfect_el'] =
          Variable<String>(indicativeImperfectEl.value);
    }
    if (indicativeImperfectNosotros.present) {
      map['indicative_imperfect_nosotros'] =
          Variable<String>(indicativeImperfectNosotros.value);
    }
    if (indicativeImperfectVosotros.present) {
      map['indicative_imperfect_vosotros'] =
          Variable<String>(indicativeImperfectVosotros.value);
    }
    if (indicativeImperfectEllos.present) {
      map['indicative_imperfect_ellos'] =
          Variable<String>(indicativeImperfectEllos.value);
    }
    if (indicativeFutureYo.present) {
      map['indicative_future_yo'] = Variable<String>(indicativeFutureYo.value);
    }
    if (indicativeFutureTu.present) {
      map['indicative_future_tu'] = Variable<String>(indicativeFutureTu.value);
    }
    if (indicativeFutureEl.present) {
      map['indicative_future_el'] = Variable<String>(indicativeFutureEl.value);
    }
    if (indicativeFutureNosotros.present) {
      map['indicative_future_nosotros'] =
          Variable<String>(indicativeFutureNosotros.value);
    }
    if (indicativeFutureVosotros.present) {
      map['indicative_future_vosotros'] =
          Variable<String>(indicativeFutureVosotros.value);
    }
    if (indicativeFutureEllos.present) {
      map['indicative_future_ellos'] =
          Variable<String>(indicativeFutureEllos.value);
    }
    if (indicativeConditionalYo.present) {
      map['indicative_conditional_yo'] =
          Variable<String>(indicativeConditionalYo.value);
    }
    if (indicativeConditionalTu.present) {
      map['indicative_conditional_tu'] =
          Variable<String>(indicativeConditionalTu.value);
    }
    if (indicativeConditionalEl.present) {
      map['indicative_conditional_el'] =
          Variable<String>(indicativeConditionalEl.value);
    }
    if (indicativeConditionalNosotros.present) {
      map['indicative_conditional_nosotros'] =
          Variable<String>(indicativeConditionalNosotros.value);
    }
    if (indicativeConditionalVosotros.present) {
      map['indicative_conditional_vosotros'] =
          Variable<String>(indicativeConditionalVosotros.value);
    }
    if (indicativeConditionalEllos.present) {
      map['indicative_conditional_ellos'] =
          Variable<String>(indicativeConditionalEllos.value);
    }
    if (imperativeTu.present) {
      map['imperative_tu'] = Variable<String>(imperativeTu.value);
    }
    if (imperativeEl.present) {
      map['imperative_el'] = Variable<String>(imperativeEl.value);
    }
    if (imperativeNosotros.present) {
      map['imperative_nosotros'] = Variable<String>(imperativeNosotros.value);
    }
    if (imperativeVosotros.present) {
      map['imperative_vosotros'] = Variable<String>(imperativeVosotros.value);
    }
    if (imperativeEllos.present) {
      map['imperative_ellos'] = Variable<String>(imperativeEllos.value);
    }
    if (subjunctivePresentYo.present) {
      map['subjunctive_present_yo'] =
          Variable<String>(subjunctivePresentYo.value);
    }
    if (subjunctivePresentTu.present) {
      map['subjunctive_present_tu'] =
          Variable<String>(subjunctivePresentTu.value);
    }
    if (subjunctivePresentEl.present) {
      map['subjunctive_present_el'] =
          Variable<String>(subjunctivePresentEl.value);
    }
    if (subjunctivePresentNosotros.present) {
      map['subjunctive_present_nosotros'] =
          Variable<String>(subjunctivePresentNosotros.value);
    }
    if (subjunctivePresentVosotros.present) {
      map['subjunctive_present_vosotros'] =
          Variable<String>(subjunctivePresentVosotros.value);
    }
    if (subjunctivePresentEllos.present) {
      map['subjunctive_present_ellos'] =
          Variable<String>(subjunctivePresentEllos.value);
    }
    if (subjunctivePastYo.present) {
      map['subjunctive_past_yo'] = Variable<String>(subjunctivePastYo.value);
    }
    if (subjunctivePastTu.present) {
      map['subjunctive_past_tu'] = Variable<String>(subjunctivePastTu.value);
    }
    if (subjunctivePastEl.present) {
      map['subjunctive_past_el'] = Variable<String>(subjunctivePastEl.value);
    }
    if (subjunctivePastNosotros.present) {
      map['subjunctive_past_nosotros'] =
          Variable<String>(subjunctivePastNosotros.value);
    }
    if (subjunctivePastVosotros.present) {
      map['subjunctive_past_vosotros'] =
          Variable<String>(subjunctivePastVosotros.value);
    }
    if (subjunctivePastEllos.present) {
      map['subjunctive_past_ellos'] =
          Variable<String>(subjunctivePastEllos.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConjugationsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('presentParticiple: $presentParticiple, ')
          ..write('prastParticiple: $prastParticiple, ')
          ..write('indicativePresentYo: $indicativePresentYo, ')
          ..write('indicativePresentTu: $indicativePresentTu, ')
          ..write('indicativePresentEl: $indicativePresentEl, ')
          ..write('indicativePresentNosotros: $indicativePresentNosotros, ')
          ..write('indicativePresentVosotros: $indicativePresentVosotros, ')
          ..write('indicativePresentEllos: $indicativePresentEllos, ')
          ..write('indicativePreteriteYo: $indicativePreteriteYo, ')
          ..write('indicativePreteriteTu: $indicativePreteriteTu, ')
          ..write('indicativePreteriteEl: $indicativePreteriteEl, ')
          ..write('indicativePreteriteNosotros: $indicativePreteriteNosotros, ')
          ..write('indicativePreteriteVosotros: $indicativePreteriteVosotros, ')
          ..write('indicativePreteriteEllos: $indicativePreteriteEllos, ')
          ..write('indicativeImperfectYo: $indicativeImperfectYo, ')
          ..write('indicativeImperfectTu: $indicativeImperfectTu, ')
          ..write('indicativeImperfectEl: $indicativeImperfectEl, ')
          ..write('indicativeImperfectNosotros: $indicativeImperfectNosotros, ')
          ..write('indicativeImperfectVosotros: $indicativeImperfectVosotros, ')
          ..write('indicativeImperfectEllos: $indicativeImperfectEllos, ')
          ..write('indicativeFutureYo: $indicativeFutureYo, ')
          ..write('indicativeFutureTu: $indicativeFutureTu, ')
          ..write('indicativeFutureEl: $indicativeFutureEl, ')
          ..write('indicativeFutureNosotros: $indicativeFutureNosotros, ')
          ..write('indicativeFutureVosotros: $indicativeFutureVosotros, ')
          ..write('indicativeFutureEllos: $indicativeFutureEllos, ')
          ..write('indicativeConditionalYo: $indicativeConditionalYo, ')
          ..write('indicativeConditionalTu: $indicativeConditionalTu, ')
          ..write('indicativeConditionalEl: $indicativeConditionalEl, ')
          ..write(
              'indicativeConditionalNosotros: $indicativeConditionalNosotros, ')
          ..write(
              'indicativeConditionalVosotros: $indicativeConditionalVosotros, ')
          ..write('indicativeConditionalEllos: $indicativeConditionalEllos, ')
          ..write('imperativeTu: $imperativeTu, ')
          ..write('imperativeEl: $imperativeEl, ')
          ..write('imperativeNosotros: $imperativeNosotros, ')
          ..write('imperativeVosotros: $imperativeVosotros, ')
          ..write('imperativeEllos: $imperativeEllos, ')
          ..write('subjunctivePresentYo: $subjunctivePresentYo, ')
          ..write('subjunctivePresentTu: $subjunctivePresentTu, ')
          ..write('subjunctivePresentEl: $subjunctivePresentEl, ')
          ..write('subjunctivePresentNosotros: $subjunctivePresentNosotros, ')
          ..write('subjunctivePresentVosotros: $subjunctivePresentVosotros, ')
          ..write('subjunctivePresentEllos: $subjunctivePresentEllos, ')
          ..write('subjunctivePastYo: $subjunctivePastYo, ')
          ..write('subjunctivePastTu: $subjunctivePastTu, ')
          ..write('subjunctivePastEl: $subjunctivePastEl, ')
          ..write('subjunctivePastNosotros: $subjunctivePastNosotros, ')
          ..write('subjunctivePastVosotros: $subjunctivePastVosotros, ')
          ..write('subjunctivePastEllos: $subjunctivePastEllos')
          ..write(')'))
        .toString();
  }
}

class $DictionariesTable extends Dictionaries
    with TableInfo<$DictionariesTable, Dictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _excfMeta = const VerificationMeta('excf');
  @override
  late final GeneratedColumn<int> excf = GeneratedColumn<int>(
      'excf', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _headwordMeta =
      const VerificationMeta('headword');
  @override
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
      'headword', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partOfSpeechMarkMeta =
      const VerificationMeta('partOfSpeechMark');
  @override
  late final GeneratedColumn<String> partOfSpeechMark = GeneratedColumn<String>(
      'part_of_speech_mark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _htmlRawMeta =
      const VerificationMeta('htmlRaw');
  @override
  late final GeneratedColumn<String> htmlRaw = GeneratedColumn<String>(
      'html_raw', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        dictionaryId,
        wordId,
        word,
        excf,
        headword,
        partOfSpeech,
        partOfSpeechMark,
        content,
        origin,
        htmlRaw
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionaries';
  @override
  VerificationContext validateIntegrity(Insertable<Dictionary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('excf')) {
      context.handle(
          _excfMeta, excf.isAcceptableOrUnknown(data['excf']!, _excfMeta));
    }
    if (data.containsKey('headword')) {
      context.handle(_headwordMeta,
          headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta));
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    }
    if (data.containsKey('part_of_speech_mark')) {
      context.handle(
          _partOfSpeechMarkMeta,
          partOfSpeechMark.isAcceptableOrUnknown(
              data['part_of_speech_mark']!, _partOfSpeechMarkMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    }
    if (data.containsKey('html_raw')) {
      context.handle(_htmlRawMeta,
          htmlRaw.isAcceptableOrUnknown(data['html_raw']!, _htmlRawMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dictionaryId};
  @override
  Dictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dictionary(
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      excf: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}excf']),
      headword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headword']),
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech']),
      partOfSpeechMark: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}part_of_speech_mark']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin']),
      htmlRaw: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html_raw']),
    );
  }

  @override
  $DictionariesTable createAlias(String alias) {
    return $DictionariesTable(attachedDatabase, alias);
  }
}

class Dictionary extends DataClass implements Insertable<Dictionary> {
  final int dictionaryId;
  final int wordId;
  final String word;
  final int? excf;
  final String? headword;
  final String? partOfSpeech;
  final String? partOfSpeechMark;
  final String? content;
  final String? origin;
  final String? htmlRaw;
  const Dictionary(
      {required this.dictionaryId,
      required this.wordId,
      required this.word,
      this.excf,
      this.headword,
      this.partOfSpeech,
      this.partOfSpeechMark,
      this.content,
      this.origin,
      this.htmlRaw});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['word_id'] = Variable<int>(wordId);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || excf != null) {
      map['excf'] = Variable<int>(excf);
    }
    if (!nullToAbsent || headword != null) {
      map['headword'] = Variable<String>(headword);
    }
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || partOfSpeechMark != null) {
      map['part_of_speech_mark'] = Variable<String>(partOfSpeechMark);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || htmlRaw != null) {
      map['html_raw'] = Variable<String>(htmlRaw);
    }
    return map;
  }

  DictionariesCompanion toCompanion(bool nullToAbsent) {
    return DictionariesCompanion(
      dictionaryId: Value(dictionaryId),
      wordId: Value(wordId),
      word: Value(word),
      excf: excf == null && nullToAbsent ? const Value.absent() : Value(excf),
      headword: headword == null && nullToAbsent
          ? const Value.absent()
          : Value(headword),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      partOfSpeechMark: partOfSpeechMark == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeechMark),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      origin:
          origin == null && nullToAbsent ? const Value.absent() : Value(origin),
      htmlRaw: htmlRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(htmlRaw),
    );
  }

  factory Dictionary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dictionary(
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
      excf: serializer.fromJson<int?>(json['excf']),
      headword: serializer.fromJson<String?>(json['headword']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      partOfSpeechMark: serializer.fromJson<String?>(json['partOfSpeechMark']),
      content: serializer.fromJson<String?>(json['content']),
      origin: serializer.fromJson<String?>(json['origin']),
      htmlRaw: serializer.fromJson<String?>(json['htmlRaw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String>(word),
      'excf': serializer.toJson<int?>(excf),
      'headword': serializer.toJson<String?>(headword),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'partOfSpeechMark': serializer.toJson<String?>(partOfSpeechMark),
      'content': serializer.toJson<String?>(content),
      'origin': serializer.toJson<String?>(origin),
      'htmlRaw': serializer.toJson<String?>(htmlRaw),
    };
  }

  Dictionary copyWith(
          {int? dictionaryId,
          int? wordId,
          String? word,
          Value<int?> excf = const Value.absent(),
          Value<String?> headword = const Value.absent(),
          Value<String?> partOfSpeech = const Value.absent(),
          Value<String?> partOfSpeechMark = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> origin = const Value.absent(),
          Value<String?> htmlRaw = const Value.absent()}) =>
      Dictionary(
        dictionaryId: dictionaryId ?? this.dictionaryId,
        wordId: wordId ?? this.wordId,
        word: word ?? this.word,
        excf: excf.present ? excf.value : this.excf,
        headword: headword.present ? headword.value : this.headword,
        partOfSpeech:
            partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
        partOfSpeechMark: partOfSpeechMark.present
            ? partOfSpeechMark.value
            : this.partOfSpeechMark,
        content: content.present ? content.value : this.content,
        origin: origin.present ? origin.value : this.origin,
        htmlRaw: htmlRaw.present ? htmlRaw.value : this.htmlRaw,
      );
  Dictionary copyWithCompanion(DictionariesCompanion data) {
    return Dictionary(
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      excf: data.excf.present ? data.excf.value : this.excf,
      headword: data.headword.present ? data.headword.value : this.headword,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      partOfSpeechMark: data.partOfSpeechMark.present
          ? data.partOfSpeechMark.value
          : this.partOfSpeechMark,
      content: data.content.present ? data.content.value : this.content,
      origin: data.origin.present ? data.origin.value : this.origin,
      htmlRaw: data.htmlRaw.present ? data.htmlRaw.value : this.htmlRaw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dictionary(')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('excf: $excf, ')
          ..write('headword: $headword, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('partOfSpeechMark: $partOfSpeechMark, ')
          ..write('content: $content, ')
          ..write('origin: $origin, ')
          ..write('htmlRaw: $htmlRaw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dictionaryId, wordId, word, excf, headword,
      partOfSpeech, partOfSpeechMark, content, origin, htmlRaw);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dictionary &&
          other.dictionaryId == this.dictionaryId &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.excf == this.excf &&
          other.headword == this.headword &&
          other.partOfSpeech == this.partOfSpeech &&
          other.partOfSpeechMark == this.partOfSpeechMark &&
          other.content == this.content &&
          other.origin == this.origin &&
          other.htmlRaw == this.htmlRaw);
}

class DictionariesCompanion extends UpdateCompanion<Dictionary> {
  final Value<int> dictionaryId;
  final Value<int> wordId;
  final Value<String> word;
  final Value<int?> excf;
  final Value<String?> headword;
  final Value<String?> partOfSpeech;
  final Value<String?> partOfSpeechMark;
  final Value<String?> content;
  final Value<String?> origin;
  final Value<String?> htmlRaw;
  const DictionariesCompanion({
    this.dictionaryId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.excf = const Value.absent(),
    this.headword = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.partOfSpeechMark = const Value.absent(),
    this.content = const Value.absent(),
    this.origin = const Value.absent(),
    this.htmlRaw = const Value.absent(),
  });
  DictionariesCompanion.insert({
    this.dictionaryId = const Value.absent(),
    required int wordId,
    required String word,
    this.excf = const Value.absent(),
    this.headword = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.partOfSpeechMark = const Value.absent(),
    this.content = const Value.absent(),
    this.origin = const Value.absent(),
    this.htmlRaw = const Value.absent(),
  })  : wordId = Value(wordId),
        word = Value(word);
  static Insertable<Dictionary> custom({
    Expression<int>? dictionaryId,
    Expression<int>? wordId,
    Expression<String>? word,
    Expression<int>? excf,
    Expression<String>? headword,
    Expression<String>? partOfSpeech,
    Expression<String>? partOfSpeechMark,
    Expression<String>? content,
    Expression<String>? origin,
    Expression<String>? htmlRaw,
  }) {
    return RawValuesInsertable({
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (wordId != null) 'word_id': wordId,
      if (word != null) 'word': word,
      if (excf != null) 'excf': excf,
      if (headword != null) 'headword': headword,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (partOfSpeechMark != null) 'part_of_speech_mark': partOfSpeechMark,
      if (content != null) 'content': content,
      if (origin != null) 'origin': origin,
      if (htmlRaw != null) 'html_raw': htmlRaw,
    });
  }

  DictionariesCompanion copyWith(
      {Value<int>? dictionaryId,
      Value<int>? wordId,
      Value<String>? word,
      Value<int?>? excf,
      Value<String?>? headword,
      Value<String?>? partOfSpeech,
      Value<String?>? partOfSpeechMark,
      Value<String?>? content,
      Value<String?>? origin,
      Value<String?>? htmlRaw}) {
    return DictionariesCompanion(
      dictionaryId: dictionaryId ?? this.dictionaryId,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      excf: excf ?? this.excf,
      headword: headword ?? this.headword,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      partOfSpeechMark: partOfSpeechMark ?? this.partOfSpeechMark,
      content: content ?? this.content,
      origin: origin ?? this.origin,
      htmlRaw: htmlRaw ?? this.htmlRaw,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (excf.present) {
      map['excf'] = Variable<int>(excf.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (partOfSpeechMark.present) {
      map['part_of_speech_mark'] = Variable<String>(partOfSpeechMark.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (htmlRaw.present) {
      map['html_raw'] = Variable<String>(htmlRaw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionariesCompanion(')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('excf: $excf, ')
          ..write('headword: $headword, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('partOfSpeechMark: $partOfSpeechMark, ')
          ..write('content: $content, ')
          ..write('origin: $origin, ')
          ..write('htmlRaw: $htmlRaw')
          ..write(')'))
        .toString();
  }
}

class $ExamplesTable extends Examples with TableInfo<$ExamplesTable, Example> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exampleIdMeta =
      const VerificationMeta('exampleId');
  @override
  late final GeneratedColumn<int> exampleId = GeneratedColumn<int>(
      'example_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exampleNoMeta =
      const VerificationMeta('exampleNo');
  @override
  late final GeneratedColumn<int> exampleNo = GeneratedColumn<int>(
      'example_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _espanolHtmlMeta =
      const VerificationMeta('espanolHtml');
  @override
  late final GeneratedColumn<String> espanolHtml = GeneratedColumn<String>(
      'espanol_html', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _japaneseTextMeta =
      const VerificationMeta('japaneseText');
  @override
  late final GeneratedColumn<String> japaneseText = GeneratedColumn<String>(
      'japanese_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _espanolTextMeta =
      const VerificationMeta('espanolText');
  @override
  late final GeneratedColumn<String> espanolText = GeneratedColumn<String>(
      'espanol_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        exampleId,
        dictionaryId,
        exampleNo,
        espanolHtml,
        japaneseText,
        espanolText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examples';
  @override
  VerificationContext validateIntegrity(Insertable<Example> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('example_id')) {
      context.handle(_exampleIdMeta,
          exampleId.isAcceptableOrUnknown(data['example_id']!, _exampleIdMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('example_no')) {
      context.handle(_exampleNoMeta,
          exampleNo.isAcceptableOrUnknown(data['example_no']!, _exampleNoMeta));
    } else if (isInserting) {
      context.missing(_exampleNoMeta);
    }
    if (data.containsKey('espanol_html')) {
      context.handle(
          _espanolHtmlMeta,
          espanolHtml.isAcceptableOrUnknown(
              data['espanol_html']!, _espanolHtmlMeta));
    } else if (isInserting) {
      context.missing(_espanolHtmlMeta);
    }
    if (data.containsKey('japanese_text')) {
      context.handle(
          _japaneseTextMeta,
          japaneseText.isAcceptableOrUnknown(
              data['japanese_text']!, _japaneseTextMeta));
    } else if (isInserting) {
      context.missing(_japaneseTextMeta);
    }
    if (data.containsKey('espanol_text')) {
      context.handle(
          _espanolTextMeta,
          espanolText.isAcceptableOrUnknown(
              data['espanol_text']!, _espanolTextMeta));
    } else if (isInserting) {
      context.missing(_espanolTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exampleId};
  @override
  Example map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Example(
      exampleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}example_id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      exampleNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}example_no'])!,
      espanolHtml: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}espanol_html'])!,
      japaneseText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}japanese_text'])!,
      espanolText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}espanol_text'])!,
    );
  }

  @override
  $ExamplesTable createAlias(String alias) {
    return $ExamplesTable(attachedDatabase, alias);
  }
}

class Example extends DataClass implements Insertable<Example> {
  final int exampleId;
  final int dictionaryId;
  final int exampleNo;
  final String espanolHtml;
  final String japaneseText;
  final String espanolText;
  const Example(
      {required this.exampleId,
      required this.dictionaryId,
      required this.exampleNo,
      required this.espanolHtml,
      required this.japaneseText,
      required this.espanolText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['example_id'] = Variable<int>(exampleId);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['example_no'] = Variable<int>(exampleNo);
    map['espanol_html'] = Variable<String>(espanolHtml);
    map['japanese_text'] = Variable<String>(japaneseText);
    map['espanol_text'] = Variable<String>(espanolText);
    return map;
  }

  ExamplesCompanion toCompanion(bool nullToAbsent) {
    return ExamplesCompanion(
      exampleId: Value(exampleId),
      dictionaryId: Value(dictionaryId),
      exampleNo: Value(exampleNo),
      espanolHtml: Value(espanolHtml),
      japaneseText: Value(japaneseText),
      espanolText: Value(espanolText),
    );
  }

  factory Example.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Example(
      exampleId: serializer.fromJson<int>(json['exampleId']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      exampleNo: serializer.fromJson<int>(json['exampleNo']),
      espanolHtml: serializer.fromJson<String>(json['espanolHtml']),
      japaneseText: serializer.fromJson<String>(json['japaneseText']),
      espanolText: serializer.fromJson<String>(json['espanolText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exampleId': serializer.toJson<int>(exampleId),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'exampleNo': serializer.toJson<int>(exampleNo),
      'espanolHtml': serializer.toJson<String>(espanolHtml),
      'japaneseText': serializer.toJson<String>(japaneseText),
      'espanolText': serializer.toJson<String>(espanolText),
    };
  }

  Example copyWith(
          {int? exampleId,
          int? dictionaryId,
          int? exampleNo,
          String? espanolHtml,
          String? japaneseText,
          String? espanolText}) =>
      Example(
        exampleId: exampleId ?? this.exampleId,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        exampleNo: exampleNo ?? this.exampleNo,
        espanolHtml: espanolHtml ?? this.espanolHtml,
        japaneseText: japaneseText ?? this.japaneseText,
        espanolText: espanolText ?? this.espanolText,
      );
  Example copyWithCompanion(ExamplesCompanion data) {
    return Example(
      exampleId: data.exampleId.present ? data.exampleId.value : this.exampleId,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      exampleNo: data.exampleNo.present ? data.exampleNo.value : this.exampleNo,
      espanolHtml:
          data.espanolHtml.present ? data.espanolHtml.value : this.espanolHtml,
      japaneseText: data.japaneseText.present
          ? data.japaneseText.value
          : this.japaneseText,
      espanolText:
          data.espanolText.present ? data.espanolText.value : this.espanolText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Example(')
          ..write('exampleId: $exampleId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('exampleNo: $exampleNo, ')
          ..write('espanolHtml: $espanolHtml, ')
          ..write('japaneseText: $japaneseText, ')
          ..write('espanolText: $espanolText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exampleId, dictionaryId, exampleNo,
      espanolHtml, japaneseText, espanolText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Example &&
          other.exampleId == this.exampleId &&
          other.dictionaryId == this.dictionaryId &&
          other.exampleNo == this.exampleNo &&
          other.espanolHtml == this.espanolHtml &&
          other.japaneseText == this.japaneseText &&
          other.espanolText == this.espanolText);
}

class ExamplesCompanion extends UpdateCompanion<Example> {
  final Value<int> exampleId;
  final Value<int> dictionaryId;
  final Value<int> exampleNo;
  final Value<String> espanolHtml;
  final Value<String> japaneseText;
  final Value<String> espanolText;
  const ExamplesCompanion({
    this.exampleId = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.exampleNo = const Value.absent(),
    this.espanolHtml = const Value.absent(),
    this.japaneseText = const Value.absent(),
    this.espanolText = const Value.absent(),
  });
  ExamplesCompanion.insert({
    this.exampleId = const Value.absent(),
    required int dictionaryId,
    required int exampleNo,
    required String espanolHtml,
    required String japaneseText,
    required String espanolText,
  })  : dictionaryId = Value(dictionaryId),
        exampleNo = Value(exampleNo),
        espanolHtml = Value(espanolHtml),
        japaneseText = Value(japaneseText),
        espanolText = Value(espanolText);
  static Insertable<Example> custom({
    Expression<int>? exampleId,
    Expression<int>? dictionaryId,
    Expression<int>? exampleNo,
    Expression<String>? espanolHtml,
    Expression<String>? japaneseText,
    Expression<String>? espanolText,
  }) {
    return RawValuesInsertable({
      if (exampleId != null) 'example_id': exampleId,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (exampleNo != null) 'example_no': exampleNo,
      if (espanolHtml != null) 'espanol_html': espanolHtml,
      if (japaneseText != null) 'japanese_text': japaneseText,
      if (espanolText != null) 'espanol_text': espanolText,
    });
  }

  ExamplesCompanion copyWith(
      {Value<int>? exampleId,
      Value<int>? dictionaryId,
      Value<int>? exampleNo,
      Value<String>? espanolHtml,
      Value<String>? japaneseText,
      Value<String>? espanolText}) {
    return ExamplesCompanion(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      exampleNo: exampleNo ?? this.exampleNo,
      espanolHtml: espanolHtml ?? this.espanolHtml,
      japaneseText: japaneseText ?? this.japaneseText,
      espanolText: espanolText ?? this.espanolText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exampleId.present) {
      map['example_id'] = Variable<int>(exampleId.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (exampleNo.present) {
      map['example_no'] = Variable<int>(exampleNo.value);
    }
    if (espanolHtml.present) {
      map['espanol_html'] = Variable<String>(espanolHtml.value);
    }
    if (japaneseText.present) {
      map['japanese_text'] = Variable<String>(japaneseText.value);
    }
    if (espanolText.present) {
      map['espanol_text'] = Variable<String>(espanolText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamplesCompanion(')
          ..write('exampleId: $exampleId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('exampleNo: $exampleNo, ')
          ..write('espanolHtml: $espanolHtml, ')
          ..write('japaneseText: $japaneseText, ')
          ..write('espanolText: $espanolText')
          ..write(')'))
        .toString();
  }
}

class $IdiomsTable extends Idioms with TableInfo<$IdiomsTable, Idiom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdiomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idiomIdMeta =
      const VerificationMeta('idiomId');
  @override
  late final GeneratedColumn<int> idiomId = GeneratedColumn<int>(
      'idiom_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idiomNoMeta =
      const VerificationMeta('idiomNo');
  @override
  late final GeneratedColumn<int> idiomNo = GeneratedColumn<int>(
      'idiom_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idiomMeta = const VerificationMeta('idiom');
  @override
  late final GeneratedColumn<String> idiom = GeneratedColumn<String>(
      'idiom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [idiomId, dictionaryId, idiomNo, idiom, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'idioms';
  @override
  VerificationContext validateIntegrity(Insertable<Idiom> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idiom_id')) {
      context.handle(_idiomIdMeta,
          idiomId.isAcceptableOrUnknown(data['idiom_id']!, _idiomIdMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('idiom_no')) {
      context.handle(_idiomNoMeta,
          idiomNo.isAcceptableOrUnknown(data['idiom_no']!, _idiomNoMeta));
    } else if (isInserting) {
      context.missing(_idiomNoMeta);
    }
    if (data.containsKey('idiom')) {
      context.handle(
          _idiomMeta, idiom.isAcceptableOrUnknown(data['idiom']!, _idiomMeta));
    } else if (isInserting) {
      context.missing(_idiomMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idiomId};
  @override
  Idiom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Idiom(
      idiomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idiom_id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      idiomNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idiom_no'])!,
      idiom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idiom'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $IdiomsTable createAlias(String alias) {
    return $IdiomsTable(attachedDatabase, alias);
  }
}

class Idiom extends DataClass implements Insertable<Idiom> {
  final int idiomId;
  final int dictionaryId;
  final int idiomNo;
  final String idiom;
  final String description;
  const Idiom(
      {required this.idiomId,
      required this.dictionaryId,
      required this.idiomNo,
      required this.idiom,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idiom_id'] = Variable<int>(idiomId);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['idiom_no'] = Variable<int>(idiomNo);
    map['idiom'] = Variable<String>(idiom);
    map['description'] = Variable<String>(description);
    return map;
  }

  IdiomsCompanion toCompanion(bool nullToAbsent) {
    return IdiomsCompanion(
      idiomId: Value(idiomId),
      dictionaryId: Value(dictionaryId),
      idiomNo: Value(idiomNo),
      idiom: Value(idiom),
      description: Value(description),
    );
  }

  factory Idiom.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Idiom(
      idiomId: serializer.fromJson<int>(json['idiomId']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      idiomNo: serializer.fromJson<int>(json['idiomNo']),
      idiom: serializer.fromJson<String>(json['idiom']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idiomId': serializer.toJson<int>(idiomId),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'idiomNo': serializer.toJson<int>(idiomNo),
      'idiom': serializer.toJson<String>(idiom),
      'description': serializer.toJson<String>(description),
    };
  }

  Idiom copyWith(
          {int? idiomId,
          int? dictionaryId,
          int? idiomNo,
          String? idiom,
          String? description}) =>
      Idiom(
        idiomId: idiomId ?? this.idiomId,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        idiomNo: idiomNo ?? this.idiomNo,
        idiom: idiom ?? this.idiom,
        description: description ?? this.description,
      );
  Idiom copyWithCompanion(IdiomsCompanion data) {
    return Idiom(
      idiomId: data.idiomId.present ? data.idiomId.value : this.idiomId,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      idiomNo: data.idiomNo.present ? data.idiomNo.value : this.idiomNo,
      idiom: data.idiom.present ? data.idiom.value : this.idiom,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Idiom(')
          ..write('idiomId: $idiomId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('idiomNo: $idiomNo, ')
          ..write('idiom: $idiom, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(idiomId, dictionaryId, idiomNo, idiom, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Idiom &&
          other.idiomId == this.idiomId &&
          other.dictionaryId == this.dictionaryId &&
          other.idiomNo == this.idiomNo &&
          other.idiom == this.idiom &&
          other.description == this.description);
}

class IdiomsCompanion extends UpdateCompanion<Idiom> {
  final Value<int> idiomId;
  final Value<int> dictionaryId;
  final Value<int> idiomNo;
  final Value<String> idiom;
  final Value<String> description;
  const IdiomsCompanion({
    this.idiomId = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.idiomNo = const Value.absent(),
    this.idiom = const Value.absent(),
    this.description = const Value.absent(),
  });
  IdiomsCompanion.insert({
    this.idiomId = const Value.absent(),
    required int dictionaryId,
    required int idiomNo,
    required String idiom,
    required String description,
  })  : dictionaryId = Value(dictionaryId),
        idiomNo = Value(idiomNo),
        idiom = Value(idiom),
        description = Value(description);
  static Insertable<Idiom> custom({
    Expression<int>? idiomId,
    Expression<int>? dictionaryId,
    Expression<int>? idiomNo,
    Expression<String>? idiom,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (idiomId != null) 'idiom_id': idiomId,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (idiomNo != null) 'idiom_no': idiomNo,
      if (idiom != null) 'idiom': idiom,
      if (description != null) 'description': description,
    });
  }

  IdiomsCompanion copyWith(
      {Value<int>? idiomId,
      Value<int>? dictionaryId,
      Value<int>? idiomNo,
      Value<String>? idiom,
      Value<String>? description}) {
    return IdiomsCompanion(
      idiomId: idiomId ?? this.idiomId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      idiomNo: idiomNo ?? this.idiomNo,
      idiom: idiom ?? this.idiom,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idiomId.present) {
      map['idiom_id'] = Variable<int>(idiomId.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (idiomNo.present) {
      map['idiom_no'] = Variable<int>(idiomNo.value);
    }
    if (idiom.present) {
      map['idiom'] = Variable<String>(idiom.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdiomsCompanion(')
          ..write('idiomId: $idiomId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('idiomNo: $idiomNo, ')
          ..write('idiom: $idiom, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $PartOfSpeechListsTable extends PartOfSpeechLists
    with TableInfo<$PartOfSpeechListsTable, PartOfSpeechList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartOfSpeechListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _partOfSpeechIdMeta =
      const VerificationMeta('partOfSpeechId');
  @override
  late final GeneratedColumn<int> partOfSpeechId = GeneratedColumn<int>(
      'part_of_speech_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [partOfSpeechId, wordId, partOfSpeech];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_of_speech_lists';
  @override
  VerificationContext validateIntegrity(Insertable<PartOfSpeechList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('part_of_speech_id')) {
      context.handle(
          _partOfSpeechIdMeta,
          partOfSpeechId.isAcceptableOrUnknown(
              data['part_of_speech_id']!, _partOfSpeechIdMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    } else if (isInserting) {
      context.missing(_partOfSpeechMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {partOfSpeechId};
  @override
  PartOfSpeechList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartOfSpeechList(
      partOfSpeechId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}part_of_speech_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech'])!,
    );
  }

  @override
  $PartOfSpeechListsTable createAlias(String alias) {
    return $PartOfSpeechListsTable(attachedDatabase, alias);
  }
}

class PartOfSpeechList extends DataClass
    implements Insertable<PartOfSpeechList> {
  final int partOfSpeechId;
  final int wordId;
  final String partOfSpeech;
  const PartOfSpeechList(
      {required this.partOfSpeechId,
      required this.wordId,
      required this.partOfSpeech});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['part_of_speech_id'] = Variable<int>(partOfSpeechId);
    map['word_id'] = Variable<int>(wordId);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    return map;
  }

  PartOfSpeechListsCompanion toCompanion(bool nullToAbsent) {
    return PartOfSpeechListsCompanion(
      partOfSpeechId: Value(partOfSpeechId),
      wordId: Value(wordId),
      partOfSpeech: Value(partOfSpeech),
    );
  }

  factory PartOfSpeechList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartOfSpeechList(
      partOfSpeechId: serializer.fromJson<int>(json['partOfSpeechId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'partOfSpeechId': serializer.toJson<int>(partOfSpeechId),
      'wordId': serializer.toJson<int>(wordId),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
    };
  }

  PartOfSpeechList copyWith(
          {int? partOfSpeechId, int? wordId, String? partOfSpeech}) =>
      PartOfSpeechList(
        partOfSpeechId: partOfSpeechId ?? this.partOfSpeechId,
        wordId: wordId ?? this.wordId,
        partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      );
  PartOfSpeechList copyWithCompanion(PartOfSpeechListsCompanion data) {
    return PartOfSpeechList(
      partOfSpeechId: data.partOfSpeechId.present
          ? data.partOfSpeechId.value
          : this.partOfSpeechId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartOfSpeechList(')
          ..write('partOfSpeechId: $partOfSpeechId, ')
          ..write('wordId: $wordId, ')
          ..write('partOfSpeech: $partOfSpeech')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(partOfSpeechId, wordId, partOfSpeech);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartOfSpeechList &&
          other.partOfSpeechId == this.partOfSpeechId &&
          other.wordId == this.wordId &&
          other.partOfSpeech == this.partOfSpeech);
}

class PartOfSpeechListsCompanion extends UpdateCompanion<PartOfSpeechList> {
  final Value<int> partOfSpeechId;
  final Value<int> wordId;
  final Value<String> partOfSpeech;
  const PartOfSpeechListsCompanion({
    this.partOfSpeechId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
  });
  PartOfSpeechListsCompanion.insert({
    this.partOfSpeechId = const Value.absent(),
    required int wordId,
    required String partOfSpeech,
  })  : wordId = Value(wordId),
        partOfSpeech = Value(partOfSpeech);
  static Insertable<PartOfSpeechList> custom({
    Expression<int>? partOfSpeechId,
    Expression<int>? wordId,
    Expression<String>? partOfSpeech,
  }) {
    return RawValuesInsertable({
      if (partOfSpeechId != null) 'part_of_speech_id': partOfSpeechId,
      if (wordId != null) 'word_id': wordId,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
    });
  }

  PartOfSpeechListsCompanion copyWith(
      {Value<int>? partOfSpeechId,
      Value<int>? wordId,
      Value<String>? partOfSpeech}) {
    return PartOfSpeechListsCompanion(
      partOfSpeechId: partOfSpeechId ?? this.partOfSpeechId,
      wordId: wordId ?? this.wordId,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (partOfSpeechId.present) {
      map['part_of_speech_id'] = Variable<int>(partOfSpeechId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartOfSpeechListsCompanion(')
          ..write('partOfSpeechId: $partOfSpeechId, ')
          ..write('wordId: $wordId, ')
          ..write('partOfSpeech: $partOfSpeech')
          ..write(')'))
        .toString();
  }
}

class $RankingsTable extends Rankings with TableInfo<$RankingsTable, Ranking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RankingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rankingIdMeta =
      const VerificationMeta('rankingId');
  @override
  late final GeneratedColumn<int> rankingId = GeneratedColumn<int>(
      'ranking_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rankingNoMeta =
      const VerificationMeta('rankingNo');
  @override
  late final GeneratedColumn<int> rankingNo = GeneratedColumn<int>(
      'ranking_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordOriginMeta =
      const VerificationMeta('wordOrigin');
  @override
  late final GeneratedColumn<String> wordOrigin = GeneratedColumn<String>(
      'word_origin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasConjMeta =
      const VerificationMeta('hasConj');
  @override
  late final GeneratedColumn<int> hasConj = GeneratedColumn<int>(
      'has_conj', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [rankingId, rankingNo, word, wordOrigin, wordId, hasConj];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rankings';
  @override
  VerificationContext validateIntegrity(Insertable<Ranking> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ranking_id')) {
      context.handle(_rankingIdMeta,
          rankingId.isAcceptableOrUnknown(data['ranking_id']!, _rankingIdMeta));
    }
    if (data.containsKey('ranking_no')) {
      context.handle(_rankingNoMeta,
          rankingNo.isAcceptableOrUnknown(data['ranking_no']!, _rankingNoMeta));
    } else if (isInserting) {
      context.missing(_rankingNoMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    }
    if (data.containsKey('word_origin')) {
      context.handle(
          _wordOriginMeta,
          wordOrigin.isAcceptableOrUnknown(
              data['word_origin']!, _wordOriginMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    }
    if (data.containsKey('has_conj')) {
      context.handle(_hasConjMeta,
          hasConj.isAcceptableOrUnknown(data['has_conj']!, _hasConjMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rankingId};
  @override
  Ranking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ranking(
      rankingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ranking_id'])!,
      rankingNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ranking_no'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word']),
      wordOrigin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_origin']),
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id']),
      hasConj: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}has_conj']),
    );
  }

  @override
  $RankingsTable createAlias(String alias) {
    return $RankingsTable(attachedDatabase, alias);
  }
}

class Ranking extends DataClass implements Insertable<Ranking> {
  final int rankingId;
  final int rankingNo;
  final String? word;
  final String? wordOrigin;
  final int? wordId;
  final int? hasConj;
  const Ranking(
      {required this.rankingId,
      required this.rankingNo,
      this.word,
      this.wordOrigin,
      this.wordId,
      this.hasConj});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ranking_id'] = Variable<int>(rankingId);
    map['ranking_no'] = Variable<int>(rankingNo);
    if (!nullToAbsent || word != null) {
      map['word'] = Variable<String>(word);
    }
    if (!nullToAbsent || wordOrigin != null) {
      map['word_origin'] = Variable<String>(wordOrigin);
    }
    if (!nullToAbsent || wordId != null) {
      map['word_id'] = Variable<int>(wordId);
    }
    if (!nullToAbsent || hasConj != null) {
      map['has_conj'] = Variable<int>(hasConj);
    }
    return map;
  }

  RankingsCompanion toCompanion(bool nullToAbsent) {
    return RankingsCompanion(
      rankingId: Value(rankingId),
      rankingNo: Value(rankingNo),
      word: word == null && nullToAbsent ? const Value.absent() : Value(word),
      wordOrigin: wordOrigin == null && nullToAbsent
          ? const Value.absent()
          : Value(wordOrigin),
      wordId:
          wordId == null && nullToAbsent ? const Value.absent() : Value(wordId),
      hasConj: hasConj == null && nullToAbsent
          ? const Value.absent()
          : Value(hasConj),
    );
  }

  factory Ranking.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ranking(
      rankingId: serializer.fromJson<int>(json['rankingId']),
      rankingNo: serializer.fromJson<int>(json['rankingNo']),
      word: serializer.fromJson<String?>(json['word']),
      wordOrigin: serializer.fromJson<String?>(json['wordOrigin']),
      wordId: serializer.fromJson<int?>(json['wordId']),
      hasConj: serializer.fromJson<int?>(json['hasConj']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rankingId': serializer.toJson<int>(rankingId),
      'rankingNo': serializer.toJson<int>(rankingNo),
      'word': serializer.toJson<String?>(word),
      'wordOrigin': serializer.toJson<String?>(wordOrigin),
      'wordId': serializer.toJson<int?>(wordId),
      'hasConj': serializer.toJson<int?>(hasConj),
    };
  }

  Ranking copyWith(
          {int? rankingId,
          int? rankingNo,
          Value<String?> word = const Value.absent(),
          Value<String?> wordOrigin = const Value.absent(),
          Value<int?> wordId = const Value.absent(),
          Value<int?> hasConj = const Value.absent()}) =>
      Ranking(
        rankingId: rankingId ?? this.rankingId,
        rankingNo: rankingNo ?? this.rankingNo,
        word: word.present ? word.value : this.word,
        wordOrigin: wordOrigin.present ? wordOrigin.value : this.wordOrigin,
        wordId: wordId.present ? wordId.value : this.wordId,
        hasConj: hasConj.present ? hasConj.value : this.hasConj,
      );
  Ranking copyWithCompanion(RankingsCompanion data) {
    return Ranking(
      rankingId: data.rankingId.present ? data.rankingId.value : this.rankingId,
      rankingNo: data.rankingNo.present ? data.rankingNo.value : this.rankingNo,
      word: data.word.present ? data.word.value : this.word,
      wordOrigin:
          data.wordOrigin.present ? data.wordOrigin.value : this.wordOrigin,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      hasConj: data.hasConj.present ? data.hasConj.value : this.hasConj,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ranking(')
          ..write('rankingId: $rankingId, ')
          ..write('rankingNo: $rankingNo, ')
          ..write('word: $word, ')
          ..write('wordOrigin: $wordOrigin, ')
          ..write('wordId: $wordId, ')
          ..write('hasConj: $hasConj')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rankingId, rankingNo, word, wordOrigin, wordId, hasConj);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ranking &&
          other.rankingId == this.rankingId &&
          other.rankingNo == this.rankingNo &&
          other.word == this.word &&
          other.wordOrigin == this.wordOrigin &&
          other.wordId == this.wordId &&
          other.hasConj == this.hasConj);
}

class RankingsCompanion extends UpdateCompanion<Ranking> {
  final Value<int> rankingId;
  final Value<int> rankingNo;
  final Value<String?> word;
  final Value<String?> wordOrigin;
  final Value<int?> wordId;
  final Value<int?> hasConj;
  const RankingsCompanion({
    this.rankingId = const Value.absent(),
    this.rankingNo = const Value.absent(),
    this.word = const Value.absent(),
    this.wordOrigin = const Value.absent(),
    this.wordId = const Value.absent(),
    this.hasConj = const Value.absent(),
  });
  RankingsCompanion.insert({
    this.rankingId = const Value.absent(),
    required int rankingNo,
    this.word = const Value.absent(),
    this.wordOrigin = const Value.absent(),
    this.wordId = const Value.absent(),
    this.hasConj = const Value.absent(),
  }) : rankingNo = Value(rankingNo);
  static Insertable<Ranking> custom({
    Expression<int>? rankingId,
    Expression<int>? rankingNo,
    Expression<String>? word,
    Expression<String>? wordOrigin,
    Expression<int>? wordId,
    Expression<int>? hasConj,
  }) {
    return RawValuesInsertable({
      if (rankingId != null) 'ranking_id': rankingId,
      if (rankingNo != null) 'ranking_no': rankingNo,
      if (word != null) 'word': word,
      if (wordOrigin != null) 'word_origin': wordOrigin,
      if (wordId != null) 'word_id': wordId,
      if (hasConj != null) 'has_conj': hasConj,
    });
  }

  RankingsCompanion copyWith(
      {Value<int>? rankingId,
      Value<int>? rankingNo,
      Value<String?>? word,
      Value<String?>? wordOrigin,
      Value<int?>? wordId,
      Value<int?>? hasConj}) {
    return RankingsCompanion(
      rankingId: rankingId ?? this.rankingId,
      rankingNo: rankingNo ?? this.rankingNo,
      word: word ?? this.word,
      wordOrigin: wordOrigin ?? this.wordOrigin,
      wordId: wordId ?? this.wordId,
      hasConj: hasConj ?? this.hasConj,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rankingId.present) {
      map['ranking_id'] = Variable<int>(rankingId.value);
    }
    if (rankingNo.present) {
      map['ranking_no'] = Variable<int>(rankingNo.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (wordOrigin.present) {
      map['word_origin'] = Variable<String>(wordOrigin.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (hasConj.present) {
      map['has_conj'] = Variable<int>(hasConj.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RankingsCompanion(')
          ..write('rankingId: $rankingId, ')
          ..write('rankingNo: $rankingNo, ')
          ..write('word: $word, ')
          ..write('wordOrigin: $wordOrigin, ')
          ..write('wordId: $wordId, ')
          ..write('hasConj: $hasConj')
          ..write(')'))
        .toString();
  }
}

class $SupplementsTable extends Supplements
    with TableInfo<$SupplementsTable, Supplement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _supplementIdMeta =
      const VerificationMeta('supplementId');
  @override
  late final GeneratedColumn<int> supplementId = GeneratedColumn<int>(
      'supplement_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _supplementNoMeta =
      const VerificationMeta('supplementNo');
  @override
  late final GeneratedColumn<int> supplementNo = GeneratedColumn<int>(
      'supplement_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exampleIdMeta =
      const VerificationMeta('exampleId');
  @override
  late final GeneratedColumn<String> exampleId = GeneratedColumn<String>(
      'example_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [supplementId, dictionaryId, supplementNo, content, exampleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplements';
  @override
  VerificationContext validateIntegrity(Insertable<Supplement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('supplement_id')) {
      context.handle(
          _supplementIdMeta,
          supplementId.isAcceptableOrUnknown(
              data['supplement_id']!, _supplementIdMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('supplement_no')) {
      context.handle(
          _supplementNoMeta,
          supplementNo.isAcceptableOrUnknown(
              data['supplement_no']!, _supplementNoMeta));
    } else if (isInserting) {
      context.missing(_supplementNoMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('example_id')) {
      context.handle(_exampleIdMeta,
          exampleId.isAcceptableOrUnknown(data['example_id']!, _exampleIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {supplementId};
  @override
  Supplement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplement(
      supplementId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supplement_id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      supplementNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supplement_no'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      exampleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_id']),
    );
  }

  @override
  $SupplementsTable createAlias(String alias) {
    return $SupplementsTable(attachedDatabase, alias);
  }
}

class Supplement extends DataClass implements Insertable<Supplement> {
  final int supplementId;
  final int dictionaryId;
  final int supplementNo;
  final String content;
  final String? exampleId;
  const Supplement(
      {required this.supplementId,
      required this.dictionaryId,
      required this.supplementNo,
      required this.content,
      this.exampleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['supplement_id'] = Variable<int>(supplementId);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['supplement_no'] = Variable<int>(supplementNo);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || exampleId != null) {
      map['example_id'] = Variable<String>(exampleId);
    }
    return map;
  }

  SupplementsCompanion toCompanion(bool nullToAbsent) {
    return SupplementsCompanion(
      supplementId: Value(supplementId),
      dictionaryId: Value(dictionaryId),
      supplementNo: Value(supplementNo),
      content: Value(content),
      exampleId: exampleId == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleId),
    );
  }

  factory Supplement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplement(
      supplementId: serializer.fromJson<int>(json['supplementId']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      supplementNo: serializer.fromJson<int>(json['supplementNo']),
      content: serializer.fromJson<String>(json['content']),
      exampleId: serializer.fromJson<String?>(json['exampleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'supplementId': serializer.toJson<int>(supplementId),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'supplementNo': serializer.toJson<int>(supplementNo),
      'content': serializer.toJson<String>(content),
      'exampleId': serializer.toJson<String?>(exampleId),
    };
  }

  Supplement copyWith(
          {int? supplementId,
          int? dictionaryId,
          int? supplementNo,
          String? content,
          Value<String?> exampleId = const Value.absent()}) =>
      Supplement(
        supplementId: supplementId ?? this.supplementId,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        supplementNo: supplementNo ?? this.supplementNo,
        content: content ?? this.content,
        exampleId: exampleId.present ? exampleId.value : this.exampleId,
      );
  Supplement copyWithCompanion(SupplementsCompanion data) {
    return Supplement(
      supplementId: data.supplementId.present
          ? data.supplementId.value
          : this.supplementId,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      supplementNo: data.supplementNo.present
          ? data.supplementNo.value
          : this.supplementNo,
      content: data.content.present ? data.content.value : this.content,
      exampleId: data.exampleId.present ? data.exampleId.value : this.exampleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplement(')
          ..write('supplementId: $supplementId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('supplementNo: $supplementNo, ')
          ..write('content: $content, ')
          ..write('exampleId: $exampleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(supplementId, dictionaryId, supplementNo, content, exampleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplement &&
          other.supplementId == this.supplementId &&
          other.dictionaryId == this.dictionaryId &&
          other.supplementNo == this.supplementNo &&
          other.content == this.content &&
          other.exampleId == this.exampleId);
}

class SupplementsCompanion extends UpdateCompanion<Supplement> {
  final Value<int> supplementId;
  final Value<int> dictionaryId;
  final Value<int> supplementNo;
  final Value<String> content;
  final Value<String?> exampleId;
  const SupplementsCompanion({
    this.supplementId = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.supplementNo = const Value.absent(),
    this.content = const Value.absent(),
    this.exampleId = const Value.absent(),
  });
  SupplementsCompanion.insert({
    this.supplementId = const Value.absent(),
    required int dictionaryId,
    required int supplementNo,
    required String content,
    this.exampleId = const Value.absent(),
  })  : dictionaryId = Value(dictionaryId),
        supplementNo = Value(supplementNo),
        content = Value(content);
  static Insertable<Supplement> custom({
    Expression<int>? supplementId,
    Expression<int>? dictionaryId,
    Expression<int>? supplementNo,
    Expression<String>? content,
    Expression<String>? exampleId,
  }) {
    return RawValuesInsertable({
      if (supplementId != null) 'supplement_id': supplementId,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (supplementNo != null) 'supplement_no': supplementNo,
      if (content != null) 'content': content,
      if (exampleId != null) 'example_id': exampleId,
    });
  }

  SupplementsCompanion copyWith(
      {Value<int>? supplementId,
      Value<int>? dictionaryId,
      Value<int>? supplementNo,
      Value<String>? content,
      Value<String?>? exampleId}) {
    return SupplementsCompanion(
      supplementId: supplementId ?? this.supplementId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      supplementNo: supplementNo ?? this.supplementNo,
      content: content ?? this.content,
      exampleId: exampleId ?? this.exampleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (supplementId.present) {
      map['supplement_id'] = Variable<int>(supplementId.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (supplementNo.present) {
      map['supplement_no'] = Variable<int>(supplementNo.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (exampleId.present) {
      map['example_id'] = Variable<String>(exampleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplementsCompanion(')
          ..write('supplementId: $supplementId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('supplementNo: $supplementNo, ')
          ..write('content: $content, ')
          ..write('exampleId: $exampleId')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partOfSpeechMeta =
      const VerificationMeta('partOfSpeech');
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
      'part_of_speech', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partOfSpeechMarkMeta =
      const VerificationMeta('partOfSpeechMark');
  @override
  late final GeneratedColumn<String> partOfSpeechMark = GeneratedColumn<String>(
      'part_of_speech_mark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [wordId, word, partOfSpeech, partOfSpeechMark];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(Insertable<Word> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
          _partOfSpeechMeta,
          partOfSpeech.isAcceptableOrUnknown(
              data['part_of_speech']!, _partOfSpeechMeta));
    }
    if (data.containsKey('part_of_speech_mark')) {
      context.handle(
          _partOfSpeechMarkMeta,
          partOfSpeechMark.isAcceptableOrUnknown(
              data['part_of_speech_mark']!, _partOfSpeechMarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      partOfSpeech: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_of_speech']),
      partOfSpeechMark: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}part_of_speech_mark']),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int wordId;
  final String word;
  final String? partOfSpeech;
  final String? partOfSpeechMark;
  const Word(
      {required this.wordId,
      required this.word,
      this.partOfSpeech,
      this.partOfSpeechMark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || partOfSpeech != null) {
      map['part_of_speech'] = Variable<String>(partOfSpeech);
    }
    if (!nullToAbsent || partOfSpeechMark != null) {
      map['part_of_speech_mark'] = Variable<String>(partOfSpeechMark);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      wordId: Value(wordId),
      word: Value(word),
      partOfSpeech: partOfSpeech == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeech),
      partOfSpeechMark: partOfSpeechMark == null && nullToAbsent
          ? const Value.absent()
          : Value(partOfSpeechMark),
    );
  }

  factory Word.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
      partOfSpeech: serializer.fromJson<String?>(json['partOfSpeech']),
      partOfSpeechMark: serializer.fromJson<String?>(json['partOfSpeechMark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String>(word),
      'partOfSpeech': serializer.toJson<String?>(partOfSpeech),
      'partOfSpeechMark': serializer.toJson<String?>(partOfSpeechMark),
    };
  }

  Word copyWith(
          {int? wordId,
          String? word,
          Value<String?> partOfSpeech = const Value.absent(),
          Value<String?> partOfSpeechMark = const Value.absent()}) =>
      Word(
        wordId: wordId ?? this.wordId,
        word: word ?? this.word,
        partOfSpeech:
            partOfSpeech.present ? partOfSpeech.value : this.partOfSpeech,
        partOfSpeechMark: partOfSpeechMark.present
            ? partOfSpeechMark.value
            : this.partOfSpeechMark,
      );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      partOfSpeechMark: data.partOfSpeechMark.present
          ? data.partOfSpeechMark.value
          : this.partOfSpeechMark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('partOfSpeechMark: $partOfSpeechMark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, word, partOfSpeech, partOfSpeechMark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.partOfSpeech == this.partOfSpeech &&
          other.partOfSpeechMark == this.partOfSpeechMark);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> wordId;
  final Value<String> word;
  final Value<String?> partOfSpeech;
  final Value<String?> partOfSpeechMark;
  const WordsCompanion({
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.partOfSpeechMark = const Value.absent(),
  });
  WordsCompanion.insert({
    this.wordId = const Value.absent(),
    required String word,
    this.partOfSpeech = const Value.absent(),
    this.partOfSpeechMark = const Value.absent(),
  }) : word = Value(word);
  static Insertable<Word> custom({
    Expression<int>? wordId,
    Expression<String>? word,
    Expression<String>? partOfSpeech,
    Expression<String>? partOfSpeechMark,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (word != null) 'word': word,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (partOfSpeechMark != null) 'part_of_speech_mark': partOfSpeechMark,
    });
  }

  WordsCompanion copyWith(
      {Value<int>? wordId,
      Value<String>? word,
      Value<String?>? partOfSpeech,
      Value<String?>? partOfSpeechMark}) {
    return WordsCompanion(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      partOfSpeechMark: partOfSpeechMark ?? this.partOfSpeechMark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (partOfSpeechMark.present) {
      map['part_of_speech_mark'] = Variable<String>(partOfSpeechMark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('partOfSpeechMark: $partOfSpeechMark')
          ..write(')'))
        .toString();
  }
}

class $WordStatusTable extends WordStatus
    with TableInfo<$WordStatusTable, WordStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isLearnedMeta =
      const VerificationMeta('isLearned');
  @override
  late final GeneratedColumn<int> isLearned = GeneratedColumn<int>(
      'is_learned', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isBookmarkedMeta =
      const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<int> isBookmarked = GeneratedColumn<int>(
      'is_bookmarked', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasNoteMeta =
      const VerificationMeta('hasNote');
  @override
  late final GeneratedColumn<int> hasNote = GeneratedColumn<int>(
      'has_note', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _editAtMeta = const VerificationMeta('editAt');
  @override
  late final GeneratedColumn<String> editAt = GeneratedColumn<String>(
      'edit_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [wordId, isLearned, isBookmarked, hasNote, editAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_status';
  @override
  VerificationContext validateIntegrity(Insertable<WordStatusData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    }
    if (data.containsKey('is_learned')) {
      context.handle(_isLearnedMeta,
          isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta));
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
          _isBookmarkedMeta,
          isBookmarked.isAcceptableOrUnknown(
              data['is_bookmarked']!, _isBookmarkedMeta));
    }
    if (data.containsKey('has_note')) {
      context.handle(_hasNoteMeta,
          hasNote.isAcceptableOrUnknown(data['has_note']!, _hasNoteMeta));
    }
    if (data.containsKey('edit_at')) {
      context.handle(_editAtMeta,
          editAt.isAcceptableOrUnknown(data['edit_at']!, _editAtMeta));
    } else if (isInserting) {
      context.missing(_editAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  WordStatusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordStatusData(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      isLearned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_learned']),
      isBookmarked: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_bookmarked']),
      hasNote: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}has_note']),
      editAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_at'])!,
    );
  }

  @override
  $WordStatusTable createAlias(String alias) {
    return $WordStatusTable(attachedDatabase, alias);
  }
}

class WordStatusData extends DataClass implements Insertable<WordStatusData> {
  final int wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;
  final String editAt;
  const WordStatusData(
      {required this.wordId,
      this.isLearned,
      this.isBookmarked,
      this.hasNote,
      required this.editAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    if (!nullToAbsent || isLearned != null) {
      map['is_learned'] = Variable<int>(isLearned);
    }
    if (!nullToAbsent || isBookmarked != null) {
      map['is_bookmarked'] = Variable<int>(isBookmarked);
    }
    if (!nullToAbsent || hasNote != null) {
      map['has_note'] = Variable<int>(hasNote);
    }
    map['edit_at'] = Variable<String>(editAt);
    return map;
  }

  WordStatusCompanion toCompanion(bool nullToAbsent) {
    return WordStatusCompanion(
      wordId: Value(wordId),
      isLearned: isLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(isLearned),
      isBookmarked: isBookmarked == null && nullToAbsent
          ? const Value.absent()
          : Value(isBookmarked),
      hasNote: hasNote == null && nullToAbsent
          ? const Value.absent()
          : Value(hasNote),
      editAt: Value(editAt),
    );
  }

  factory WordStatusData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordStatusData(
      wordId: serializer.fromJson<int>(json['wordId']),
      isLearned: serializer.fromJson<int?>(json['isLearned']),
      isBookmarked: serializer.fromJson<int?>(json['isBookmarked']),
      hasNote: serializer.fromJson<int?>(json['hasNote']),
      editAt: serializer.fromJson<String>(json['editAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'isLearned': serializer.toJson<int?>(isLearned),
      'isBookmarked': serializer.toJson<int?>(isBookmarked),
      'hasNote': serializer.toJson<int?>(hasNote),
      'editAt': serializer.toJson<String>(editAt),
    };
  }

  WordStatusData copyWith(
          {int? wordId,
          Value<int?> isLearned = const Value.absent(),
          Value<int?> isBookmarked = const Value.absent(),
          Value<int?> hasNote = const Value.absent(),
          String? editAt}) =>
      WordStatusData(
        wordId: wordId ?? this.wordId,
        isLearned: isLearned.present ? isLearned.value : this.isLearned,
        isBookmarked:
            isBookmarked.present ? isBookmarked.value : this.isBookmarked,
        hasNote: hasNote.present ? hasNote.value : this.hasNote,
        editAt: editAt ?? this.editAt,
      );
  WordStatusData copyWithCompanion(WordStatusCompanion data) {
    return WordStatusData(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      hasNote: data.hasNote.present ? data.hasNote.value : this.hasNote,
      editAt: data.editAt.present ? data.editAt.value : this.editAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordStatusData(')
          ..write('wordId: $wordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(wordId, isLearned, isBookmarked, hasNote, editAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordStatusData &&
          other.wordId == this.wordId &&
          other.isLearned == this.isLearned &&
          other.isBookmarked == this.isBookmarked &&
          other.hasNote == this.hasNote &&
          other.editAt == this.editAt);
}

class WordStatusCompanion extends UpdateCompanion<WordStatusData> {
  final Value<int> wordId;
  final Value<int?> isLearned;
  final Value<int?> isBookmarked;
  final Value<int?> hasNote;
  final Value<String> editAt;
  const WordStatusCompanion({
    this.wordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    this.editAt = const Value.absent(),
  });
  WordStatusCompanion.insert({
    this.wordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    required String editAt,
  }) : editAt = Value(editAt);
  static Insertable<WordStatusData> custom({
    Expression<int>? wordId,
    Expression<int>? isLearned,
    Expression<int>? isBookmarked,
    Expression<int>? hasNote,
    Expression<String>? editAt,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (isLearned != null) 'is_learned': isLearned,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (hasNote != null) 'has_note': hasNote,
      if (editAt != null) 'edit_at': editAt,
    });
  }

  WordStatusCompanion copyWith(
      {Value<int>? wordId,
      Value<int?>? isLearned,
      Value<int?>? isBookmarked,
      Value<int?>? hasNote,
      Value<String>? editAt}) {
    return WordStatusCompanion(
      wordId: wordId ?? this.wordId,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
      editAt: editAt ?? this.editAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<int>(isLearned.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<int>(isBookmarked.value);
    }
    if (hasNote.present) {
      map['has_note'] = Variable<int>(hasNote.value);
    }
    if (editAt.present) {
      map['edit_at'] = Variable<String>(editAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordStatusCompanion(')
          ..write('wordId: $wordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }
}

class $MyWordsTable extends MyWords with TableInfo<$MyWordsTable, MyWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _myWordIdMeta =
      const VerificationMeta('myWordId');
  @override
  late final GeneratedColumn<int> myWordId = GeneratedColumn<int>(
      'my_word_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentsMeta =
      const VerificationMeta('contents');
  @override
  late final GeneratedColumn<String> contents = GeneratedColumn<String>(
      'contents', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editAtMeta = const VerificationMeta('editAt');
  @override
  late final GeneratedColumn<String> editAt = GeneratedColumn<String>(
      'edit_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [myWordId, word, contents, editAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_words';
  @override
  VerificationContext validateIntegrity(Insertable<MyWord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('my_word_id')) {
      context.handle(_myWordIdMeta,
          myWordId.isAcceptableOrUnknown(data['my_word_id']!, _myWordIdMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('contents')) {
      context.handle(_contentsMeta,
          contents.isAcceptableOrUnknown(data['contents']!, _contentsMeta));
    }
    if (data.containsKey('edit_at')) {
      context.handle(_editAtMeta,
          editAt.isAcceptableOrUnknown(data['edit_at']!, _editAtMeta));
    } else if (isInserting) {
      context.missing(_editAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {myWordId};
  @override
  MyWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyWord(
      myWordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      contents: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contents']),
      editAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_at'])!,
    );
  }

  @override
  $MyWordsTable createAlias(String alias) {
    return $MyWordsTable(attachedDatabase, alias);
  }
}

class MyWord extends DataClass implements Insertable<MyWord> {
  final int myWordId;
  final String word;
  final String? contents;
  final String editAt;
  const MyWord(
      {required this.myWordId,
      required this.word,
      this.contents,
      required this.editAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['my_word_id'] = Variable<int>(myWordId);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || contents != null) {
      map['contents'] = Variable<String>(contents);
    }
    map['edit_at'] = Variable<String>(editAt);
    return map;
  }

  MyWordsCompanion toCompanion(bool nullToAbsent) {
    return MyWordsCompanion(
      myWordId: Value(myWordId),
      word: Value(word),
      contents: contents == null && nullToAbsent
          ? const Value.absent()
          : Value(contents),
      editAt: Value(editAt),
    );
  }

  factory MyWord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyWord(
      myWordId: serializer.fromJson<int>(json['myWordId']),
      word: serializer.fromJson<String>(json['word']),
      contents: serializer.fromJson<String?>(json['contents']),
      editAt: serializer.fromJson<String>(json['editAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'myWordId': serializer.toJson<int>(myWordId),
      'word': serializer.toJson<String>(word),
      'contents': serializer.toJson<String?>(contents),
      'editAt': serializer.toJson<String>(editAt),
    };
  }

  MyWord copyWith(
          {int? myWordId,
          String? word,
          Value<String?> contents = const Value.absent(),
          String? editAt}) =>
      MyWord(
        myWordId: myWordId ?? this.myWordId,
        word: word ?? this.word,
        contents: contents.present ? contents.value : this.contents,
        editAt: editAt ?? this.editAt,
      );
  MyWord copyWithCompanion(MyWordsCompanion data) {
    return MyWord(
      myWordId: data.myWordId.present ? data.myWordId.value : this.myWordId,
      word: data.word.present ? data.word.value : this.word,
      contents: data.contents.present ? data.contents.value : this.contents,
      editAt: data.editAt.present ? data.editAt.value : this.editAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyWord(')
          ..write('myWordId: $myWordId, ')
          ..write('word: $word, ')
          ..write('contents: $contents, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(myWordId, word, contents, editAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyWord &&
          other.myWordId == this.myWordId &&
          other.word == this.word &&
          other.contents == this.contents &&
          other.editAt == this.editAt);
}

class MyWordsCompanion extends UpdateCompanion<MyWord> {
  final Value<int> myWordId;
  final Value<String> word;
  final Value<String?> contents;
  final Value<String> editAt;
  const MyWordsCompanion({
    this.myWordId = const Value.absent(),
    this.word = const Value.absent(),
    this.contents = const Value.absent(),
    this.editAt = const Value.absent(),
  });
  MyWordsCompanion.insert({
    this.myWordId = const Value.absent(),
    required String word,
    this.contents = const Value.absent(),
    required String editAt,
  })  : word = Value(word),
        editAt = Value(editAt);
  static Insertable<MyWord> custom({
    Expression<int>? myWordId,
    Expression<String>? word,
    Expression<String>? contents,
    Expression<String>? editAt,
  }) {
    return RawValuesInsertable({
      if (myWordId != null) 'my_word_id': myWordId,
      if (word != null) 'word': word,
      if (contents != null) 'contents': contents,
      if (editAt != null) 'edit_at': editAt,
    });
  }

  MyWordsCompanion copyWith(
      {Value<int>? myWordId,
      Value<String>? word,
      Value<String?>? contents,
      Value<String>? editAt}) {
    return MyWordsCompanion(
      myWordId: myWordId ?? this.myWordId,
      word: word ?? this.word,
      contents: contents ?? this.contents,
      editAt: editAt ?? this.editAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (myWordId.present) {
      map['my_word_id'] = Variable<int>(myWordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (contents.present) {
      map['contents'] = Variable<String>(contents.value);
    }
    if (editAt.present) {
      map['edit_at'] = Variable<String>(editAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyWordsCompanion(')
          ..write('myWordId: $myWordId, ')
          ..write('word: $word, ')
          ..write('contents: $contents, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }
}

class $MyWordStatusTable extends MyWordStatus
    with TableInfo<$MyWordStatusTable, MyWordStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyWordStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _myWordIdMeta =
      const VerificationMeta('myWordId');
  @override
  late final GeneratedColumn<int> myWordId = GeneratedColumn<int>(
      'my_word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isLearnedMeta =
      const VerificationMeta('isLearned');
  @override
  late final GeneratedColumn<int> isLearned = GeneratedColumn<int>(
      'is_learned', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isBookmarkedMeta =
      const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<int> isBookmarked = GeneratedColumn<int>(
      'is_bookmarked', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasNoteMeta =
      const VerificationMeta('hasNote');
  @override
  late final GeneratedColumn<int> hasNote = GeneratedColumn<int>(
      'has_note', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _editAtMeta = const VerificationMeta('editAt');
  @override
  late final GeneratedColumn<String> editAt = GeneratedColumn<String>(
      'edit_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [myWordId, isLearned, isBookmarked, hasNote, editAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_word_status';
  @override
  VerificationContext validateIntegrity(Insertable<MyWordStatusData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('my_word_id')) {
      context.handle(_myWordIdMeta,
          myWordId.isAcceptableOrUnknown(data['my_word_id']!, _myWordIdMeta));
    }
    if (data.containsKey('is_learned')) {
      context.handle(_isLearnedMeta,
          isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta));
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
          _isBookmarkedMeta,
          isBookmarked.isAcceptableOrUnknown(
              data['is_bookmarked']!, _isBookmarkedMeta));
    }
    if (data.containsKey('has_note')) {
      context.handle(_hasNoteMeta,
          hasNote.isAcceptableOrUnknown(data['has_note']!, _hasNoteMeta));
    }
    if (data.containsKey('edit_at')) {
      context.handle(_editAtMeta,
          editAt.isAcceptableOrUnknown(data['edit_at']!, _editAtMeta));
    } else if (isInserting) {
      context.missing(_editAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {myWordId};
  @override
  MyWordStatusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyWordStatusData(
      myWordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_word_id'])!,
      isLearned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_learned']),
      isBookmarked: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_bookmarked']),
      hasNote: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}has_note']),
      editAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_at'])!,
    );
  }

  @override
  $MyWordStatusTable createAlias(String alias) {
    return $MyWordStatusTable(attachedDatabase, alias);
  }
}

class MyWordStatusData extends DataClass
    implements Insertable<MyWordStatusData> {
  final int myWordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;
  final String editAt;
  const MyWordStatusData(
      {required this.myWordId,
      this.isLearned,
      this.isBookmarked,
      this.hasNote,
      required this.editAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['my_word_id'] = Variable<int>(myWordId);
    if (!nullToAbsent || isLearned != null) {
      map['is_learned'] = Variable<int>(isLearned);
    }
    if (!nullToAbsent || isBookmarked != null) {
      map['is_bookmarked'] = Variable<int>(isBookmarked);
    }
    if (!nullToAbsent || hasNote != null) {
      map['has_note'] = Variable<int>(hasNote);
    }
    map['edit_at'] = Variable<String>(editAt);
    return map;
  }

  MyWordStatusCompanion toCompanion(bool nullToAbsent) {
    return MyWordStatusCompanion(
      myWordId: Value(myWordId),
      isLearned: isLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(isLearned),
      isBookmarked: isBookmarked == null && nullToAbsent
          ? const Value.absent()
          : Value(isBookmarked),
      hasNote: hasNote == null && nullToAbsent
          ? const Value.absent()
          : Value(hasNote),
      editAt: Value(editAt),
    );
  }

  factory MyWordStatusData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyWordStatusData(
      myWordId: serializer.fromJson<int>(json['myWordId']),
      isLearned: serializer.fromJson<int?>(json['isLearned']),
      isBookmarked: serializer.fromJson<int?>(json['isBookmarked']),
      hasNote: serializer.fromJson<int?>(json['hasNote']),
      editAt: serializer.fromJson<String>(json['editAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'myWordId': serializer.toJson<int>(myWordId),
      'isLearned': serializer.toJson<int?>(isLearned),
      'isBookmarked': serializer.toJson<int?>(isBookmarked),
      'hasNote': serializer.toJson<int?>(hasNote),
      'editAt': serializer.toJson<String>(editAt),
    };
  }

  MyWordStatusData copyWith(
          {int? myWordId,
          Value<int?> isLearned = const Value.absent(),
          Value<int?> isBookmarked = const Value.absent(),
          Value<int?> hasNote = const Value.absent(),
          String? editAt}) =>
      MyWordStatusData(
        myWordId: myWordId ?? this.myWordId,
        isLearned: isLearned.present ? isLearned.value : this.isLearned,
        isBookmarked:
            isBookmarked.present ? isBookmarked.value : this.isBookmarked,
        hasNote: hasNote.present ? hasNote.value : this.hasNote,
        editAt: editAt ?? this.editAt,
      );
  MyWordStatusData copyWithCompanion(MyWordStatusCompanion data) {
    return MyWordStatusData(
      myWordId: data.myWordId.present ? data.myWordId.value : this.myWordId,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      hasNote: data.hasNote.present ? data.hasNote.value : this.hasNote,
      editAt: data.editAt.present ? data.editAt.value : this.editAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyWordStatusData(')
          ..write('myWordId: $myWordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(myWordId, isLearned, isBookmarked, hasNote, editAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyWordStatusData &&
          other.myWordId == this.myWordId &&
          other.isLearned == this.isLearned &&
          other.isBookmarked == this.isBookmarked &&
          other.hasNote == this.hasNote &&
          other.editAt == this.editAt);
}

class MyWordStatusCompanion extends UpdateCompanion<MyWordStatusData> {
  final Value<int> myWordId;
  final Value<int?> isLearned;
  final Value<int?> isBookmarked;
  final Value<int?> hasNote;
  final Value<String> editAt;
  const MyWordStatusCompanion({
    this.myWordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    this.editAt = const Value.absent(),
  });
  MyWordStatusCompanion.insert({
    this.myWordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    required String editAt,
  }) : editAt = Value(editAt);
  static Insertable<MyWordStatusData> custom({
    Expression<int>? myWordId,
    Expression<int>? isLearned,
    Expression<int>? isBookmarked,
    Expression<int>? hasNote,
    Expression<String>? editAt,
  }) {
    return RawValuesInsertable({
      if (myWordId != null) 'my_word_id': myWordId,
      if (isLearned != null) 'is_learned': isLearned,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (hasNote != null) 'has_note': hasNote,
      if (editAt != null) 'edit_at': editAt,
    });
  }

  MyWordStatusCompanion copyWith(
      {Value<int>? myWordId,
      Value<int?>? isLearned,
      Value<int?>? isBookmarked,
      Value<int?>? hasNote,
      Value<String>? editAt}) {
    return MyWordStatusCompanion(
      myWordId: myWordId ?? this.myWordId,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
      editAt: editAt ?? this.editAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (myWordId.present) {
      map['my_word_id'] = Variable<int>(myWordId.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<int>(isLearned.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<int>(isBookmarked.value);
    }
    if (hasNote.present) {
      map['has_note'] = Variable<int>(hasNote.value);
    }
    if (editAt.present) {
      map['edit_at'] = Variable<String>(editAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyWordStatusCompanion(')
          ..write('myWordId: $myWordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }
}

class $JpnEspWordsTable extends JpnEspWords
    with TableInfo<$JpnEspWordsTable, JpnEspWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JpnEspWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'jpn_esp_word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [wordId, word];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jpn_esp_words';
  @override
  VerificationContext validateIntegrity(Insertable<JpnEspWord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jpn_esp_word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['jpn_esp_word_id']!, _wordIdMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  JpnEspWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JpnEspWord(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}jpn_esp_word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
    );
  }

  @override
  $JpnEspWordsTable createAlias(String alias) {
    return $JpnEspWordsTable(attachedDatabase, alias);
  }
}

class JpnEspWord extends DataClass implements Insertable<JpnEspWord> {
  final int wordId;
  final String word;
  const JpnEspWord({required this.wordId, required this.word});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jpn_esp_word_id'] = Variable<int>(wordId);
    map['word'] = Variable<String>(word);
    return map;
  }

  JpnEspWordsCompanion toCompanion(bool nullToAbsent) {
    return JpnEspWordsCompanion(
      wordId: Value(wordId),
      word: Value(word),
    );
  }

  factory JpnEspWord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JpnEspWord(
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String>(word),
    };
  }

  JpnEspWord copyWith({int? wordId, String? word}) => JpnEspWord(
        wordId: wordId ?? this.wordId,
        word: word ?? this.word,
      );
  JpnEspWord copyWithCompanion(JpnEspWordsCompanion data) {
    return JpnEspWord(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspWord(')
          ..write('wordId: $wordId, ')
          ..write('word: $word')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, word);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JpnEspWord &&
          other.wordId == this.wordId &&
          other.word == this.word);
}

class JpnEspWordsCompanion extends UpdateCompanion<JpnEspWord> {
  final Value<int> wordId;
  final Value<String> word;
  const JpnEspWordsCompanion({
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
  });
  JpnEspWordsCompanion.insert({
    this.wordId = const Value.absent(),
    required String word,
  }) : word = Value(word);
  static Insertable<JpnEspWord> custom({
    Expression<int>? wordId,
    Expression<String>? word,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'jpn_esp_word_id': wordId,
      if (word != null) 'word': word,
    });
  }

  JpnEspWordsCompanion copyWith({Value<int>? wordId, Value<String>? word}) {
    return JpnEspWordsCompanion(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['jpn_esp_word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspWordsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('word: $word')
          ..write(')'))
        .toString();
  }
}

class $JpnEspWordStatusTable extends JpnEspWordStatus
    with TableInfo<$JpnEspWordStatusTable, JpnEspWordStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JpnEspWordStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'jpn_esp_word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isLearnedMeta =
      const VerificationMeta('isLearned');
  @override
  late final GeneratedColumn<int> isLearned = GeneratedColumn<int>(
      'is_learned', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isBookmarkedMeta =
      const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<int> isBookmarked = GeneratedColumn<int>(
      'is_bookmarked', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasNoteMeta =
      const VerificationMeta('hasNote');
  @override
  late final GeneratedColumn<int> hasNote = GeneratedColumn<int>(
      'has_note', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _editAtMeta = const VerificationMeta('editAt');
  @override
  late final GeneratedColumn<String> editAt = GeneratedColumn<String>(
      'edit_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [wordId, isLearned, isBookmarked, hasNote, editAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jpn_esp_word_status';
  @override
  VerificationContext validateIntegrity(
      Insertable<JpnEspWordStatusData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jpn_esp_word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['jpn_esp_word_id']!, _wordIdMeta));
    }
    if (data.containsKey('is_learned')) {
      context.handle(_isLearnedMeta,
          isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta));
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
          _isBookmarkedMeta,
          isBookmarked.isAcceptableOrUnknown(
              data['is_bookmarked']!, _isBookmarkedMeta));
    }
    if (data.containsKey('has_note')) {
      context.handle(_hasNoteMeta,
          hasNote.isAcceptableOrUnknown(data['has_note']!, _hasNoteMeta));
    }
    if (data.containsKey('edit_at')) {
      context.handle(_editAtMeta,
          editAt.isAcceptableOrUnknown(data['edit_at']!, _editAtMeta));
    } else if (isInserting) {
      context.missing(_editAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  JpnEspWordStatusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JpnEspWordStatusData(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}jpn_esp_word_id'])!,
      isLearned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_learned']),
      isBookmarked: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_bookmarked']),
      hasNote: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}has_note']),
      editAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edit_at'])!,
    );
  }

  @override
  $JpnEspWordStatusTable createAlias(String alias) {
    return $JpnEspWordStatusTable(attachedDatabase, alias);
  }
}

class JpnEspWordStatusData extends DataClass
    implements Insertable<JpnEspWordStatusData> {
  final int wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;
  final String editAt;
  const JpnEspWordStatusData(
      {required this.wordId,
      this.isLearned,
      this.isBookmarked,
      this.hasNote,
      required this.editAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jpn_esp_word_id'] = Variable<int>(wordId);
    if (!nullToAbsent || isLearned != null) {
      map['is_learned'] = Variable<int>(isLearned);
    }
    if (!nullToAbsent || isBookmarked != null) {
      map['is_bookmarked'] = Variable<int>(isBookmarked);
    }
    if (!nullToAbsent || hasNote != null) {
      map['has_note'] = Variable<int>(hasNote);
    }
    map['edit_at'] = Variable<String>(editAt);
    return map;
  }

  JpnEspWordStatusCompanion toCompanion(bool nullToAbsent) {
    return JpnEspWordStatusCompanion(
      wordId: Value(wordId),
      isLearned: isLearned == null && nullToAbsent
          ? const Value.absent()
          : Value(isLearned),
      isBookmarked: isBookmarked == null && nullToAbsent
          ? const Value.absent()
          : Value(isBookmarked),
      hasNote: hasNote == null && nullToAbsent
          ? const Value.absent()
          : Value(hasNote),
      editAt: Value(editAt),
    );
  }

  factory JpnEspWordStatusData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JpnEspWordStatusData(
      wordId: serializer.fromJson<int>(json['wordId']),
      isLearned: serializer.fromJson<int?>(json['isLearned']),
      isBookmarked: serializer.fromJson<int?>(json['isBookmarked']),
      hasNote: serializer.fromJson<int?>(json['hasNote']),
      editAt: serializer.fromJson<String>(json['editAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'isLearned': serializer.toJson<int?>(isLearned),
      'isBookmarked': serializer.toJson<int?>(isBookmarked),
      'hasNote': serializer.toJson<int?>(hasNote),
      'editAt': serializer.toJson<String>(editAt),
    };
  }

  JpnEspWordStatusData copyWith(
          {int? wordId,
          Value<int?> isLearned = const Value.absent(),
          Value<int?> isBookmarked = const Value.absent(),
          Value<int?> hasNote = const Value.absent(),
          String? editAt}) =>
      JpnEspWordStatusData(
        wordId: wordId ?? this.wordId,
        isLearned: isLearned.present ? isLearned.value : this.isLearned,
        isBookmarked:
            isBookmarked.present ? isBookmarked.value : this.isBookmarked,
        hasNote: hasNote.present ? hasNote.value : this.hasNote,
        editAt: editAt ?? this.editAt,
      );
  JpnEspWordStatusData copyWithCompanion(JpnEspWordStatusCompanion data) {
    return JpnEspWordStatusData(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      hasNote: data.hasNote.present ? data.hasNote.value : this.hasNote,
      editAt: data.editAt.present ? data.editAt.value : this.editAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspWordStatusData(')
          ..write('wordId: $wordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(wordId, isLearned, isBookmarked, hasNote, editAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JpnEspWordStatusData &&
          other.wordId == this.wordId &&
          other.isLearned == this.isLearned &&
          other.isBookmarked == this.isBookmarked &&
          other.hasNote == this.hasNote &&
          other.editAt == this.editAt);
}

class JpnEspWordStatusCompanion extends UpdateCompanion<JpnEspWordStatusData> {
  final Value<int> wordId;
  final Value<int?> isLearned;
  final Value<int?> isBookmarked;
  final Value<int?> hasNote;
  final Value<String> editAt;
  const JpnEspWordStatusCompanion({
    this.wordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    this.editAt = const Value.absent(),
  });
  JpnEspWordStatusCompanion.insert({
    this.wordId = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.hasNote = const Value.absent(),
    required String editAt,
  }) : editAt = Value(editAt);
  static Insertable<JpnEspWordStatusData> custom({
    Expression<int>? wordId,
    Expression<int>? isLearned,
    Expression<int>? isBookmarked,
    Expression<int>? hasNote,
    Expression<String>? editAt,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'jpn_esp_word_id': wordId,
      if (isLearned != null) 'is_learned': isLearned,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (hasNote != null) 'has_note': hasNote,
      if (editAt != null) 'edit_at': editAt,
    });
  }

  JpnEspWordStatusCompanion copyWith(
      {Value<int>? wordId,
      Value<int?>? isLearned,
      Value<int?>? isBookmarked,
      Value<int?>? hasNote,
      Value<String>? editAt}) {
    return JpnEspWordStatusCompanion(
      wordId: wordId ?? this.wordId,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
      editAt: editAt ?? this.editAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['jpn_esp_word_id'] = Variable<int>(wordId.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<int>(isLearned.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<int>(isBookmarked.value);
    }
    if (hasNote.present) {
      map['has_note'] = Variable<int>(hasNote.value);
    }
    if (editAt.present) {
      map['edit_at'] = Variable<String>(editAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspWordStatusCompanion(')
          ..write('wordId: $wordId, ')
          ..write('isLearned: $isLearned, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('hasNote: $hasNote, ')
          ..write('editAt: $editAt')
          ..write(')'))
        .toString();
  }
}

class $JpnEspDictionariesTable extends JpnEspDictionaries
    with TableInfo<$JpnEspDictionariesTable, JpnEspDictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JpnEspDictionariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'jpn_esp_dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'jpn_esp_word_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _excfMeta = const VerificationMeta('excf');
  @override
  late final GeneratedColumn<int> excf = GeneratedColumn<int>(
      'excf', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _headwordMeta =
      const VerificationMeta('headword');
  @override
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
      'headword', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _htmlRawMeta =
      const VerificationMeta('htmlRaw');
  @override
  late final GeneratedColumn<String> htmlRaw = GeneratedColumn<String>(
      'html_raw', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [dictionaryId, wordId, word, excf, headword, content, htmlRaw];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jpn_esp_dictionaries';
  @override
  VerificationContext validateIntegrity(Insertable<JpnEspDictionary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jpn_esp_dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['jpn_esp_dictionary_id']!, _dictionaryIdMeta));
    }
    if (data.containsKey('jpn_esp_word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['jpn_esp_word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('excf')) {
      context.handle(
          _excfMeta, excf.isAcceptableOrUnknown(data['excf']!, _excfMeta));
    } else if (isInserting) {
      context.missing(_excfMeta);
    }
    if (data.containsKey('headword')) {
      context.handle(_headwordMeta,
          headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta));
    } else if (isInserting) {
      context.missing(_headwordMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('html_raw')) {
      context.handle(_htmlRawMeta,
          htmlRaw.isAcceptableOrUnknown(data['html_raw']!, _htmlRawMeta));
    } else if (isInserting) {
      context.missing(_htmlRawMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dictionaryId};
  @override
  JpnEspDictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JpnEspDictionary(
      dictionaryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}jpn_esp_dictionary_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}jpn_esp_word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      excf: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}excf'])!,
      headword: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headword'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      htmlRaw: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html_raw'])!,
    );
  }

  @override
  $JpnEspDictionariesTable createAlias(String alias) {
    return $JpnEspDictionariesTable(attachedDatabase, alias);
  }
}

class JpnEspDictionary extends DataClass
    implements Insertable<JpnEspDictionary> {
  final int dictionaryId;
  final int wordId;
  final String word;
  final int excf;
  final String headword;
  final String content;
  final String htmlRaw;
  const JpnEspDictionary(
      {required this.dictionaryId,
      required this.wordId,
      required this.word,
      required this.excf,
      required this.headword,
      required this.content,
      required this.htmlRaw});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jpn_esp_dictionary_id'] = Variable<int>(dictionaryId);
    map['jpn_esp_word_id'] = Variable<int>(wordId);
    map['word'] = Variable<String>(word);
    map['excf'] = Variable<int>(excf);
    map['headword'] = Variable<String>(headword);
    map['content'] = Variable<String>(content);
    map['html_raw'] = Variable<String>(htmlRaw);
    return map;
  }

  JpnEspDictionariesCompanion toCompanion(bool nullToAbsent) {
    return JpnEspDictionariesCompanion(
      dictionaryId: Value(dictionaryId),
      wordId: Value(wordId),
      word: Value(word),
      excf: Value(excf),
      headword: Value(headword),
      content: Value(content),
      htmlRaw: Value(htmlRaw),
    );
  }

  factory JpnEspDictionary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JpnEspDictionary(
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String>(json['word']),
      excf: serializer.fromJson<int>(json['excf']),
      headword: serializer.fromJson<String>(json['headword']),
      content: serializer.fromJson<String>(json['content']),
      htmlRaw: serializer.fromJson<String>(json['htmlRaw']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String>(word),
      'excf': serializer.toJson<int>(excf),
      'headword': serializer.toJson<String>(headword),
      'content': serializer.toJson<String>(content),
      'htmlRaw': serializer.toJson<String>(htmlRaw),
    };
  }

  JpnEspDictionary copyWith(
          {int? dictionaryId,
          int? wordId,
          String? word,
          int? excf,
          String? headword,
          String? content,
          String? htmlRaw}) =>
      JpnEspDictionary(
        dictionaryId: dictionaryId ?? this.dictionaryId,
        wordId: wordId ?? this.wordId,
        word: word ?? this.word,
        excf: excf ?? this.excf,
        headword: headword ?? this.headword,
        content: content ?? this.content,
        htmlRaw: htmlRaw ?? this.htmlRaw,
      );
  JpnEspDictionary copyWithCompanion(JpnEspDictionariesCompanion data) {
    return JpnEspDictionary(
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      excf: data.excf.present ? data.excf.value : this.excf,
      headword: data.headword.present ? data.headword.value : this.headword,
      content: data.content.present ? data.content.value : this.content,
      htmlRaw: data.htmlRaw.present ? data.htmlRaw.value : this.htmlRaw,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspDictionary(')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('excf: $excf, ')
          ..write('headword: $headword, ')
          ..write('content: $content, ')
          ..write('htmlRaw: $htmlRaw')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dictionaryId, wordId, word, excf, headword, content, htmlRaw);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JpnEspDictionary &&
          other.dictionaryId == this.dictionaryId &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.excf == this.excf &&
          other.headword == this.headword &&
          other.content == this.content &&
          other.htmlRaw == this.htmlRaw);
}

class JpnEspDictionariesCompanion extends UpdateCompanion<JpnEspDictionary> {
  final Value<int> dictionaryId;
  final Value<int> wordId;
  final Value<String> word;
  final Value<int> excf;
  final Value<String> headword;
  final Value<String> content;
  final Value<String> htmlRaw;
  const JpnEspDictionariesCompanion({
    this.dictionaryId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.excf = const Value.absent(),
    this.headword = const Value.absent(),
    this.content = const Value.absent(),
    this.htmlRaw = const Value.absent(),
  });
  JpnEspDictionariesCompanion.insert({
    this.dictionaryId = const Value.absent(),
    required int wordId,
    required String word,
    required int excf,
    required String headword,
    required String content,
    required String htmlRaw,
  })  : wordId = Value(wordId),
        word = Value(word),
        excf = Value(excf),
        headword = Value(headword),
        content = Value(content),
        htmlRaw = Value(htmlRaw);
  static Insertable<JpnEspDictionary> custom({
    Expression<int>? dictionaryId,
    Expression<int>? wordId,
    Expression<String>? word,
    Expression<int>? excf,
    Expression<String>? headword,
    Expression<String>? content,
    Expression<String>? htmlRaw,
  }) {
    return RawValuesInsertable({
      if (dictionaryId != null) 'jpn_esp_dictionary_id': dictionaryId,
      if (wordId != null) 'jpn_esp_word_id': wordId,
      if (word != null) 'word': word,
      if (excf != null) 'excf': excf,
      if (headword != null) 'headword': headword,
      if (content != null) 'content': content,
      if (htmlRaw != null) 'html_raw': htmlRaw,
    });
  }

  JpnEspDictionariesCompanion copyWith(
      {Value<int>? dictionaryId,
      Value<int>? wordId,
      Value<String>? word,
      Value<int>? excf,
      Value<String>? headword,
      Value<String>? content,
      Value<String>? htmlRaw}) {
    return JpnEspDictionariesCompanion(
      dictionaryId: dictionaryId ?? this.dictionaryId,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      excf: excf ?? this.excf,
      headword: headword ?? this.headword,
      content: content ?? this.content,
      htmlRaw: htmlRaw ?? this.htmlRaw,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dictionaryId.present) {
      map['jpn_esp_dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (wordId.present) {
      map['jpn_esp_word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (excf.present) {
      map['excf'] = Variable<int>(excf.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (htmlRaw.present) {
      map['html_raw'] = Variable<String>(htmlRaw.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspDictionariesCompanion(')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('excf: $excf, ')
          ..write('headword: $headword, ')
          ..write('content: $content, ')
          ..write('htmlRaw: $htmlRaw')
          ..write(')'))
        .toString();
  }
}

class $JpnEspExamplesTable extends JpnEspExamples
    with TableInfo<$JpnEspExamplesTable, JpnEspExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JpnEspExamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exampleIdMeta =
      const VerificationMeta('exampleId');
  @override
  late final GeneratedColumn<int> exampleId = GeneratedColumn<int>(
      'jpn_esp_example_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'jpn_esp_dictionary_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exampleNoMeta =
      const VerificationMeta('exampleNo');
  @override
  late final GeneratedColumn<int> exampleNo = GeneratedColumn<int>(
      'example_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _japaneseTextMeta =
      const VerificationMeta('japaneseText');
  @override
  late final GeneratedColumn<String> japaneseText = GeneratedColumn<String>(
      'japanese_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _espanolHtmlMeta =
      const VerificationMeta('espanolHtml');
  @override
  late final GeneratedColumn<String> espanolHtml = GeneratedColumn<String>(
      'espanol_html', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _espanolTextMeta =
      const VerificationMeta('espanolText');
  @override
  late final GeneratedColumn<String> espanolText = GeneratedColumn<String>(
      'espanol_txt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        exampleId,
        dictionaryId,
        exampleNo,
        japaneseText,
        espanolHtml,
        espanolText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jpn_esp_examples';
  @override
  VerificationContext validateIntegrity(Insertable<JpnEspExample> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jpn_esp_example_id')) {
      context.handle(
          _exampleIdMeta,
          exampleId.isAcceptableOrUnknown(
              data['jpn_esp_example_id']!, _exampleIdMeta));
    }
    if (data.containsKey('jpn_esp_dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['jpn_esp_dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('example_no')) {
      context.handle(_exampleNoMeta,
          exampleNo.isAcceptableOrUnknown(data['example_no']!, _exampleNoMeta));
    } else if (isInserting) {
      context.missing(_exampleNoMeta);
    }
    if (data.containsKey('japanese_text')) {
      context.handle(
          _japaneseTextMeta,
          japaneseText.isAcceptableOrUnknown(
              data['japanese_text']!, _japaneseTextMeta));
    } else if (isInserting) {
      context.missing(_japaneseTextMeta);
    }
    if (data.containsKey('espanol_html')) {
      context.handle(
          _espanolHtmlMeta,
          espanolHtml.isAcceptableOrUnknown(
              data['espanol_html']!, _espanolHtmlMeta));
    } else if (isInserting) {
      context.missing(_espanolHtmlMeta);
    }
    if (data.containsKey('espanol_txt')) {
      context.handle(
          _espanolTextMeta,
          espanolText.isAcceptableOrUnknown(
              data['espanol_txt']!, _espanolTextMeta));
    } else if (isInserting) {
      context.missing(_espanolTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exampleId};
  @override
  JpnEspExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JpnEspExample(
      exampleId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}jpn_esp_example_id'])!,
      dictionaryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}jpn_esp_dictionary_id'])!,
      exampleNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}example_no'])!,
      japaneseText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}japanese_text'])!,
      espanolHtml: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}espanol_html'])!,
      espanolText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}espanol_txt'])!,
    );
  }

  @override
  $JpnEspExamplesTable createAlias(String alias) {
    return $JpnEspExamplesTable(attachedDatabase, alias);
  }
}

class JpnEspExample extends DataClass implements Insertable<JpnEspExample> {
  final int exampleId;
  final int dictionaryId;
  final int exampleNo;
  final String japaneseText;
  final String espanolHtml;
  final String espanolText;
  const JpnEspExample(
      {required this.exampleId,
      required this.dictionaryId,
      required this.exampleNo,
      required this.japaneseText,
      required this.espanolHtml,
      required this.espanolText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jpn_esp_example_id'] = Variable<int>(exampleId);
    map['jpn_esp_dictionary_id'] = Variable<int>(dictionaryId);
    map['example_no'] = Variable<int>(exampleNo);
    map['japanese_text'] = Variable<String>(japaneseText);
    map['espanol_html'] = Variable<String>(espanolHtml);
    map['espanol_txt'] = Variable<String>(espanolText);
    return map;
  }

  JpnEspExamplesCompanion toCompanion(bool nullToAbsent) {
    return JpnEspExamplesCompanion(
      exampleId: Value(exampleId),
      dictionaryId: Value(dictionaryId),
      exampleNo: Value(exampleNo),
      japaneseText: Value(japaneseText),
      espanolHtml: Value(espanolHtml),
      espanolText: Value(espanolText),
    );
  }

  factory JpnEspExample.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JpnEspExample(
      exampleId: serializer.fromJson<int>(json['exampleId']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      exampleNo: serializer.fromJson<int>(json['exampleNo']),
      japaneseText: serializer.fromJson<String>(json['japaneseText']),
      espanolHtml: serializer.fromJson<String>(json['espanolHtml']),
      espanolText: serializer.fromJson<String>(json['espanolText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exampleId': serializer.toJson<int>(exampleId),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'exampleNo': serializer.toJson<int>(exampleNo),
      'japaneseText': serializer.toJson<String>(japaneseText),
      'espanolHtml': serializer.toJson<String>(espanolHtml),
      'espanolText': serializer.toJson<String>(espanolText),
    };
  }

  JpnEspExample copyWith(
          {int? exampleId,
          int? dictionaryId,
          int? exampleNo,
          String? japaneseText,
          String? espanolHtml,
          String? espanolText}) =>
      JpnEspExample(
        exampleId: exampleId ?? this.exampleId,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        exampleNo: exampleNo ?? this.exampleNo,
        japaneseText: japaneseText ?? this.japaneseText,
        espanolHtml: espanolHtml ?? this.espanolHtml,
        espanolText: espanolText ?? this.espanolText,
      );
  JpnEspExample copyWithCompanion(JpnEspExamplesCompanion data) {
    return JpnEspExample(
      exampleId: data.exampleId.present ? data.exampleId.value : this.exampleId,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      exampleNo: data.exampleNo.present ? data.exampleNo.value : this.exampleNo,
      japaneseText: data.japaneseText.present
          ? data.japaneseText.value
          : this.japaneseText,
      espanolHtml:
          data.espanolHtml.present ? data.espanolHtml.value : this.espanolHtml,
      espanolText:
          data.espanolText.present ? data.espanolText.value : this.espanolText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspExample(')
          ..write('exampleId: $exampleId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('exampleNo: $exampleNo, ')
          ..write('japaneseText: $japaneseText, ')
          ..write('espanolHtml: $espanolHtml, ')
          ..write('espanolText: $espanolText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exampleId, dictionaryId, exampleNo,
      japaneseText, espanolHtml, espanolText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JpnEspExample &&
          other.exampleId == this.exampleId &&
          other.dictionaryId == this.dictionaryId &&
          other.exampleNo == this.exampleNo &&
          other.japaneseText == this.japaneseText &&
          other.espanolHtml == this.espanolHtml &&
          other.espanolText == this.espanolText);
}

class JpnEspExamplesCompanion extends UpdateCompanion<JpnEspExample> {
  final Value<int> exampleId;
  final Value<int> dictionaryId;
  final Value<int> exampleNo;
  final Value<String> japaneseText;
  final Value<String> espanolHtml;
  final Value<String> espanolText;
  const JpnEspExamplesCompanion({
    this.exampleId = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.exampleNo = const Value.absent(),
    this.japaneseText = const Value.absent(),
    this.espanolHtml = const Value.absent(),
    this.espanolText = const Value.absent(),
  });
  JpnEspExamplesCompanion.insert({
    this.exampleId = const Value.absent(),
    required int dictionaryId,
    required int exampleNo,
    required String japaneseText,
    required String espanolHtml,
    required String espanolText,
  })  : dictionaryId = Value(dictionaryId),
        exampleNo = Value(exampleNo),
        japaneseText = Value(japaneseText),
        espanolHtml = Value(espanolHtml),
        espanolText = Value(espanolText);
  static Insertable<JpnEspExample> custom({
    Expression<int>? exampleId,
    Expression<int>? dictionaryId,
    Expression<int>? exampleNo,
    Expression<String>? japaneseText,
    Expression<String>? espanolHtml,
    Expression<String>? espanolText,
  }) {
    return RawValuesInsertable({
      if (exampleId != null) 'jpn_esp_example_id': exampleId,
      if (dictionaryId != null) 'jpn_esp_dictionary_id': dictionaryId,
      if (exampleNo != null) 'example_no': exampleNo,
      if (japaneseText != null) 'japanese_text': japaneseText,
      if (espanolHtml != null) 'espanol_html': espanolHtml,
      if (espanolText != null) 'espanol_txt': espanolText,
    });
  }

  JpnEspExamplesCompanion copyWith(
      {Value<int>? exampleId,
      Value<int>? dictionaryId,
      Value<int>? exampleNo,
      Value<String>? japaneseText,
      Value<String>? espanolHtml,
      Value<String>? espanolText}) {
    return JpnEspExamplesCompanion(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      exampleNo: exampleNo ?? this.exampleNo,
      japaneseText: japaneseText ?? this.japaneseText,
      espanolHtml: espanolHtml ?? this.espanolHtml,
      espanolText: espanolText ?? this.espanolText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exampleId.present) {
      map['jpn_esp_example_id'] = Variable<int>(exampleId.value);
    }
    if (dictionaryId.present) {
      map['jpn_esp_dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (exampleNo.present) {
      map['example_no'] = Variable<int>(exampleNo.value);
    }
    if (japaneseText.present) {
      map['japanese_text'] = Variable<String>(japaneseText.value);
    }
    if (espanolHtml.present) {
      map['espanol_html'] = Variable<String>(espanolHtml.value);
    }
    if (espanolText.present) {
      map['espanol_txt'] = Variable<String>(espanolText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JpnEspExamplesCompanion(')
          ..write('exampleId: $exampleId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('exampleNo: $exampleNo, ')
          ..write('japaneseText: $japaneseText, ')
          ..write('espanolHtml: $espanolHtml, ')
          ..write('espanolText: $espanolText')
          ..write(')'))
        .toString();
  }
}

class $EsEnConjugacionsTable extends EsEnConjugacions
    with TableInfo<$EsEnConjugacionsTable, EsEnConjugacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EsEnConjugacionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _englishMeta =
      const VerificationMeta('english');
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
      'english', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _present3rdMeta =
      const VerificationMeta('present3rd');
  @override
  late final GeneratedColumn<String> present3rd = GeneratedColumn<String>(
      'present_3rd', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _presentPMeta =
      const VerificationMeta('presentP');
  @override
  late final GeneratedColumn<String> presentP = GeneratedColumn<String>(
      'present_p', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pastMeta = const VerificationMeta('past');
  @override
  late final GeneratedColumn<String> past = GeneratedColumn<String>(
      'past', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pastPMeta = const VerificationMeta('pastP');
  @override
  late final GeneratedColumn<String> pastP = GeneratedColumn<String>(
      'past_p', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [wordId, word, english, present3rd, presentP, past, pastP];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'es_en_conjugacions';
  @override
  VerificationContext validateIntegrity(Insertable<EsEnConjugacion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    }
    if (data.containsKey('english')) {
      context.handle(_englishMeta,
          english.isAcceptableOrUnknown(data['english']!, _englishMeta));
    }
    if (data.containsKey('present_3rd')) {
      context.handle(
          _present3rdMeta,
          present3rd.isAcceptableOrUnknown(
              data['present_3rd']!, _present3rdMeta));
    }
    if (data.containsKey('present_p')) {
      context.handle(_presentPMeta,
          presentP.isAcceptableOrUnknown(data['present_p']!, _presentPMeta));
    }
    if (data.containsKey('past')) {
      context.handle(
          _pastMeta, past.isAcceptableOrUnknown(data['past']!, _pastMeta));
    }
    if (data.containsKey('past_p')) {
      context.handle(
          _pastPMeta, pastP.isAcceptableOrUnknown(data['past_p']!, _pastPMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId};
  @override
  EsEnConjugacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EsEnConjugacion(
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word']),
      english: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}english']),
      present3rd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}present_3rd']),
      presentP: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}present_p']),
      past: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}past']),
      pastP: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}past_p']),
    );
  }

  @override
  $EsEnConjugacionsTable createAlias(String alias) {
    return $EsEnConjugacionsTable(attachedDatabase, alias);
  }
}

class EsEnConjugacion extends DataClass implements Insertable<EsEnConjugacion> {
  final int wordId;
  final String? word;
  final String? english;
  final String? present3rd;
  final String? presentP;
  final String? past;
  final String? pastP;
  const EsEnConjugacion(
      {required this.wordId,
      this.word,
      this.english,
      this.present3rd,
      this.presentP,
      this.past,
      this.pastP});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    if (!nullToAbsent || word != null) {
      map['word'] = Variable<String>(word);
    }
    if (!nullToAbsent || english != null) {
      map['english'] = Variable<String>(english);
    }
    if (!nullToAbsent || present3rd != null) {
      map['present_3rd'] = Variable<String>(present3rd);
    }
    if (!nullToAbsent || presentP != null) {
      map['present_p'] = Variable<String>(presentP);
    }
    if (!nullToAbsent || past != null) {
      map['past'] = Variable<String>(past);
    }
    if (!nullToAbsent || pastP != null) {
      map['past_p'] = Variable<String>(pastP);
    }
    return map;
  }

  EsEnConjugacionsCompanion toCompanion(bool nullToAbsent) {
    return EsEnConjugacionsCompanion(
      wordId: Value(wordId),
      word: word == null && nullToAbsent ? const Value.absent() : Value(word),
      english: english == null && nullToAbsent
          ? const Value.absent()
          : Value(english),
      present3rd: present3rd == null && nullToAbsent
          ? const Value.absent()
          : Value(present3rd),
      presentP: presentP == null && nullToAbsent
          ? const Value.absent()
          : Value(presentP),
      past: past == null && nullToAbsent ? const Value.absent() : Value(past),
      pastP:
          pastP == null && nullToAbsent ? const Value.absent() : Value(pastP),
    );
  }

  factory EsEnConjugacion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EsEnConjugacion(
      wordId: serializer.fromJson<int>(json['wordId']),
      word: serializer.fromJson<String?>(json['word']),
      english: serializer.fromJson<String?>(json['english']),
      present3rd: serializer.fromJson<String?>(json['present3rd']),
      presentP: serializer.fromJson<String?>(json['presentP']),
      past: serializer.fromJson<String?>(json['past']),
      pastP: serializer.fromJson<String?>(json['pastP']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'word': serializer.toJson<String?>(word),
      'english': serializer.toJson<String?>(english),
      'present3rd': serializer.toJson<String?>(present3rd),
      'presentP': serializer.toJson<String?>(presentP),
      'past': serializer.toJson<String?>(past),
      'pastP': serializer.toJson<String?>(pastP),
    };
  }

  EsEnConjugacion copyWith(
          {int? wordId,
          Value<String?> word = const Value.absent(),
          Value<String?> english = const Value.absent(),
          Value<String?> present3rd = const Value.absent(),
          Value<String?> presentP = const Value.absent(),
          Value<String?> past = const Value.absent(),
          Value<String?> pastP = const Value.absent()}) =>
      EsEnConjugacion(
        wordId: wordId ?? this.wordId,
        word: word.present ? word.value : this.word,
        english: english.present ? english.value : this.english,
        present3rd: present3rd.present ? present3rd.value : this.present3rd,
        presentP: presentP.present ? presentP.value : this.presentP,
        past: past.present ? past.value : this.past,
        pastP: pastP.present ? pastP.value : this.pastP,
      );
  EsEnConjugacion copyWithCompanion(EsEnConjugacionsCompanion data) {
    return EsEnConjugacion(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      word: data.word.present ? data.word.value : this.word,
      english: data.english.present ? data.english.value : this.english,
      present3rd:
          data.present3rd.present ? data.present3rd.value : this.present3rd,
      presentP: data.presentP.present ? data.presentP.value : this.presentP,
      past: data.past.present ? data.past.value : this.past,
      pastP: data.pastP.present ? data.pastP.value : this.pastP,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EsEnConjugacion(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('english: $english, ')
          ..write('present3rd: $present3rd, ')
          ..write('presentP: $presentP, ')
          ..write('past: $past, ')
          ..write('pastP: $pastP')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(wordId, word, english, present3rd, presentP, past, pastP);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EsEnConjugacion &&
          other.wordId == this.wordId &&
          other.word == this.word &&
          other.english == this.english &&
          other.present3rd == this.present3rd &&
          other.presentP == this.presentP &&
          other.past == this.past &&
          other.pastP == this.pastP);
}

class EsEnConjugacionsCompanion extends UpdateCompanion<EsEnConjugacion> {
  final Value<int> wordId;
  final Value<String?> word;
  final Value<String?> english;
  final Value<String?> present3rd;
  final Value<String?> presentP;
  final Value<String?> past;
  final Value<String?> pastP;
  const EsEnConjugacionsCompanion({
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.english = const Value.absent(),
    this.present3rd = const Value.absent(),
    this.presentP = const Value.absent(),
    this.past = const Value.absent(),
    this.pastP = const Value.absent(),
  });
  EsEnConjugacionsCompanion.insert({
    this.wordId = const Value.absent(),
    this.word = const Value.absent(),
    this.english = const Value.absent(),
    this.present3rd = const Value.absent(),
    this.presentP = const Value.absent(),
    this.past = const Value.absent(),
    this.pastP = const Value.absent(),
  });
  static Insertable<EsEnConjugacion> custom({
    Expression<int>? wordId,
    Expression<String>? word,
    Expression<String>? english,
    Expression<String>? present3rd,
    Expression<String>? presentP,
    Expression<String>? past,
    Expression<String>? pastP,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (word != null) 'word': word,
      if (english != null) 'english': english,
      if (present3rd != null) 'present_3rd': present3rd,
      if (presentP != null) 'present_p': presentP,
      if (past != null) 'past': past,
      if (pastP != null) 'past_p': pastP,
    });
  }

  EsEnConjugacionsCompanion copyWith(
      {Value<int>? wordId,
      Value<String?>? word,
      Value<String?>? english,
      Value<String?>? present3rd,
      Value<String?>? presentP,
      Value<String?>? past,
      Value<String?>? pastP}) {
    return EsEnConjugacionsCompanion(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      english: english ?? this.english,
      present3rd: present3rd ?? this.present3rd,
      presentP: presentP ?? this.presentP,
      past: past ?? this.past,
      pastP: pastP ?? this.pastP,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (present3rd.present) {
      map['present_3rd'] = Variable<String>(present3rd.value);
    }
    if (presentP.present) {
      map['present_p'] = Variable<String>(presentP.value);
    }
    if (past.present) {
      map['past'] = Variable<String>(past.value);
    }
    if (pastP.present) {
      map['past_p'] = Variable<String>(pastP.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EsEnConjugacionsCompanion(')
          ..write('wordId: $wordId, ')
          ..write('word: $word, ')
          ..write('english: $english, ')
          ..write('present3rd: $present3rd, ')
          ..write('presentP: $presentP, ')
          ..write('past: $past, ')
          ..write('pastP: $pastP')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseProvider extends GeneratedDatabase {
  _$DatabaseProvider(QueryExecutor e) : super(e);
  $DatabaseProviderManager get managers => $DatabaseProviderManager(this);
  late final $ConjugationsTable conjugations = $ConjugationsTable(this);
  late final $DictionariesTable dictionaries = $DictionariesTable(this);
  late final $ExamplesTable examples = $ExamplesTable(this);
  late final $IdiomsTable idioms = $IdiomsTable(this);
  late final $PartOfSpeechListsTable partOfSpeechLists =
      $PartOfSpeechListsTable(this);
  late final $RankingsTable rankings = $RankingsTable(this);
  late final $SupplementsTable supplements = $SupplementsTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordStatusTable wordStatus = $WordStatusTable(this);
  late final $MyWordsTable myWords = $MyWordsTable(this);
  late final $MyWordStatusTable myWordStatus = $MyWordStatusTable(this);
  late final $JpnEspWordsTable jpnEspWords = $JpnEspWordsTable(this);
  late final $JpnEspWordStatusTable jpnEspWordStatus =
      $JpnEspWordStatusTable(this);
  late final $JpnEspDictionariesTable jpnEspDictionaries =
      $JpnEspDictionariesTable(this);
  late final $JpnEspExamplesTable jpnEspExamples = $JpnEspExamplesTable(this);
  late final $EsEnConjugacionsTable esEnConjugacions =
      $EsEnConjugacionsTable(this);
  late final WordDao wordDao = WordDao(this as DatabaseProvider);
  late final RankingDao rankingDao = RankingDao(this as DatabaseProvider);
  late final PartOfSpeechListDao partOfSpeechListDao =
      PartOfSpeechListDao(this as DatabaseProvider);
  late final MyWordDao myWordDao = MyWordDao(this as DatabaseProvider);
  late final JpnEspWordDao jpnEspWordDao =
      JpnEspWordDao(this as DatabaseProvider);
  late final EsEnConjugacionDao esEnConjugacionDao =
      EsEnConjugacionDao(this as DatabaseProvider);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        conjugations,
        dictionaries,
        examples,
        idioms,
        partOfSpeechLists,
        rankings,
        supplements,
        words,
        wordStatus,
        myWords,
        myWordStatus,
        jpnEspWords,
        jpnEspWordStatus,
        jpnEspDictionaries,
        jpnEspExamples,
        esEnConjugacions
      ];
}

typedef $$ConjugationsTableCreateCompanionBuilder = ConjugationsCompanion
    Function({
  Value<int> wordId,
  required String word,
  Value<String?> meaning,
  Value<String?> presentParticiple,
  Value<String?> prastParticiple,
  Value<String?> indicativePresentYo,
  Value<String?> indicativePresentTu,
  Value<String?> indicativePresentEl,
  Value<String?> indicativePresentNosotros,
  Value<String?> indicativePresentVosotros,
  Value<String?> indicativePresentEllos,
  Value<String?> indicativePreteriteYo,
  Value<String?> indicativePreteriteTu,
  Value<String?> indicativePreteriteEl,
  Value<String?> indicativePreteriteNosotros,
  Value<String?> indicativePreteriteVosotros,
  Value<String?> indicativePreteriteEllos,
  Value<String?> indicativeImperfectYo,
  Value<String?> indicativeImperfectTu,
  Value<String?> indicativeImperfectEl,
  Value<String?> indicativeImperfectNosotros,
  Value<String?> indicativeImperfectVosotros,
  Value<String?> indicativeImperfectEllos,
  Value<String?> indicativeFutureYo,
  Value<String?> indicativeFutureTu,
  Value<String?> indicativeFutureEl,
  Value<String?> indicativeFutureNosotros,
  Value<String?> indicativeFutureVosotros,
  Value<String?> indicativeFutureEllos,
  Value<String?> indicativeConditionalYo,
  Value<String?> indicativeConditionalTu,
  Value<String?> indicativeConditionalEl,
  Value<String?> indicativeConditionalNosotros,
  Value<String?> indicativeConditionalVosotros,
  Value<String?> indicativeConditionalEllos,
  Value<String?> imperativeTu,
  Value<String?> imperativeEl,
  Value<String?> imperativeNosotros,
  Value<String?> imperativeVosotros,
  Value<String?> imperativeEllos,
  Value<String?> subjunctivePresentYo,
  Value<String?> subjunctivePresentTu,
  Value<String?> subjunctivePresentEl,
  Value<String?> subjunctivePresentNosotros,
  Value<String?> subjunctivePresentVosotros,
  Value<String?> subjunctivePresentEllos,
  Value<String?> subjunctivePastYo,
  Value<String?> subjunctivePastTu,
  Value<String?> subjunctivePastEl,
  Value<String?> subjunctivePastNosotros,
  Value<String?> subjunctivePastVosotros,
  Value<String?> subjunctivePastEllos,
});
typedef $$ConjugationsTableUpdateCompanionBuilder = ConjugationsCompanion
    Function({
  Value<int> wordId,
  Value<String> word,
  Value<String?> meaning,
  Value<String?> presentParticiple,
  Value<String?> prastParticiple,
  Value<String?> indicativePresentYo,
  Value<String?> indicativePresentTu,
  Value<String?> indicativePresentEl,
  Value<String?> indicativePresentNosotros,
  Value<String?> indicativePresentVosotros,
  Value<String?> indicativePresentEllos,
  Value<String?> indicativePreteriteYo,
  Value<String?> indicativePreteriteTu,
  Value<String?> indicativePreteriteEl,
  Value<String?> indicativePreteriteNosotros,
  Value<String?> indicativePreteriteVosotros,
  Value<String?> indicativePreteriteEllos,
  Value<String?> indicativeImperfectYo,
  Value<String?> indicativeImperfectTu,
  Value<String?> indicativeImperfectEl,
  Value<String?> indicativeImperfectNosotros,
  Value<String?> indicativeImperfectVosotros,
  Value<String?> indicativeImperfectEllos,
  Value<String?> indicativeFutureYo,
  Value<String?> indicativeFutureTu,
  Value<String?> indicativeFutureEl,
  Value<String?> indicativeFutureNosotros,
  Value<String?> indicativeFutureVosotros,
  Value<String?> indicativeFutureEllos,
  Value<String?> indicativeConditionalYo,
  Value<String?> indicativeConditionalTu,
  Value<String?> indicativeConditionalEl,
  Value<String?> indicativeConditionalNosotros,
  Value<String?> indicativeConditionalVosotros,
  Value<String?> indicativeConditionalEllos,
  Value<String?> imperativeTu,
  Value<String?> imperativeEl,
  Value<String?> imperativeNosotros,
  Value<String?> imperativeVosotros,
  Value<String?> imperativeEllos,
  Value<String?> subjunctivePresentYo,
  Value<String?> subjunctivePresentTu,
  Value<String?> subjunctivePresentEl,
  Value<String?> subjunctivePresentNosotros,
  Value<String?> subjunctivePresentVosotros,
  Value<String?> subjunctivePresentEllos,
  Value<String?> subjunctivePastYo,
  Value<String?> subjunctivePastTu,
  Value<String?> subjunctivePastEl,
  Value<String?> subjunctivePastNosotros,
  Value<String?> subjunctivePastVosotros,
  Value<String?> subjunctivePastEllos,
});

class $$ConjugationsTableFilterComposer
    extends Composer<_$DatabaseProvider, $ConjugationsTable> {
  $$ConjugationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get presentParticiple => $composableBuilder(
      column: $table.presentParticiple,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prastParticiple => $composableBuilder(
      column: $table.prastParticiple,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentYo => $composableBuilder(
      column: $table.indicativePresentYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentTu => $composableBuilder(
      column: $table.indicativePresentTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentEl => $composableBuilder(
      column: $table.indicativePresentEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentNosotros => $composableBuilder(
      column: $table.indicativePresentNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentVosotros => $composableBuilder(
      column: $table.indicativePresentVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePresentEllos => $composableBuilder(
      column: $table.indicativePresentEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteYo => $composableBuilder(
      column: $table.indicativePreteriteYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteTu => $composableBuilder(
      column: $table.indicativePreteriteTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteEl => $composableBuilder(
      column: $table.indicativePreteriteEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteNosotros => $composableBuilder(
      column: $table.indicativePreteriteNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteVosotros => $composableBuilder(
      column: $table.indicativePreteriteVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativePreteriteEllos => $composableBuilder(
      column: $table.indicativePreteriteEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectYo => $composableBuilder(
      column: $table.indicativeImperfectYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectTu => $composableBuilder(
      column: $table.indicativeImperfectTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectEl => $composableBuilder(
      column: $table.indicativeImperfectEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectNosotros => $composableBuilder(
      column: $table.indicativeImperfectNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectVosotros => $composableBuilder(
      column: $table.indicativeImperfectVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeImperfectEllos => $composableBuilder(
      column: $table.indicativeImperfectEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureYo => $composableBuilder(
      column: $table.indicativeFutureYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureTu => $composableBuilder(
      column: $table.indicativeFutureTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureEl => $composableBuilder(
      column: $table.indicativeFutureEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureNosotros => $composableBuilder(
      column: $table.indicativeFutureNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureVosotros => $composableBuilder(
      column: $table.indicativeFutureVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeFutureEllos => $composableBuilder(
      column: $table.indicativeFutureEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalYo => $composableBuilder(
      column: $table.indicativeConditionalYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalTu => $composableBuilder(
      column: $table.indicativeConditionalTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalEl => $composableBuilder(
      column: $table.indicativeConditionalEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalNosotros => $composableBuilder(
      column: $table.indicativeConditionalNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalVosotros => $composableBuilder(
      column: $table.indicativeConditionalVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get indicativeConditionalEllos => $composableBuilder(
      column: $table.indicativeConditionalEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imperativeTu => $composableBuilder(
      column: $table.imperativeTu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imperativeEl => $composableBuilder(
      column: $table.imperativeEl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imperativeNosotros => $composableBuilder(
      column: $table.imperativeNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imperativeVosotros => $composableBuilder(
      column: $table.imperativeVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imperativeEllos => $composableBuilder(
      column: $table.imperativeEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentYo => $composableBuilder(
      column: $table.subjunctivePresentYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentTu => $composableBuilder(
      column: $table.subjunctivePresentTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentEl => $composableBuilder(
      column: $table.subjunctivePresentEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentNosotros => $composableBuilder(
      column: $table.subjunctivePresentNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentVosotros => $composableBuilder(
      column: $table.subjunctivePresentVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePresentEllos => $composableBuilder(
      column: $table.subjunctivePresentEllos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastYo => $composableBuilder(
      column: $table.subjunctivePastYo,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastTu => $composableBuilder(
      column: $table.subjunctivePastTu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastEl => $composableBuilder(
      column: $table.subjunctivePastEl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastNosotros => $composableBuilder(
      column: $table.subjunctivePastNosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastVosotros => $composableBuilder(
      column: $table.subjunctivePastVosotros,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjunctivePastEllos => $composableBuilder(
      column: $table.subjunctivePastEllos,
      builder: (column) => ColumnFilters(column));
}

class $$ConjugationsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $ConjugationsTable> {
  $$ConjugationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meaning => $composableBuilder(
      column: $table.meaning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get presentParticiple => $composableBuilder(
      column: $table.presentParticiple,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prastParticiple => $composableBuilder(
      column: $table.prastParticiple,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentYo => $composableBuilder(
      column: $table.indicativePresentYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentTu => $composableBuilder(
      column: $table.indicativePresentTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentEl => $composableBuilder(
      column: $table.indicativePresentEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentNosotros => $composableBuilder(
      column: $table.indicativePresentNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentVosotros => $composableBuilder(
      column: $table.indicativePresentVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePresentEllos => $composableBuilder(
      column: $table.indicativePresentEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteYo => $composableBuilder(
      column: $table.indicativePreteriteYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteTu => $composableBuilder(
      column: $table.indicativePreteriteTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteEl => $composableBuilder(
      column: $table.indicativePreteriteEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteNosotros => $composableBuilder(
      column: $table.indicativePreteriteNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteVosotros => $composableBuilder(
      column: $table.indicativePreteriteVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativePreteriteEllos => $composableBuilder(
      column: $table.indicativePreteriteEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectYo => $composableBuilder(
      column: $table.indicativeImperfectYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectTu => $composableBuilder(
      column: $table.indicativeImperfectTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectEl => $composableBuilder(
      column: $table.indicativeImperfectEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectNosotros => $composableBuilder(
      column: $table.indicativeImperfectNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectVosotros => $composableBuilder(
      column: $table.indicativeImperfectVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeImperfectEllos => $composableBuilder(
      column: $table.indicativeImperfectEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureYo => $composableBuilder(
      column: $table.indicativeFutureYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureTu => $composableBuilder(
      column: $table.indicativeFutureTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureEl => $composableBuilder(
      column: $table.indicativeFutureEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureNosotros => $composableBuilder(
      column: $table.indicativeFutureNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureVosotros => $composableBuilder(
      column: $table.indicativeFutureVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeFutureEllos => $composableBuilder(
      column: $table.indicativeFutureEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalYo => $composableBuilder(
      column: $table.indicativeConditionalYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalTu => $composableBuilder(
      column: $table.indicativeConditionalTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalEl => $composableBuilder(
      column: $table.indicativeConditionalEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalNosotros =>
      $composableBuilder(
          column: $table.indicativeConditionalNosotros,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalVosotros =>
      $composableBuilder(
          column: $table.indicativeConditionalVosotros,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get indicativeConditionalEllos => $composableBuilder(
      column: $table.indicativeConditionalEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imperativeTu => $composableBuilder(
      column: $table.imperativeTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imperativeEl => $composableBuilder(
      column: $table.imperativeEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imperativeNosotros => $composableBuilder(
      column: $table.imperativeNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imperativeVosotros => $composableBuilder(
      column: $table.imperativeVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imperativeEllos => $composableBuilder(
      column: $table.imperativeEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentYo => $composableBuilder(
      column: $table.subjunctivePresentYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentTu => $composableBuilder(
      column: $table.subjunctivePresentTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentEl => $composableBuilder(
      column: $table.subjunctivePresentEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentNosotros => $composableBuilder(
      column: $table.subjunctivePresentNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentVosotros => $composableBuilder(
      column: $table.subjunctivePresentVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePresentEllos => $composableBuilder(
      column: $table.subjunctivePresentEllos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastYo => $composableBuilder(
      column: $table.subjunctivePastYo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastTu => $composableBuilder(
      column: $table.subjunctivePastTu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastEl => $composableBuilder(
      column: $table.subjunctivePastEl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastNosotros => $composableBuilder(
      column: $table.subjunctivePastNosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastVosotros => $composableBuilder(
      column: $table.subjunctivePastVosotros,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjunctivePastEllos => $composableBuilder(
      column: $table.subjunctivePastEllos,
      builder: (column) => ColumnOrderings(column));
}

class $$ConjugationsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $ConjugationsTable> {
  $$ConjugationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get presentParticiple => $composableBuilder(
      column: $table.presentParticiple, builder: (column) => column);

  GeneratedColumn<String> get prastParticiple => $composableBuilder(
      column: $table.prastParticiple, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentYo => $composableBuilder(
      column: $table.indicativePresentYo, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentTu => $composableBuilder(
      column: $table.indicativePresentTu, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentEl => $composableBuilder(
      column: $table.indicativePresentEl, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentNosotros => $composableBuilder(
      column: $table.indicativePresentNosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentVosotros => $composableBuilder(
      column: $table.indicativePresentVosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativePresentEllos => $composableBuilder(
      column: $table.indicativePresentEllos, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteYo => $composableBuilder(
      column: $table.indicativePreteriteYo, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteTu => $composableBuilder(
      column: $table.indicativePreteriteTu, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteEl => $composableBuilder(
      column: $table.indicativePreteriteEl, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteNosotros => $composableBuilder(
      column: $table.indicativePreteriteNosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteVosotros => $composableBuilder(
      column: $table.indicativePreteriteVosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativePreteriteEllos => $composableBuilder(
      column: $table.indicativePreteriteEllos, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectYo => $composableBuilder(
      column: $table.indicativeImperfectYo, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectTu => $composableBuilder(
      column: $table.indicativeImperfectTu, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectEl => $composableBuilder(
      column: $table.indicativeImperfectEl, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectNosotros => $composableBuilder(
      column: $table.indicativeImperfectNosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectVosotros => $composableBuilder(
      column: $table.indicativeImperfectVosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativeImperfectEllos => $composableBuilder(
      column: $table.indicativeImperfectEllos, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureYo => $composableBuilder(
      column: $table.indicativeFutureYo, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureTu => $composableBuilder(
      column: $table.indicativeFutureTu, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureEl => $composableBuilder(
      column: $table.indicativeFutureEl, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureNosotros => $composableBuilder(
      column: $table.indicativeFutureNosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureVosotros => $composableBuilder(
      column: $table.indicativeFutureVosotros, builder: (column) => column);

  GeneratedColumn<String> get indicativeFutureEllos => $composableBuilder(
      column: $table.indicativeFutureEllos, builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalYo => $composableBuilder(
      column: $table.indicativeConditionalYo, builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalTu => $composableBuilder(
      column: $table.indicativeConditionalTu, builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalEl => $composableBuilder(
      column: $table.indicativeConditionalEl, builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalNosotros =>
      $composableBuilder(
          column: $table.indicativeConditionalNosotros,
          builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalVosotros =>
      $composableBuilder(
          column: $table.indicativeConditionalVosotros,
          builder: (column) => column);

  GeneratedColumn<String> get indicativeConditionalEllos => $composableBuilder(
      column: $table.indicativeConditionalEllos, builder: (column) => column);

  GeneratedColumn<String> get imperativeTu => $composableBuilder(
      column: $table.imperativeTu, builder: (column) => column);

  GeneratedColumn<String> get imperativeEl => $composableBuilder(
      column: $table.imperativeEl, builder: (column) => column);

  GeneratedColumn<String> get imperativeNosotros => $composableBuilder(
      column: $table.imperativeNosotros, builder: (column) => column);

  GeneratedColumn<String> get imperativeVosotros => $composableBuilder(
      column: $table.imperativeVosotros, builder: (column) => column);

  GeneratedColumn<String> get imperativeEllos => $composableBuilder(
      column: $table.imperativeEllos, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentYo => $composableBuilder(
      column: $table.subjunctivePresentYo, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentTu => $composableBuilder(
      column: $table.subjunctivePresentTu, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentEl => $composableBuilder(
      column: $table.subjunctivePresentEl, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentNosotros => $composableBuilder(
      column: $table.subjunctivePresentNosotros, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentVosotros => $composableBuilder(
      column: $table.subjunctivePresentVosotros, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePresentEllos => $composableBuilder(
      column: $table.subjunctivePresentEllos, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastYo => $composableBuilder(
      column: $table.subjunctivePastYo, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastTu => $composableBuilder(
      column: $table.subjunctivePastTu, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastEl => $composableBuilder(
      column: $table.subjunctivePastEl, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastNosotros => $composableBuilder(
      column: $table.subjunctivePastNosotros, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastVosotros => $composableBuilder(
      column: $table.subjunctivePastVosotros, builder: (column) => column);

  GeneratedColumn<String> get subjunctivePastEllos => $composableBuilder(
      column: $table.subjunctivePastEllos, builder: (column) => column);
}

class $$ConjugationsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $ConjugationsTable,
    Conjugation,
    $$ConjugationsTableFilterComposer,
    $$ConjugationsTableOrderingComposer,
    $$ConjugationsTableAnnotationComposer,
    $$ConjugationsTableCreateCompanionBuilder,
    $$ConjugationsTableUpdateCompanionBuilder,
    (
      Conjugation,
      BaseReferences<_$DatabaseProvider, $ConjugationsTable, Conjugation>
    ),
    Conjugation,
    PrefetchHooks Function()> {
  $$ConjugationsTableTableManager(
      _$DatabaseProvider db, $ConjugationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConjugationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConjugationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConjugationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String?> meaning = const Value.absent(),
            Value<String?> presentParticiple = const Value.absent(),
            Value<String?> prastParticiple = const Value.absent(),
            Value<String?> indicativePresentYo = const Value.absent(),
            Value<String?> indicativePresentTu = const Value.absent(),
            Value<String?> indicativePresentEl = const Value.absent(),
            Value<String?> indicativePresentNosotros = const Value.absent(),
            Value<String?> indicativePresentVosotros = const Value.absent(),
            Value<String?> indicativePresentEllos = const Value.absent(),
            Value<String?> indicativePreteriteYo = const Value.absent(),
            Value<String?> indicativePreteriteTu = const Value.absent(),
            Value<String?> indicativePreteriteEl = const Value.absent(),
            Value<String?> indicativePreteriteNosotros = const Value.absent(),
            Value<String?> indicativePreteriteVosotros = const Value.absent(),
            Value<String?> indicativePreteriteEllos = const Value.absent(),
            Value<String?> indicativeImperfectYo = const Value.absent(),
            Value<String?> indicativeImperfectTu = const Value.absent(),
            Value<String?> indicativeImperfectEl = const Value.absent(),
            Value<String?> indicativeImperfectNosotros = const Value.absent(),
            Value<String?> indicativeImperfectVosotros = const Value.absent(),
            Value<String?> indicativeImperfectEllos = const Value.absent(),
            Value<String?> indicativeFutureYo = const Value.absent(),
            Value<String?> indicativeFutureTu = const Value.absent(),
            Value<String?> indicativeFutureEl = const Value.absent(),
            Value<String?> indicativeFutureNosotros = const Value.absent(),
            Value<String?> indicativeFutureVosotros = const Value.absent(),
            Value<String?> indicativeFutureEllos = const Value.absent(),
            Value<String?> indicativeConditionalYo = const Value.absent(),
            Value<String?> indicativeConditionalTu = const Value.absent(),
            Value<String?> indicativeConditionalEl = const Value.absent(),
            Value<String?> indicativeConditionalNosotros = const Value.absent(),
            Value<String?> indicativeConditionalVosotros = const Value.absent(),
            Value<String?> indicativeConditionalEllos = const Value.absent(),
            Value<String?> imperativeTu = const Value.absent(),
            Value<String?> imperativeEl = const Value.absent(),
            Value<String?> imperativeNosotros = const Value.absent(),
            Value<String?> imperativeVosotros = const Value.absent(),
            Value<String?> imperativeEllos = const Value.absent(),
            Value<String?> subjunctivePresentYo = const Value.absent(),
            Value<String?> subjunctivePresentTu = const Value.absent(),
            Value<String?> subjunctivePresentEl = const Value.absent(),
            Value<String?> subjunctivePresentNosotros = const Value.absent(),
            Value<String?> subjunctivePresentVosotros = const Value.absent(),
            Value<String?> subjunctivePresentEllos = const Value.absent(),
            Value<String?> subjunctivePastYo = const Value.absent(),
            Value<String?> subjunctivePastTu = const Value.absent(),
            Value<String?> subjunctivePastEl = const Value.absent(),
            Value<String?> subjunctivePastNosotros = const Value.absent(),
            Value<String?> subjunctivePastVosotros = const Value.absent(),
            Value<String?> subjunctivePastEllos = const Value.absent(),
          }) =>
              ConjugationsCompanion(
            wordId: wordId,
            word: word,
            meaning: meaning,
            presentParticiple: presentParticiple,
            prastParticiple: prastParticiple,
            indicativePresentYo: indicativePresentYo,
            indicativePresentTu: indicativePresentTu,
            indicativePresentEl: indicativePresentEl,
            indicativePresentNosotros: indicativePresentNosotros,
            indicativePresentVosotros: indicativePresentVosotros,
            indicativePresentEllos: indicativePresentEllos,
            indicativePreteriteYo: indicativePreteriteYo,
            indicativePreteriteTu: indicativePreteriteTu,
            indicativePreteriteEl: indicativePreteriteEl,
            indicativePreteriteNosotros: indicativePreteriteNosotros,
            indicativePreteriteVosotros: indicativePreteriteVosotros,
            indicativePreteriteEllos: indicativePreteriteEllos,
            indicativeImperfectYo: indicativeImperfectYo,
            indicativeImperfectTu: indicativeImperfectTu,
            indicativeImperfectEl: indicativeImperfectEl,
            indicativeImperfectNosotros: indicativeImperfectNosotros,
            indicativeImperfectVosotros: indicativeImperfectVosotros,
            indicativeImperfectEllos: indicativeImperfectEllos,
            indicativeFutureYo: indicativeFutureYo,
            indicativeFutureTu: indicativeFutureTu,
            indicativeFutureEl: indicativeFutureEl,
            indicativeFutureNosotros: indicativeFutureNosotros,
            indicativeFutureVosotros: indicativeFutureVosotros,
            indicativeFutureEllos: indicativeFutureEllos,
            indicativeConditionalYo: indicativeConditionalYo,
            indicativeConditionalTu: indicativeConditionalTu,
            indicativeConditionalEl: indicativeConditionalEl,
            indicativeConditionalNosotros: indicativeConditionalNosotros,
            indicativeConditionalVosotros: indicativeConditionalVosotros,
            indicativeConditionalEllos: indicativeConditionalEllos,
            imperativeTu: imperativeTu,
            imperativeEl: imperativeEl,
            imperativeNosotros: imperativeNosotros,
            imperativeVosotros: imperativeVosotros,
            imperativeEllos: imperativeEllos,
            subjunctivePresentYo: subjunctivePresentYo,
            subjunctivePresentTu: subjunctivePresentTu,
            subjunctivePresentEl: subjunctivePresentEl,
            subjunctivePresentNosotros: subjunctivePresentNosotros,
            subjunctivePresentVosotros: subjunctivePresentVosotros,
            subjunctivePresentEllos: subjunctivePresentEllos,
            subjunctivePastYo: subjunctivePastYo,
            subjunctivePastTu: subjunctivePastTu,
            subjunctivePastEl: subjunctivePastEl,
            subjunctivePastNosotros: subjunctivePastNosotros,
            subjunctivePastVosotros: subjunctivePastVosotros,
            subjunctivePastEllos: subjunctivePastEllos,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            required String word,
            Value<String?> meaning = const Value.absent(),
            Value<String?> presentParticiple = const Value.absent(),
            Value<String?> prastParticiple = const Value.absent(),
            Value<String?> indicativePresentYo = const Value.absent(),
            Value<String?> indicativePresentTu = const Value.absent(),
            Value<String?> indicativePresentEl = const Value.absent(),
            Value<String?> indicativePresentNosotros = const Value.absent(),
            Value<String?> indicativePresentVosotros = const Value.absent(),
            Value<String?> indicativePresentEllos = const Value.absent(),
            Value<String?> indicativePreteriteYo = const Value.absent(),
            Value<String?> indicativePreteriteTu = const Value.absent(),
            Value<String?> indicativePreteriteEl = const Value.absent(),
            Value<String?> indicativePreteriteNosotros = const Value.absent(),
            Value<String?> indicativePreteriteVosotros = const Value.absent(),
            Value<String?> indicativePreteriteEllos = const Value.absent(),
            Value<String?> indicativeImperfectYo = const Value.absent(),
            Value<String?> indicativeImperfectTu = const Value.absent(),
            Value<String?> indicativeImperfectEl = const Value.absent(),
            Value<String?> indicativeImperfectNosotros = const Value.absent(),
            Value<String?> indicativeImperfectVosotros = const Value.absent(),
            Value<String?> indicativeImperfectEllos = const Value.absent(),
            Value<String?> indicativeFutureYo = const Value.absent(),
            Value<String?> indicativeFutureTu = const Value.absent(),
            Value<String?> indicativeFutureEl = const Value.absent(),
            Value<String?> indicativeFutureNosotros = const Value.absent(),
            Value<String?> indicativeFutureVosotros = const Value.absent(),
            Value<String?> indicativeFutureEllos = const Value.absent(),
            Value<String?> indicativeConditionalYo = const Value.absent(),
            Value<String?> indicativeConditionalTu = const Value.absent(),
            Value<String?> indicativeConditionalEl = const Value.absent(),
            Value<String?> indicativeConditionalNosotros = const Value.absent(),
            Value<String?> indicativeConditionalVosotros = const Value.absent(),
            Value<String?> indicativeConditionalEllos = const Value.absent(),
            Value<String?> imperativeTu = const Value.absent(),
            Value<String?> imperativeEl = const Value.absent(),
            Value<String?> imperativeNosotros = const Value.absent(),
            Value<String?> imperativeVosotros = const Value.absent(),
            Value<String?> imperativeEllos = const Value.absent(),
            Value<String?> subjunctivePresentYo = const Value.absent(),
            Value<String?> subjunctivePresentTu = const Value.absent(),
            Value<String?> subjunctivePresentEl = const Value.absent(),
            Value<String?> subjunctivePresentNosotros = const Value.absent(),
            Value<String?> subjunctivePresentVosotros = const Value.absent(),
            Value<String?> subjunctivePresentEllos = const Value.absent(),
            Value<String?> subjunctivePastYo = const Value.absent(),
            Value<String?> subjunctivePastTu = const Value.absent(),
            Value<String?> subjunctivePastEl = const Value.absent(),
            Value<String?> subjunctivePastNosotros = const Value.absent(),
            Value<String?> subjunctivePastVosotros = const Value.absent(),
            Value<String?> subjunctivePastEllos = const Value.absent(),
          }) =>
              ConjugationsCompanion.insert(
            wordId: wordId,
            word: word,
            meaning: meaning,
            presentParticiple: presentParticiple,
            prastParticiple: prastParticiple,
            indicativePresentYo: indicativePresentYo,
            indicativePresentTu: indicativePresentTu,
            indicativePresentEl: indicativePresentEl,
            indicativePresentNosotros: indicativePresentNosotros,
            indicativePresentVosotros: indicativePresentVosotros,
            indicativePresentEllos: indicativePresentEllos,
            indicativePreteriteYo: indicativePreteriteYo,
            indicativePreteriteTu: indicativePreteriteTu,
            indicativePreteriteEl: indicativePreteriteEl,
            indicativePreteriteNosotros: indicativePreteriteNosotros,
            indicativePreteriteVosotros: indicativePreteriteVosotros,
            indicativePreteriteEllos: indicativePreteriteEllos,
            indicativeImperfectYo: indicativeImperfectYo,
            indicativeImperfectTu: indicativeImperfectTu,
            indicativeImperfectEl: indicativeImperfectEl,
            indicativeImperfectNosotros: indicativeImperfectNosotros,
            indicativeImperfectVosotros: indicativeImperfectVosotros,
            indicativeImperfectEllos: indicativeImperfectEllos,
            indicativeFutureYo: indicativeFutureYo,
            indicativeFutureTu: indicativeFutureTu,
            indicativeFutureEl: indicativeFutureEl,
            indicativeFutureNosotros: indicativeFutureNosotros,
            indicativeFutureVosotros: indicativeFutureVosotros,
            indicativeFutureEllos: indicativeFutureEllos,
            indicativeConditionalYo: indicativeConditionalYo,
            indicativeConditionalTu: indicativeConditionalTu,
            indicativeConditionalEl: indicativeConditionalEl,
            indicativeConditionalNosotros: indicativeConditionalNosotros,
            indicativeConditionalVosotros: indicativeConditionalVosotros,
            indicativeConditionalEllos: indicativeConditionalEllos,
            imperativeTu: imperativeTu,
            imperativeEl: imperativeEl,
            imperativeNosotros: imperativeNosotros,
            imperativeVosotros: imperativeVosotros,
            imperativeEllos: imperativeEllos,
            subjunctivePresentYo: subjunctivePresentYo,
            subjunctivePresentTu: subjunctivePresentTu,
            subjunctivePresentEl: subjunctivePresentEl,
            subjunctivePresentNosotros: subjunctivePresentNosotros,
            subjunctivePresentVosotros: subjunctivePresentVosotros,
            subjunctivePresentEllos: subjunctivePresentEllos,
            subjunctivePastYo: subjunctivePastYo,
            subjunctivePastTu: subjunctivePastTu,
            subjunctivePastEl: subjunctivePastEl,
            subjunctivePastNosotros: subjunctivePastNosotros,
            subjunctivePastVosotros: subjunctivePastVosotros,
            subjunctivePastEllos: subjunctivePastEllos,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConjugationsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $ConjugationsTable,
    Conjugation,
    $$ConjugationsTableFilterComposer,
    $$ConjugationsTableOrderingComposer,
    $$ConjugationsTableAnnotationComposer,
    $$ConjugationsTableCreateCompanionBuilder,
    $$ConjugationsTableUpdateCompanionBuilder,
    (
      Conjugation,
      BaseReferences<_$DatabaseProvider, $ConjugationsTable, Conjugation>
    ),
    Conjugation,
    PrefetchHooks Function()>;
typedef $$DictionariesTableCreateCompanionBuilder = DictionariesCompanion
    Function({
  Value<int> dictionaryId,
  required int wordId,
  required String word,
  Value<int?> excf,
  Value<String?> headword,
  Value<String?> partOfSpeech,
  Value<String?> partOfSpeechMark,
  Value<String?> content,
  Value<String?> origin,
  Value<String?> htmlRaw,
});
typedef $$DictionariesTableUpdateCompanionBuilder = DictionariesCompanion
    Function({
  Value<int> dictionaryId,
  Value<int> wordId,
  Value<String> word,
  Value<int?> excf,
  Value<String?> headword,
  Value<String?> partOfSpeech,
  Value<String?> partOfSpeechMark,
  Value<String?> content,
  Value<String?> origin,
  Value<String?> htmlRaw,
});

class $$DictionariesTableFilterComposer
    extends Composer<_$DatabaseProvider, $DictionariesTable> {
  $$DictionariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get excf => $composableBuilder(
      column: $table.excf, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headword => $composableBuilder(
      column: $table.headword, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get htmlRaw => $composableBuilder(
      column: $table.htmlRaw, builder: (column) => ColumnFilters(column));
}

class $$DictionariesTableOrderingComposer
    extends Composer<_$DatabaseProvider, $DictionariesTable> {
  $$DictionariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get excf => $composableBuilder(
      column: $table.excf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headword => $composableBuilder(
      column: $table.headword, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get htmlRaw => $composableBuilder(
      column: $table.htmlRaw, builder: (column) => ColumnOrderings(column));
}

class $$DictionariesTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $DictionariesTable> {
  $$DictionariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<int> get excf =>
      $composableBuilder(column: $table.excf, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get htmlRaw =>
      $composableBuilder(column: $table.htmlRaw, builder: (column) => column);
}

class $$DictionariesTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $DictionariesTable,
    Dictionary,
    $$DictionariesTableFilterComposer,
    $$DictionariesTableOrderingComposer,
    $$DictionariesTableAnnotationComposer,
    $$DictionariesTableCreateCompanionBuilder,
    $$DictionariesTableUpdateCompanionBuilder,
    (
      Dictionary,
      BaseReferences<_$DatabaseProvider, $DictionariesTable, Dictionary>
    ),
    Dictionary,
    PrefetchHooks Function()> {
  $$DictionariesTableTableManager(
      _$DatabaseProvider db, $DictionariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> dictionaryId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<int?> excf = const Value.absent(),
            Value<String?> headword = const Value.absent(),
            Value<String?> partOfSpeech = const Value.absent(),
            Value<String?> partOfSpeechMark = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> origin = const Value.absent(),
            Value<String?> htmlRaw = const Value.absent(),
          }) =>
              DictionariesCompanion(
            dictionaryId: dictionaryId,
            wordId: wordId,
            word: word,
            excf: excf,
            headword: headword,
            partOfSpeech: partOfSpeech,
            partOfSpeechMark: partOfSpeechMark,
            content: content,
            origin: origin,
            htmlRaw: htmlRaw,
          ),
          createCompanionCallback: ({
            Value<int> dictionaryId = const Value.absent(),
            required int wordId,
            required String word,
            Value<int?> excf = const Value.absent(),
            Value<String?> headword = const Value.absent(),
            Value<String?> partOfSpeech = const Value.absent(),
            Value<String?> partOfSpeechMark = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> origin = const Value.absent(),
            Value<String?> htmlRaw = const Value.absent(),
          }) =>
              DictionariesCompanion.insert(
            dictionaryId: dictionaryId,
            wordId: wordId,
            word: word,
            excf: excf,
            headword: headword,
            partOfSpeech: partOfSpeech,
            partOfSpeechMark: partOfSpeechMark,
            content: content,
            origin: origin,
            htmlRaw: htmlRaw,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DictionariesTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $DictionariesTable,
    Dictionary,
    $$DictionariesTableFilterComposer,
    $$DictionariesTableOrderingComposer,
    $$DictionariesTableAnnotationComposer,
    $$DictionariesTableCreateCompanionBuilder,
    $$DictionariesTableUpdateCompanionBuilder,
    (
      Dictionary,
      BaseReferences<_$DatabaseProvider, $DictionariesTable, Dictionary>
    ),
    Dictionary,
    PrefetchHooks Function()>;
typedef $$ExamplesTableCreateCompanionBuilder = ExamplesCompanion Function({
  Value<int> exampleId,
  required int dictionaryId,
  required int exampleNo,
  required String espanolHtml,
  required String japaneseText,
  required String espanolText,
});
typedef $$ExamplesTableUpdateCompanionBuilder = ExamplesCompanion Function({
  Value<int> exampleId,
  Value<int> dictionaryId,
  Value<int> exampleNo,
  Value<String> espanolHtml,
  Value<String> japaneseText,
  Value<String> espanolText,
});

class $$ExamplesTableFilterComposer
    extends Composer<_$DatabaseProvider, $ExamplesTable> {
  $$ExamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exampleNo => $composableBuilder(
      column: $table.exampleNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => ColumnFilters(column));
}

class $$ExamplesTableOrderingComposer
    extends Composer<_$DatabaseProvider, $ExamplesTable> {
  $$ExamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exampleNo => $composableBuilder(
      column: $table.exampleNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => ColumnOrderings(column));
}

class $$ExamplesTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $ExamplesTable> {
  $$ExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get exampleId =>
      $composableBuilder(column: $table.exampleId, builder: (column) => column);

  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get exampleNo =>
      $composableBuilder(column: $table.exampleNo, builder: (column) => column);

  GeneratedColumn<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => column);

  GeneratedColumn<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText, builder: (column) => column);

  GeneratedColumn<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => column);
}

class $$ExamplesTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $ExamplesTable,
    Example,
    $$ExamplesTableFilterComposer,
    $$ExamplesTableOrderingComposer,
    $$ExamplesTableAnnotationComposer,
    $$ExamplesTableCreateCompanionBuilder,
    $$ExamplesTableUpdateCompanionBuilder,
    (Example, BaseReferences<_$DatabaseProvider, $ExamplesTable, Example>),
    Example,
    PrefetchHooks Function()> {
  $$ExamplesTableTableManager(_$DatabaseProvider db, $ExamplesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> exampleId = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<int> exampleNo = const Value.absent(),
            Value<String> espanolHtml = const Value.absent(),
            Value<String> japaneseText = const Value.absent(),
            Value<String> espanolText = const Value.absent(),
          }) =>
              ExamplesCompanion(
            exampleId: exampleId,
            dictionaryId: dictionaryId,
            exampleNo: exampleNo,
            espanolHtml: espanolHtml,
            japaneseText: japaneseText,
            espanolText: espanolText,
          ),
          createCompanionCallback: ({
            Value<int> exampleId = const Value.absent(),
            required int dictionaryId,
            required int exampleNo,
            required String espanolHtml,
            required String japaneseText,
            required String espanolText,
          }) =>
              ExamplesCompanion.insert(
            exampleId: exampleId,
            dictionaryId: dictionaryId,
            exampleNo: exampleNo,
            espanolHtml: espanolHtml,
            japaneseText: japaneseText,
            espanolText: espanolText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExamplesTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $ExamplesTable,
    Example,
    $$ExamplesTableFilterComposer,
    $$ExamplesTableOrderingComposer,
    $$ExamplesTableAnnotationComposer,
    $$ExamplesTableCreateCompanionBuilder,
    $$ExamplesTableUpdateCompanionBuilder,
    (Example, BaseReferences<_$DatabaseProvider, $ExamplesTable, Example>),
    Example,
    PrefetchHooks Function()>;
typedef $$IdiomsTableCreateCompanionBuilder = IdiomsCompanion Function({
  Value<int> idiomId,
  required int dictionaryId,
  required int idiomNo,
  required String idiom,
  required String description,
});
typedef $$IdiomsTableUpdateCompanionBuilder = IdiomsCompanion Function({
  Value<int> idiomId,
  Value<int> dictionaryId,
  Value<int> idiomNo,
  Value<String> idiom,
  Value<String> description,
});

class $$IdiomsTableFilterComposer
    extends Composer<_$DatabaseProvider, $IdiomsTable> {
  $$IdiomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idiomId => $composableBuilder(
      column: $table.idiomId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get idiomNo => $composableBuilder(
      column: $table.idiomNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idiom => $composableBuilder(
      column: $table.idiom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$IdiomsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $IdiomsTable> {
  $$IdiomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idiomId => $composableBuilder(
      column: $table.idiomId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get idiomNo => $composableBuilder(
      column: $table.idiomNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idiom => $composableBuilder(
      column: $table.idiom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$IdiomsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $IdiomsTable> {
  $$IdiomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idiomId =>
      $composableBuilder(column: $table.idiomId, builder: (column) => column);

  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get idiomNo =>
      $composableBuilder(column: $table.idiomNo, builder: (column) => column);

  GeneratedColumn<String> get idiom =>
      $composableBuilder(column: $table.idiom, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$IdiomsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $IdiomsTable,
    Idiom,
    $$IdiomsTableFilterComposer,
    $$IdiomsTableOrderingComposer,
    $$IdiomsTableAnnotationComposer,
    $$IdiomsTableCreateCompanionBuilder,
    $$IdiomsTableUpdateCompanionBuilder,
    (Idiom, BaseReferences<_$DatabaseProvider, $IdiomsTable, Idiom>),
    Idiom,
    PrefetchHooks Function()> {
  $$IdiomsTableTableManager(_$DatabaseProvider db, $IdiomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdiomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdiomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdiomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> idiomId = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<int> idiomNo = const Value.absent(),
            Value<String> idiom = const Value.absent(),
            Value<String> description = const Value.absent(),
          }) =>
              IdiomsCompanion(
            idiomId: idiomId,
            dictionaryId: dictionaryId,
            idiomNo: idiomNo,
            idiom: idiom,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> idiomId = const Value.absent(),
            required int dictionaryId,
            required int idiomNo,
            required String idiom,
            required String description,
          }) =>
              IdiomsCompanion.insert(
            idiomId: idiomId,
            dictionaryId: dictionaryId,
            idiomNo: idiomNo,
            idiom: idiom,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IdiomsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $IdiomsTable,
    Idiom,
    $$IdiomsTableFilterComposer,
    $$IdiomsTableOrderingComposer,
    $$IdiomsTableAnnotationComposer,
    $$IdiomsTableCreateCompanionBuilder,
    $$IdiomsTableUpdateCompanionBuilder,
    (Idiom, BaseReferences<_$DatabaseProvider, $IdiomsTable, Idiom>),
    Idiom,
    PrefetchHooks Function()>;
typedef $$PartOfSpeechListsTableCreateCompanionBuilder
    = PartOfSpeechListsCompanion Function({
  Value<int> partOfSpeechId,
  required int wordId,
  required String partOfSpeech,
});
typedef $$PartOfSpeechListsTableUpdateCompanionBuilder
    = PartOfSpeechListsCompanion Function({
  Value<int> partOfSpeechId,
  Value<int> wordId,
  Value<String> partOfSpeech,
});

class $$PartOfSpeechListsTableFilterComposer
    extends Composer<_$DatabaseProvider, $PartOfSpeechListsTable> {
  $$PartOfSpeechListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get partOfSpeechId => $composableBuilder(
      column: $table.partOfSpeechId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));
}

class $$PartOfSpeechListsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $PartOfSpeechListsTable> {
  $$PartOfSpeechListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get partOfSpeechId => $composableBuilder(
      column: $table.partOfSpeechId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));
}

class $$PartOfSpeechListsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $PartOfSpeechListsTable> {
  $$PartOfSpeechListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get partOfSpeechId => $composableBuilder(
      column: $table.partOfSpeechId, builder: (column) => column);

  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);
}

class $$PartOfSpeechListsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $PartOfSpeechListsTable,
    PartOfSpeechList,
    $$PartOfSpeechListsTableFilterComposer,
    $$PartOfSpeechListsTableOrderingComposer,
    $$PartOfSpeechListsTableAnnotationComposer,
    $$PartOfSpeechListsTableCreateCompanionBuilder,
    $$PartOfSpeechListsTableUpdateCompanionBuilder,
    (
      PartOfSpeechList,
      BaseReferences<_$DatabaseProvider, $PartOfSpeechListsTable,
          PartOfSpeechList>
    ),
    PartOfSpeechList,
    PrefetchHooks Function()> {
  $$PartOfSpeechListsTableTableManager(
      _$DatabaseProvider db, $PartOfSpeechListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartOfSpeechListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartOfSpeechListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartOfSpeechListsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> partOfSpeechId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<String> partOfSpeech = const Value.absent(),
          }) =>
              PartOfSpeechListsCompanion(
            partOfSpeechId: partOfSpeechId,
            wordId: wordId,
            partOfSpeech: partOfSpeech,
          ),
          createCompanionCallback: ({
            Value<int> partOfSpeechId = const Value.absent(),
            required int wordId,
            required String partOfSpeech,
          }) =>
              PartOfSpeechListsCompanion.insert(
            partOfSpeechId: partOfSpeechId,
            wordId: wordId,
            partOfSpeech: partOfSpeech,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PartOfSpeechListsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $PartOfSpeechListsTable,
    PartOfSpeechList,
    $$PartOfSpeechListsTableFilterComposer,
    $$PartOfSpeechListsTableOrderingComposer,
    $$PartOfSpeechListsTableAnnotationComposer,
    $$PartOfSpeechListsTableCreateCompanionBuilder,
    $$PartOfSpeechListsTableUpdateCompanionBuilder,
    (
      PartOfSpeechList,
      BaseReferences<_$DatabaseProvider, $PartOfSpeechListsTable,
          PartOfSpeechList>
    ),
    PartOfSpeechList,
    PrefetchHooks Function()>;
typedef $$RankingsTableCreateCompanionBuilder = RankingsCompanion Function({
  Value<int> rankingId,
  required int rankingNo,
  Value<String?> word,
  Value<String?> wordOrigin,
  Value<int?> wordId,
  Value<int?> hasConj,
});
typedef $$RankingsTableUpdateCompanionBuilder = RankingsCompanion Function({
  Value<int> rankingId,
  Value<int> rankingNo,
  Value<String?> word,
  Value<String?> wordOrigin,
  Value<int?> wordId,
  Value<int?> hasConj,
});

class $$RankingsTableFilterComposer
    extends Composer<_$DatabaseProvider, $RankingsTable> {
  $$RankingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rankingId => $composableBuilder(
      column: $table.rankingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rankingNo => $composableBuilder(
      column: $table.rankingNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordOrigin => $composableBuilder(
      column: $table.wordOrigin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hasConj => $composableBuilder(
      column: $table.hasConj, builder: (column) => ColumnFilters(column));
}

class $$RankingsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $RankingsTable> {
  $$RankingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rankingId => $composableBuilder(
      column: $table.rankingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rankingNo => $composableBuilder(
      column: $table.rankingNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordOrigin => $composableBuilder(
      column: $table.wordOrigin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hasConj => $composableBuilder(
      column: $table.hasConj, builder: (column) => ColumnOrderings(column));
}

class $$RankingsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $RankingsTable> {
  $$RankingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rankingId =>
      $composableBuilder(column: $table.rankingId, builder: (column) => column);

  GeneratedColumn<int> get rankingNo =>
      $composableBuilder(column: $table.rankingNo, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get wordOrigin => $composableBuilder(
      column: $table.wordOrigin, builder: (column) => column);

  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<int> get hasConj =>
      $composableBuilder(column: $table.hasConj, builder: (column) => column);
}

class $$RankingsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $RankingsTable,
    Ranking,
    $$RankingsTableFilterComposer,
    $$RankingsTableOrderingComposer,
    $$RankingsTableAnnotationComposer,
    $$RankingsTableCreateCompanionBuilder,
    $$RankingsTableUpdateCompanionBuilder,
    (Ranking, BaseReferences<_$DatabaseProvider, $RankingsTable, Ranking>),
    Ranking,
    PrefetchHooks Function()> {
  $$RankingsTableTableManager(_$DatabaseProvider db, $RankingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RankingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RankingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RankingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> rankingId = const Value.absent(),
            Value<int> rankingNo = const Value.absent(),
            Value<String?> word = const Value.absent(),
            Value<String?> wordOrigin = const Value.absent(),
            Value<int?> wordId = const Value.absent(),
            Value<int?> hasConj = const Value.absent(),
          }) =>
              RankingsCompanion(
            rankingId: rankingId,
            rankingNo: rankingNo,
            word: word,
            wordOrigin: wordOrigin,
            wordId: wordId,
            hasConj: hasConj,
          ),
          createCompanionCallback: ({
            Value<int> rankingId = const Value.absent(),
            required int rankingNo,
            Value<String?> word = const Value.absent(),
            Value<String?> wordOrigin = const Value.absent(),
            Value<int?> wordId = const Value.absent(),
            Value<int?> hasConj = const Value.absent(),
          }) =>
              RankingsCompanion.insert(
            rankingId: rankingId,
            rankingNo: rankingNo,
            word: word,
            wordOrigin: wordOrigin,
            wordId: wordId,
            hasConj: hasConj,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RankingsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $RankingsTable,
    Ranking,
    $$RankingsTableFilterComposer,
    $$RankingsTableOrderingComposer,
    $$RankingsTableAnnotationComposer,
    $$RankingsTableCreateCompanionBuilder,
    $$RankingsTableUpdateCompanionBuilder,
    (Ranking, BaseReferences<_$DatabaseProvider, $RankingsTable, Ranking>),
    Ranking,
    PrefetchHooks Function()>;
typedef $$SupplementsTableCreateCompanionBuilder = SupplementsCompanion
    Function({
  Value<int> supplementId,
  required int dictionaryId,
  required int supplementNo,
  required String content,
  Value<String?> exampleId,
});
typedef $$SupplementsTableUpdateCompanionBuilder = SupplementsCompanion
    Function({
  Value<int> supplementId,
  Value<int> dictionaryId,
  Value<int> supplementNo,
  Value<String> content,
  Value<String?> exampleId,
});

class $$SupplementsTableFilterComposer
    extends Composer<_$DatabaseProvider, $SupplementsTable> {
  $$SupplementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get supplementId => $composableBuilder(
      column: $table.supplementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get supplementNo => $composableBuilder(
      column: $table.supplementNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnFilters(column));
}

class $$SupplementsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $SupplementsTable> {
  $$SupplementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get supplementId => $composableBuilder(
      column: $table.supplementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get supplementNo => $composableBuilder(
      column: $table.supplementNo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnOrderings(column));
}

class $$SupplementsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $SupplementsTable> {
  $$SupplementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get supplementId => $composableBuilder(
      column: $table.supplementId, builder: (column) => column);

  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get supplementNo => $composableBuilder(
      column: $table.supplementNo, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get exampleId =>
      $composableBuilder(column: $table.exampleId, builder: (column) => column);
}

class $$SupplementsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $SupplementsTable,
    Supplement,
    $$SupplementsTableFilterComposer,
    $$SupplementsTableOrderingComposer,
    $$SupplementsTableAnnotationComposer,
    $$SupplementsTableCreateCompanionBuilder,
    $$SupplementsTableUpdateCompanionBuilder,
    (
      Supplement,
      BaseReferences<_$DatabaseProvider, $SupplementsTable, Supplement>
    ),
    Supplement,
    PrefetchHooks Function()> {
  $$SupplementsTableTableManager(_$DatabaseProvider db, $SupplementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> supplementId = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<int> supplementNo = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> exampleId = const Value.absent(),
          }) =>
              SupplementsCompanion(
            supplementId: supplementId,
            dictionaryId: dictionaryId,
            supplementNo: supplementNo,
            content: content,
            exampleId: exampleId,
          ),
          createCompanionCallback: ({
            Value<int> supplementId = const Value.absent(),
            required int dictionaryId,
            required int supplementNo,
            required String content,
            Value<String?> exampleId = const Value.absent(),
          }) =>
              SupplementsCompanion.insert(
            supplementId: supplementId,
            dictionaryId: dictionaryId,
            supplementNo: supplementNo,
            content: content,
            exampleId: exampleId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SupplementsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $SupplementsTable,
    Supplement,
    $$SupplementsTableFilterComposer,
    $$SupplementsTableOrderingComposer,
    $$SupplementsTableAnnotationComposer,
    $$SupplementsTableCreateCompanionBuilder,
    $$SupplementsTableUpdateCompanionBuilder,
    (
      Supplement,
      BaseReferences<_$DatabaseProvider, $SupplementsTable, Supplement>
    ),
    Supplement,
    PrefetchHooks Function()>;
typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> wordId,
  required String word,
  Value<String?> partOfSpeech,
  Value<String?> partOfSpeechMark,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> wordId,
  Value<String> word,
  Value<String?> partOfSpeech,
  Value<String?> partOfSpeechMark,
});

class $$WordsTableFilterComposer
    extends Composer<_$DatabaseProvider, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark,
      builder: (column) => ColumnFilters(column));
}

class $$WordsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark,
      builder: (column) => ColumnOrderings(column));
}

class $$WordsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
      column: $table.partOfSpeech, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeechMark => $composableBuilder(
      column: $table.partOfSpeechMark, builder: (column) => column);
}

class $$WordsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, BaseReferences<_$DatabaseProvider, $WordsTable, Word>),
    Word,
    PrefetchHooks Function()> {
  $$WordsTableTableManager(_$DatabaseProvider db, $WordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String?> partOfSpeech = const Value.absent(),
            Value<String?> partOfSpeechMark = const Value.absent(),
          }) =>
              WordsCompanion(
            wordId: wordId,
            word: word,
            partOfSpeech: partOfSpeech,
            partOfSpeechMark: partOfSpeechMark,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            required String word,
            Value<String?> partOfSpeech = const Value.absent(),
            Value<String?> partOfSpeechMark = const Value.absent(),
          }) =>
              WordsCompanion.insert(
            wordId: wordId,
            word: word,
            partOfSpeech: partOfSpeech,
            partOfSpeechMark: partOfSpeechMark,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, BaseReferences<_$DatabaseProvider, $WordsTable, Word>),
    Word,
    PrefetchHooks Function()>;
typedef $$WordStatusTableCreateCompanionBuilder = WordStatusCompanion Function({
  Value<int> wordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  required String editAt,
});
typedef $$WordStatusTableUpdateCompanionBuilder = WordStatusCompanion Function({
  Value<int> wordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  Value<String> editAt,
});

class $$WordStatusTableFilterComposer
    extends Composer<_$DatabaseProvider, $WordStatusTable> {
  $$WordStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnFilters(column));
}

class $$WordStatusTableOrderingComposer
    extends Composer<_$DatabaseProvider, $WordStatusTable> {
  $$WordStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnOrderings(column));
}

class $$WordStatusTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $WordStatusTable> {
  $$WordStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<int> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => column);

  GeneratedColumn<int> get hasNote =>
      $composableBuilder(column: $table.hasNote, builder: (column) => column);

  GeneratedColumn<String> get editAt =>
      $composableBuilder(column: $table.editAt, builder: (column) => column);
}

class $$WordStatusTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $WordStatusTable,
    WordStatusData,
    $$WordStatusTableFilterComposer,
    $$WordStatusTableOrderingComposer,
    $$WordStatusTableAnnotationComposer,
    $$WordStatusTableCreateCompanionBuilder,
    $$WordStatusTableUpdateCompanionBuilder,
    (
      WordStatusData,
      BaseReferences<_$DatabaseProvider, $WordStatusTable, WordStatusData>
    ),
    WordStatusData,
    PrefetchHooks Function()> {
  $$WordStatusTableTableManager(_$DatabaseProvider db, $WordStatusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            Value<String> editAt = const Value.absent(),
          }) =>
              WordStatusCompanion(
            wordId: wordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            required String editAt,
          }) =>
              WordStatusCompanion.insert(
            wordId: wordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordStatusTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $WordStatusTable,
    WordStatusData,
    $$WordStatusTableFilterComposer,
    $$WordStatusTableOrderingComposer,
    $$WordStatusTableAnnotationComposer,
    $$WordStatusTableCreateCompanionBuilder,
    $$WordStatusTableUpdateCompanionBuilder,
    (
      WordStatusData,
      BaseReferences<_$DatabaseProvider, $WordStatusTable, WordStatusData>
    ),
    WordStatusData,
    PrefetchHooks Function()>;
typedef $$MyWordsTableCreateCompanionBuilder = MyWordsCompanion Function({
  Value<int> myWordId,
  required String word,
  Value<String?> contents,
  required String editAt,
});
typedef $$MyWordsTableUpdateCompanionBuilder = MyWordsCompanion Function({
  Value<int> myWordId,
  Value<String> word,
  Value<String?> contents,
  Value<String> editAt,
});

class $$MyWordsTableFilterComposer
    extends Composer<_$DatabaseProvider, $MyWordsTable> {
  $$MyWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get myWordId => $composableBuilder(
      column: $table.myWordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contents => $composableBuilder(
      column: $table.contents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnFilters(column));
}

class $$MyWordsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $MyWordsTable> {
  $$MyWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get myWordId => $composableBuilder(
      column: $table.myWordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contents => $composableBuilder(
      column: $table.contents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnOrderings(column));
}

class $$MyWordsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $MyWordsTable> {
  $$MyWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get myWordId =>
      $composableBuilder(column: $table.myWordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get contents =>
      $composableBuilder(column: $table.contents, builder: (column) => column);

  GeneratedColumn<String> get editAt =>
      $composableBuilder(column: $table.editAt, builder: (column) => column);
}

class $$MyWordsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $MyWordsTable,
    MyWord,
    $$MyWordsTableFilterComposer,
    $$MyWordsTableOrderingComposer,
    $$MyWordsTableAnnotationComposer,
    $$MyWordsTableCreateCompanionBuilder,
    $$MyWordsTableUpdateCompanionBuilder,
    (MyWord, BaseReferences<_$DatabaseProvider, $MyWordsTable, MyWord>),
    MyWord,
    PrefetchHooks Function()> {
  $$MyWordsTableTableManager(_$DatabaseProvider db, $MyWordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> myWordId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String?> contents = const Value.absent(),
            Value<String> editAt = const Value.absent(),
          }) =>
              MyWordsCompanion(
            myWordId: myWordId,
            word: word,
            contents: contents,
            editAt: editAt,
          ),
          createCompanionCallback: ({
            Value<int> myWordId = const Value.absent(),
            required String word,
            Value<String?> contents = const Value.absent(),
            required String editAt,
          }) =>
              MyWordsCompanion.insert(
            myWordId: myWordId,
            word: word,
            contents: contents,
            editAt: editAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MyWordsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $MyWordsTable,
    MyWord,
    $$MyWordsTableFilterComposer,
    $$MyWordsTableOrderingComposer,
    $$MyWordsTableAnnotationComposer,
    $$MyWordsTableCreateCompanionBuilder,
    $$MyWordsTableUpdateCompanionBuilder,
    (MyWord, BaseReferences<_$DatabaseProvider, $MyWordsTable, MyWord>),
    MyWord,
    PrefetchHooks Function()>;
typedef $$MyWordStatusTableCreateCompanionBuilder = MyWordStatusCompanion
    Function({
  Value<int> myWordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  required String editAt,
});
typedef $$MyWordStatusTableUpdateCompanionBuilder = MyWordStatusCompanion
    Function({
  Value<int> myWordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  Value<String> editAt,
});

class $$MyWordStatusTableFilterComposer
    extends Composer<_$DatabaseProvider, $MyWordStatusTable> {
  $$MyWordStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get myWordId => $composableBuilder(
      column: $table.myWordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnFilters(column));
}

class $$MyWordStatusTableOrderingComposer
    extends Composer<_$DatabaseProvider, $MyWordStatusTable> {
  $$MyWordStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get myWordId => $composableBuilder(
      column: $table.myWordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnOrderings(column));
}

class $$MyWordStatusTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $MyWordStatusTable> {
  $$MyWordStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get myWordId =>
      $composableBuilder(column: $table.myWordId, builder: (column) => column);

  GeneratedColumn<int> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => column);

  GeneratedColumn<int> get hasNote =>
      $composableBuilder(column: $table.hasNote, builder: (column) => column);

  GeneratedColumn<String> get editAt =>
      $composableBuilder(column: $table.editAt, builder: (column) => column);
}

class $$MyWordStatusTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $MyWordStatusTable,
    MyWordStatusData,
    $$MyWordStatusTableFilterComposer,
    $$MyWordStatusTableOrderingComposer,
    $$MyWordStatusTableAnnotationComposer,
    $$MyWordStatusTableCreateCompanionBuilder,
    $$MyWordStatusTableUpdateCompanionBuilder,
    (
      MyWordStatusData,
      BaseReferences<_$DatabaseProvider, $MyWordStatusTable, MyWordStatusData>
    ),
    MyWordStatusData,
    PrefetchHooks Function()> {
  $$MyWordStatusTableTableManager(
      _$DatabaseProvider db, $MyWordStatusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyWordStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyWordStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyWordStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> myWordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            Value<String> editAt = const Value.absent(),
          }) =>
              MyWordStatusCompanion(
            myWordId: myWordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          createCompanionCallback: ({
            Value<int> myWordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            required String editAt,
          }) =>
              MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MyWordStatusTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $MyWordStatusTable,
    MyWordStatusData,
    $$MyWordStatusTableFilterComposer,
    $$MyWordStatusTableOrderingComposer,
    $$MyWordStatusTableAnnotationComposer,
    $$MyWordStatusTableCreateCompanionBuilder,
    $$MyWordStatusTableUpdateCompanionBuilder,
    (
      MyWordStatusData,
      BaseReferences<_$DatabaseProvider, $MyWordStatusTable, MyWordStatusData>
    ),
    MyWordStatusData,
    PrefetchHooks Function()>;
typedef $$JpnEspWordsTableCreateCompanionBuilder = JpnEspWordsCompanion
    Function({
  Value<int> wordId,
  required String word,
});
typedef $$JpnEspWordsTableUpdateCompanionBuilder = JpnEspWordsCompanion
    Function({
  Value<int> wordId,
  Value<String> word,
});

class $$JpnEspWordsTableFilterComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordsTable> {
  $$JpnEspWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));
}

class $$JpnEspWordsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordsTable> {
  $$JpnEspWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));
}

class $$JpnEspWordsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordsTable> {
  $$JpnEspWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);
}

class $$JpnEspWordsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $JpnEspWordsTable,
    JpnEspWord,
    $$JpnEspWordsTableFilterComposer,
    $$JpnEspWordsTableOrderingComposer,
    $$JpnEspWordsTableAnnotationComposer,
    $$JpnEspWordsTableCreateCompanionBuilder,
    $$JpnEspWordsTableUpdateCompanionBuilder,
    (
      JpnEspWord,
      BaseReferences<_$DatabaseProvider, $JpnEspWordsTable, JpnEspWord>
    ),
    JpnEspWord,
    PrefetchHooks Function()> {
  $$JpnEspWordsTableTableManager(_$DatabaseProvider db, $JpnEspWordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JpnEspWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JpnEspWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JpnEspWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<String> word = const Value.absent(),
          }) =>
              JpnEspWordsCompanion(
            wordId: wordId,
            word: word,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            required String word,
          }) =>
              JpnEspWordsCompanion.insert(
            wordId: wordId,
            word: word,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JpnEspWordsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $JpnEspWordsTable,
    JpnEspWord,
    $$JpnEspWordsTableFilterComposer,
    $$JpnEspWordsTableOrderingComposer,
    $$JpnEspWordsTableAnnotationComposer,
    $$JpnEspWordsTableCreateCompanionBuilder,
    $$JpnEspWordsTableUpdateCompanionBuilder,
    (
      JpnEspWord,
      BaseReferences<_$DatabaseProvider, $JpnEspWordsTable, JpnEspWord>
    ),
    JpnEspWord,
    PrefetchHooks Function()>;
typedef $$JpnEspWordStatusTableCreateCompanionBuilder
    = JpnEspWordStatusCompanion Function({
  Value<int> wordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  required String editAt,
});
typedef $$JpnEspWordStatusTableUpdateCompanionBuilder
    = JpnEspWordStatusCompanion Function({
  Value<int> wordId,
  Value<int?> isLearned,
  Value<int?> isBookmarked,
  Value<int?> hasNote,
  Value<String> editAt,
});

class $$JpnEspWordStatusTableFilterComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordStatusTable> {
  $$JpnEspWordStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnFilters(column));
}

class $$JpnEspWordStatusTableOrderingComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordStatusTable> {
  $$JpnEspWordStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isLearned => $composableBuilder(
      column: $table.isLearned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hasNote => $composableBuilder(
      column: $table.hasNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editAt => $composableBuilder(
      column: $table.editAt, builder: (column) => ColumnOrderings(column));
}

class $$JpnEspWordStatusTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $JpnEspWordStatusTable> {
  $$JpnEspWordStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<int> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<int> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => column);

  GeneratedColumn<int> get hasNote =>
      $composableBuilder(column: $table.hasNote, builder: (column) => column);

  GeneratedColumn<String> get editAt =>
      $composableBuilder(column: $table.editAt, builder: (column) => column);
}

class $$JpnEspWordStatusTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $JpnEspWordStatusTable,
    JpnEspWordStatusData,
    $$JpnEspWordStatusTableFilterComposer,
    $$JpnEspWordStatusTableOrderingComposer,
    $$JpnEspWordStatusTableAnnotationComposer,
    $$JpnEspWordStatusTableCreateCompanionBuilder,
    $$JpnEspWordStatusTableUpdateCompanionBuilder,
    (
      JpnEspWordStatusData,
      BaseReferences<_$DatabaseProvider, $JpnEspWordStatusTable,
          JpnEspWordStatusData>
    ),
    JpnEspWordStatusData,
    PrefetchHooks Function()> {
  $$JpnEspWordStatusTableTableManager(
      _$DatabaseProvider db, $JpnEspWordStatusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JpnEspWordStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JpnEspWordStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JpnEspWordStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            Value<String> editAt = const Value.absent(),
          }) =>
              JpnEspWordStatusCompanion(
            wordId: wordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<int?> isLearned = const Value.absent(),
            Value<int?> isBookmarked = const Value.absent(),
            Value<int?> hasNote = const Value.absent(),
            required String editAt,
          }) =>
              JpnEspWordStatusCompanion.insert(
            wordId: wordId,
            isLearned: isLearned,
            isBookmarked: isBookmarked,
            hasNote: hasNote,
            editAt: editAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JpnEspWordStatusTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $JpnEspWordStatusTable,
    JpnEspWordStatusData,
    $$JpnEspWordStatusTableFilterComposer,
    $$JpnEspWordStatusTableOrderingComposer,
    $$JpnEspWordStatusTableAnnotationComposer,
    $$JpnEspWordStatusTableCreateCompanionBuilder,
    $$JpnEspWordStatusTableUpdateCompanionBuilder,
    (
      JpnEspWordStatusData,
      BaseReferences<_$DatabaseProvider, $JpnEspWordStatusTable,
          JpnEspWordStatusData>
    ),
    JpnEspWordStatusData,
    PrefetchHooks Function()>;
typedef $$JpnEspDictionariesTableCreateCompanionBuilder
    = JpnEspDictionariesCompanion Function({
  Value<int> dictionaryId,
  required int wordId,
  required String word,
  required int excf,
  required String headword,
  required String content,
  required String htmlRaw,
});
typedef $$JpnEspDictionariesTableUpdateCompanionBuilder
    = JpnEspDictionariesCompanion Function({
  Value<int> dictionaryId,
  Value<int> wordId,
  Value<String> word,
  Value<int> excf,
  Value<String> headword,
  Value<String> content,
  Value<String> htmlRaw,
});

class $$JpnEspDictionariesTableFilterComposer
    extends Composer<_$DatabaseProvider, $JpnEspDictionariesTable> {
  $$JpnEspDictionariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get excf => $composableBuilder(
      column: $table.excf, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headword => $composableBuilder(
      column: $table.headword, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get htmlRaw => $composableBuilder(
      column: $table.htmlRaw, builder: (column) => ColumnFilters(column));
}

class $$JpnEspDictionariesTableOrderingComposer
    extends Composer<_$DatabaseProvider, $JpnEspDictionariesTable> {
  $$JpnEspDictionariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get excf => $composableBuilder(
      column: $table.excf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headword => $composableBuilder(
      column: $table.headword, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get htmlRaw => $composableBuilder(
      column: $table.htmlRaw, builder: (column) => ColumnOrderings(column));
}

class $$JpnEspDictionariesTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $JpnEspDictionariesTable> {
  $$JpnEspDictionariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<int> get excf =>
      $composableBuilder(column: $table.excf, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get htmlRaw =>
      $composableBuilder(column: $table.htmlRaw, builder: (column) => column);
}

class $$JpnEspDictionariesTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $JpnEspDictionariesTable,
    JpnEspDictionary,
    $$JpnEspDictionariesTableFilterComposer,
    $$JpnEspDictionariesTableOrderingComposer,
    $$JpnEspDictionariesTableAnnotationComposer,
    $$JpnEspDictionariesTableCreateCompanionBuilder,
    $$JpnEspDictionariesTableUpdateCompanionBuilder,
    (
      JpnEspDictionary,
      BaseReferences<_$DatabaseProvider, $JpnEspDictionariesTable,
          JpnEspDictionary>
    ),
    JpnEspDictionary,
    PrefetchHooks Function()> {
  $$JpnEspDictionariesTableTableManager(
      _$DatabaseProvider db, $JpnEspDictionariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JpnEspDictionariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JpnEspDictionariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JpnEspDictionariesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> dictionaryId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<int> excf = const Value.absent(),
            Value<String> headword = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> htmlRaw = const Value.absent(),
          }) =>
              JpnEspDictionariesCompanion(
            dictionaryId: dictionaryId,
            wordId: wordId,
            word: word,
            excf: excf,
            headword: headword,
            content: content,
            htmlRaw: htmlRaw,
          ),
          createCompanionCallback: ({
            Value<int> dictionaryId = const Value.absent(),
            required int wordId,
            required String word,
            required int excf,
            required String headword,
            required String content,
            required String htmlRaw,
          }) =>
              JpnEspDictionariesCompanion.insert(
            dictionaryId: dictionaryId,
            wordId: wordId,
            word: word,
            excf: excf,
            headword: headword,
            content: content,
            htmlRaw: htmlRaw,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JpnEspDictionariesTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $JpnEspDictionariesTable,
    JpnEspDictionary,
    $$JpnEspDictionariesTableFilterComposer,
    $$JpnEspDictionariesTableOrderingComposer,
    $$JpnEspDictionariesTableAnnotationComposer,
    $$JpnEspDictionariesTableCreateCompanionBuilder,
    $$JpnEspDictionariesTableUpdateCompanionBuilder,
    (
      JpnEspDictionary,
      BaseReferences<_$DatabaseProvider, $JpnEspDictionariesTable,
          JpnEspDictionary>
    ),
    JpnEspDictionary,
    PrefetchHooks Function()>;
typedef $$JpnEspExamplesTableCreateCompanionBuilder = JpnEspExamplesCompanion
    Function({
  Value<int> exampleId,
  required int dictionaryId,
  required int exampleNo,
  required String japaneseText,
  required String espanolHtml,
  required String espanolText,
});
typedef $$JpnEspExamplesTableUpdateCompanionBuilder = JpnEspExamplesCompanion
    Function({
  Value<int> exampleId,
  Value<int> dictionaryId,
  Value<int> exampleNo,
  Value<String> japaneseText,
  Value<String> espanolHtml,
  Value<String> espanolText,
});

class $$JpnEspExamplesTableFilterComposer
    extends Composer<_$DatabaseProvider, $JpnEspExamplesTable> {
  $$JpnEspExamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exampleNo => $composableBuilder(
      column: $table.exampleNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => ColumnFilters(column));
}

class $$JpnEspExamplesTableOrderingComposer
    extends Composer<_$DatabaseProvider, $JpnEspExamplesTable> {
  $$JpnEspExamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get exampleId => $composableBuilder(
      column: $table.exampleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exampleNo => $composableBuilder(
      column: $table.exampleNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => ColumnOrderings(column));
}

class $$JpnEspExamplesTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $JpnEspExamplesTable> {
  $$JpnEspExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get exampleId =>
      $composableBuilder(column: $table.exampleId, builder: (column) => column);

  GeneratedColumn<int> get dictionaryId => $composableBuilder(
      column: $table.dictionaryId, builder: (column) => column);

  GeneratedColumn<int> get exampleNo =>
      $composableBuilder(column: $table.exampleNo, builder: (column) => column);

  GeneratedColumn<String> get japaneseText => $composableBuilder(
      column: $table.japaneseText, builder: (column) => column);

  GeneratedColumn<String> get espanolHtml => $composableBuilder(
      column: $table.espanolHtml, builder: (column) => column);

  GeneratedColumn<String> get espanolText => $composableBuilder(
      column: $table.espanolText, builder: (column) => column);
}

class $$JpnEspExamplesTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $JpnEspExamplesTable,
    JpnEspExample,
    $$JpnEspExamplesTableFilterComposer,
    $$JpnEspExamplesTableOrderingComposer,
    $$JpnEspExamplesTableAnnotationComposer,
    $$JpnEspExamplesTableCreateCompanionBuilder,
    $$JpnEspExamplesTableUpdateCompanionBuilder,
    (
      JpnEspExample,
      BaseReferences<_$DatabaseProvider, $JpnEspExamplesTable, JpnEspExample>
    ),
    JpnEspExample,
    PrefetchHooks Function()> {
  $$JpnEspExamplesTableTableManager(
      _$DatabaseProvider db, $JpnEspExamplesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JpnEspExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JpnEspExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JpnEspExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> exampleId = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<int> exampleNo = const Value.absent(),
            Value<String> japaneseText = const Value.absent(),
            Value<String> espanolHtml = const Value.absent(),
            Value<String> espanolText = const Value.absent(),
          }) =>
              JpnEspExamplesCompanion(
            exampleId: exampleId,
            dictionaryId: dictionaryId,
            exampleNo: exampleNo,
            japaneseText: japaneseText,
            espanolHtml: espanolHtml,
            espanolText: espanolText,
          ),
          createCompanionCallback: ({
            Value<int> exampleId = const Value.absent(),
            required int dictionaryId,
            required int exampleNo,
            required String japaneseText,
            required String espanolHtml,
            required String espanolText,
          }) =>
              JpnEspExamplesCompanion.insert(
            exampleId: exampleId,
            dictionaryId: dictionaryId,
            exampleNo: exampleNo,
            japaneseText: japaneseText,
            espanolHtml: espanolHtml,
            espanolText: espanolText,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JpnEspExamplesTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $JpnEspExamplesTable,
    JpnEspExample,
    $$JpnEspExamplesTableFilterComposer,
    $$JpnEspExamplesTableOrderingComposer,
    $$JpnEspExamplesTableAnnotationComposer,
    $$JpnEspExamplesTableCreateCompanionBuilder,
    $$JpnEspExamplesTableUpdateCompanionBuilder,
    (
      JpnEspExample,
      BaseReferences<_$DatabaseProvider, $JpnEspExamplesTable, JpnEspExample>
    ),
    JpnEspExample,
    PrefetchHooks Function()>;
typedef $$EsEnConjugacionsTableCreateCompanionBuilder
    = EsEnConjugacionsCompanion Function({
  Value<int> wordId,
  Value<String?> word,
  Value<String?> english,
  Value<String?> present3rd,
  Value<String?> presentP,
  Value<String?> past,
  Value<String?> pastP,
});
typedef $$EsEnConjugacionsTableUpdateCompanionBuilder
    = EsEnConjugacionsCompanion Function({
  Value<int> wordId,
  Value<String?> word,
  Value<String?> english,
  Value<String?> present3rd,
  Value<String?> presentP,
  Value<String?> past,
  Value<String?> pastP,
});

class $$EsEnConjugacionsTableFilterComposer
    extends Composer<_$DatabaseProvider, $EsEnConjugacionsTable> {
  $$EsEnConjugacionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get english => $composableBuilder(
      column: $table.english, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get present3rd => $composableBuilder(
      column: $table.present3rd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get presentP => $composableBuilder(
      column: $table.presentP, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get past => $composableBuilder(
      column: $table.past, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pastP => $composableBuilder(
      column: $table.pastP, builder: (column) => ColumnFilters(column));
}

class $$EsEnConjugacionsTableOrderingComposer
    extends Composer<_$DatabaseProvider, $EsEnConjugacionsTable> {
  $$EsEnConjugacionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get english => $composableBuilder(
      column: $table.english, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get present3rd => $composableBuilder(
      column: $table.present3rd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get presentP => $composableBuilder(
      column: $table.presentP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get past => $composableBuilder(
      column: $table.past, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pastP => $composableBuilder(
      column: $table.pastP, builder: (column) => ColumnOrderings(column));
}

class $$EsEnConjugacionsTableAnnotationComposer
    extends Composer<_$DatabaseProvider, $EsEnConjugacionsTable> {
  $$EsEnConjugacionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get present3rd => $composableBuilder(
      column: $table.present3rd, builder: (column) => column);

  GeneratedColumn<String> get presentP =>
      $composableBuilder(column: $table.presentP, builder: (column) => column);

  GeneratedColumn<String> get past =>
      $composableBuilder(column: $table.past, builder: (column) => column);

  GeneratedColumn<String> get pastP =>
      $composableBuilder(column: $table.pastP, builder: (column) => column);
}

class $$EsEnConjugacionsTableTableManager extends RootTableManager<
    _$DatabaseProvider,
    $EsEnConjugacionsTable,
    EsEnConjugacion,
    $$EsEnConjugacionsTableFilterComposer,
    $$EsEnConjugacionsTableOrderingComposer,
    $$EsEnConjugacionsTableAnnotationComposer,
    $$EsEnConjugacionsTableCreateCompanionBuilder,
    $$EsEnConjugacionsTableUpdateCompanionBuilder,
    (
      EsEnConjugacion,
      BaseReferences<_$DatabaseProvider, $EsEnConjugacionsTable,
          EsEnConjugacion>
    ),
    EsEnConjugacion,
    PrefetchHooks Function()> {
  $$EsEnConjugacionsTableTableManager(
      _$DatabaseProvider db, $EsEnConjugacionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EsEnConjugacionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EsEnConjugacionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EsEnConjugacionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<String?> word = const Value.absent(),
            Value<String?> english = const Value.absent(),
            Value<String?> present3rd = const Value.absent(),
            Value<String?> presentP = const Value.absent(),
            Value<String?> past = const Value.absent(),
            Value<String?> pastP = const Value.absent(),
          }) =>
              EsEnConjugacionsCompanion(
            wordId: wordId,
            word: word,
            english: english,
            present3rd: present3rd,
            presentP: presentP,
            past: past,
            pastP: pastP,
          ),
          createCompanionCallback: ({
            Value<int> wordId = const Value.absent(),
            Value<String?> word = const Value.absent(),
            Value<String?> english = const Value.absent(),
            Value<String?> present3rd = const Value.absent(),
            Value<String?> presentP = const Value.absent(),
            Value<String?> past = const Value.absent(),
            Value<String?> pastP = const Value.absent(),
          }) =>
              EsEnConjugacionsCompanion.insert(
            wordId: wordId,
            word: word,
            english: english,
            present3rd: present3rd,
            presentP: presentP,
            past: past,
            pastP: pastP,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EsEnConjugacionsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseProvider,
    $EsEnConjugacionsTable,
    EsEnConjugacion,
    $$EsEnConjugacionsTableFilterComposer,
    $$EsEnConjugacionsTableOrderingComposer,
    $$EsEnConjugacionsTableAnnotationComposer,
    $$EsEnConjugacionsTableCreateCompanionBuilder,
    $$EsEnConjugacionsTableUpdateCompanionBuilder,
    (
      EsEnConjugacion,
      BaseReferences<_$DatabaseProvider, $EsEnConjugacionsTable,
          EsEnConjugacion>
    ),
    EsEnConjugacion,
    PrefetchHooks Function()>;

class $DatabaseProviderManager {
  final _$DatabaseProvider _db;
  $DatabaseProviderManager(this._db);
  $$ConjugationsTableTableManager get conjugations =>
      $$ConjugationsTableTableManager(_db, _db.conjugations);
  $$DictionariesTableTableManager get dictionaries =>
      $$DictionariesTableTableManager(_db, _db.dictionaries);
  $$ExamplesTableTableManager get examples =>
      $$ExamplesTableTableManager(_db, _db.examples);
  $$IdiomsTableTableManager get idioms =>
      $$IdiomsTableTableManager(_db, _db.idioms);
  $$PartOfSpeechListsTableTableManager get partOfSpeechLists =>
      $$PartOfSpeechListsTableTableManager(_db, _db.partOfSpeechLists);
  $$RankingsTableTableManager get rankings =>
      $$RankingsTableTableManager(_db, _db.rankings);
  $$SupplementsTableTableManager get supplements =>
      $$SupplementsTableTableManager(_db, _db.supplements);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordStatusTableTableManager get wordStatus =>
      $$WordStatusTableTableManager(_db, _db.wordStatus);
  $$MyWordsTableTableManager get myWords =>
      $$MyWordsTableTableManager(_db, _db.myWords);
  $$MyWordStatusTableTableManager get myWordStatus =>
      $$MyWordStatusTableTableManager(_db, _db.myWordStatus);
  $$JpnEspWordsTableTableManager get jpnEspWords =>
      $$JpnEspWordsTableTableManager(_db, _db.jpnEspWords);
  $$JpnEspWordStatusTableTableManager get jpnEspWordStatus =>
      $$JpnEspWordStatusTableTableManager(_db, _db.jpnEspWordStatus);
  $$JpnEspDictionariesTableTableManager get jpnEspDictionaries =>
      $$JpnEspDictionariesTableTableManager(_db, _db.jpnEspDictionaries);
  $$JpnEspExamplesTableTableManager get jpnEspExamples =>
      $$JpnEspExamplesTableTableManager(_db, _db.jpnEspExamples);
  $$EsEnConjugacionsTableTableManager get esEnConjugacions =>
      $$EsEnConjugacionsTableTableManager(_db, _db.esEnConjugacions);
}
