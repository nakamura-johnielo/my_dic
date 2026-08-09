/// Search-owned position of a matching form in a conjugation result.
enum SearchConjugationMatchKey {
  presentParticiple('present_participle', SearchMoodTense.participlePresent,
      SearchSubject.yo),
  pastParticiple(
      'past_participle', SearchMoodTense.participlePast, SearchSubject.yo),
  indicativePresentYo('indicative_present_yo',
      SearchMoodTense.indicativePresent, SearchSubject.yo),
  indicativePresentTu('indicative_present_tu',
      SearchMoodTense.indicativePresent, SearchSubject.tu),
  indicativePresentEl('indicative_present_el',
      SearchMoodTense.indicativePresent, SearchSubject.el),
  indicativePresentNosotros('indicative_present_nosotros',
      SearchMoodTense.indicativePresent, SearchSubject.nosotros),
  indicativePresentVosotros('indicative_present_vosotros',
      SearchMoodTense.indicativePresent, SearchSubject.vosotros),
  indicativePresentEllos('indicative_present_ellos',
      SearchMoodTense.indicativePresent, SearchSubject.ellos),
  indicativePreteriteYo('indicative_preterite_yo',
      SearchMoodTense.indicativePreterite, SearchSubject.yo),
  indicativePreteriteTu('indicative_preterite_tu',
      SearchMoodTense.indicativePreterite, SearchSubject.tu),
  indicativePreteriteEl('indicative_preterite_el',
      SearchMoodTense.indicativePreterite, SearchSubject.el),
  indicativePreteriteNosotros('indicative_preterite_nosotros',
      SearchMoodTense.indicativePreterite, SearchSubject.nosotros),
  indicativePreteriteVosotros('indicative_preterite_vosotros',
      SearchMoodTense.indicativePreterite, SearchSubject.vosotros),
  indicativePreteriteEllos('indicative_preterite_ellos',
      SearchMoodTense.indicativePreterite, SearchSubject.ellos),
  indicativeImperfectYo('indicative_imperfect_yo',
      SearchMoodTense.indicativeImperfect, SearchSubject.yo),
  indicativeImperfectTu('indicative_imperfect_tu',
      SearchMoodTense.indicativeImperfect, SearchSubject.tu),
  indicativeImperfectEl('indicative_imperfect_el',
      SearchMoodTense.indicativeImperfect, SearchSubject.el),
  indicativeImperfectNosotros('indicative_imperfect_nosotros',
      SearchMoodTense.indicativeImperfect, SearchSubject.nosotros),
  indicativeImperfectVosotros('indicative_imperfect_vosotros',
      SearchMoodTense.indicativeImperfect, SearchSubject.vosotros),
  indicativeImperfectEllos('indicative_imperfect_ellos',
      SearchMoodTense.indicativeImperfect, SearchSubject.ellos),
  indicativeFutureYo('indicative_future_yo', SearchMoodTense.indicativeFuture,
      SearchSubject.yo),
  indicativeFutureTu('indicative_future_tu', SearchMoodTense.indicativeFuture,
      SearchSubject.tu),
  indicativeFutureEl('indicative_future_el', SearchMoodTense.indicativeFuture,
      SearchSubject.el),
  indicativeFutureNosotros('indicative_future_nosotros',
      SearchMoodTense.indicativeFuture, SearchSubject.nosotros),
  indicativeFutureVosotros('indicative_future_vosotros',
      SearchMoodTense.indicativeFuture, SearchSubject.vosotros),
  indicativeFutureEllos('indicative_future_ellos',
      SearchMoodTense.indicativeFuture, SearchSubject.ellos),
  indicativeConditionalYo('indicative_conditional_yo',
      SearchMoodTense.indicativeConditional, SearchSubject.yo),
  indicativeConditionalTu('indicative_conditional_tu',
      SearchMoodTense.indicativeConditional, SearchSubject.tu),
  indicativeConditionalEl('indicative_conditional_el',
      SearchMoodTense.indicativeConditional, SearchSubject.el),
  indicativeConditionalNosotros('indicative_conditional_nosotros',
      SearchMoodTense.indicativeConditional, SearchSubject.nosotros),
  indicativeConditionalVosotros('indicative_conditional_vosotros',
      SearchMoodTense.indicativeConditional, SearchSubject.vosotros),
  indicativeConditionalEllos('indicative_conditional_ellos',
      SearchMoodTense.indicativeConditional, SearchSubject.ellos),
  imperativeTu('imperative_tu', SearchMoodTense.imperative, SearchSubject.tu),
  imperativeEl('imperative_el', SearchMoodTense.imperative, SearchSubject.el),
  imperativeNosotros('imperative_nosotros', SearchMoodTense.imperative,
      SearchSubject.nosotros),
  imperativeVosotros('imperative_vosotros', SearchMoodTense.imperative,
      SearchSubject.vosotros),
  imperativeEllos(
      'imperative_ellos', SearchMoodTense.imperative, SearchSubject.ellos),
  subjunctivePresentYo('subjunctive_present_yo',
      SearchMoodTense.subjunctivePresent, SearchSubject.yo),
  subjunctivePresentTu('subjunctive_present_tu',
      SearchMoodTense.subjunctivePresent, SearchSubject.tu),
  subjunctivePresentEl('subjunctive_present_el',
      SearchMoodTense.subjunctivePresent, SearchSubject.el),
  subjunctivePresentNosotros('subjunctive_present_nosotros',
      SearchMoodTense.subjunctivePresent, SearchSubject.nosotros),
  subjunctivePresentVosotros('subjunctive_present_vosotros',
      SearchMoodTense.subjunctivePresent, SearchSubject.vosotros),
  subjunctivePresentEllos('subjunctive_present_ellos',
      SearchMoodTense.subjunctivePresent, SearchSubject.ellos),
  subjunctivePastYo(
      'subjunctive_past_yo', SearchMoodTense.subjunctivePast, SearchSubject.yo),
  subjunctivePastTu(
      'subjunctive_past_tu', SearchMoodTense.subjunctivePast, SearchSubject.tu),
  subjunctivePastEl(
      'subjunctive_past_el', SearchMoodTense.subjunctivePast, SearchSubject.el),
  subjunctivePastNosotros('subjunctive_past_nosotros',
      SearchMoodTense.subjunctivePast, SearchSubject.nosotros),
  subjunctivePastVosotros('subjunctive_past_vosotros',
      SearchMoodTense.subjunctivePast, SearchSubject.vosotros),
  subjunctivePastEllos('subjunctive_past_ellos',
      SearchMoodTense.subjunctivePast, SearchSubject.ellos);

  const SearchConjugationMatchKey(this.wireValue, this.moodTense, this.subject);

  final String wireValue;
  final SearchMoodTense moodTense;
  final SearchSubject subject;

  static SearchConjugationMatchKey? tryFromWireValue(String value) {
    for (final key in values) {
      if (key.wireValue == value) return key;
    }
    return null;
  }
}

enum SearchMoodTense {
  participlePresent,
  participlePast,
  indicativePresent,
  indicativePreterite,
  indicativeImperfect,
  indicativeFuture,
  indicativeConditional,
  imperative,
  subjunctivePresent,
  subjunctivePast,
}

enum SearchSubject { yo, tu, el, nosotros, vosotros, ellos }
