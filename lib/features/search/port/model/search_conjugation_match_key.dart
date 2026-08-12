enum SearchConjugationMatchKey {
  presentParticiple(SearchMoodTense.participlePresent, SearchSubject.yo),
  pastParticiple(SearchMoodTense.participlePast, SearchSubject.yo),
  indicativePresentYo(SearchMoodTense.indicativePresent, SearchSubject.yo),
  indicativePresentTu(SearchMoodTense.indicativePresent, SearchSubject.tu),
  indicativePresentEl(SearchMoodTense.indicativePresent, SearchSubject.el),
  indicativePresentNosotros(
      SearchMoodTense.indicativePresent, SearchSubject.nosotros),
  indicativePresentVosotros(
      SearchMoodTense.indicativePresent, SearchSubject.vosotros),
  indicativePresentEllos(
      SearchMoodTense.indicativePresent, SearchSubject.ellos),
  indicativePreteriteYo(SearchMoodTense.indicativePreterite, SearchSubject.yo),
  indicativePreteriteTu(SearchMoodTense.indicativePreterite, SearchSubject.tu),
  indicativePreteriteEl(SearchMoodTense.indicativePreterite, SearchSubject.el),
  indicativePreteriteNosotros(
      SearchMoodTense.indicativePreterite, SearchSubject.nosotros),
  indicativePreteriteVosotros(
      SearchMoodTense.indicativePreterite, SearchSubject.vosotros),
  indicativePreteriteEllos(
      SearchMoodTense.indicativePreterite, SearchSubject.ellos),
  indicativeImperfectYo(SearchMoodTense.indicativeImperfect, SearchSubject.yo),
  indicativeImperfectTu(SearchMoodTense.indicativeImperfect, SearchSubject.tu),
  indicativeImperfectEl(SearchMoodTense.indicativeImperfect, SearchSubject.el),
  indicativeImperfectNosotros(
      SearchMoodTense.indicativeImperfect, SearchSubject.nosotros),
  indicativeImperfectVosotros(
      SearchMoodTense.indicativeImperfect, SearchSubject.vosotros),
  indicativeImperfectEllos(
      SearchMoodTense.indicativeImperfect, SearchSubject.ellos),
  indicativeFutureYo(SearchMoodTense.indicativeFuture, SearchSubject.yo),
  indicativeFutureTu(SearchMoodTense.indicativeFuture, SearchSubject.tu),
  indicativeFutureEl(SearchMoodTense.indicativeFuture, SearchSubject.el),
  indicativeFutureNosotros(
      SearchMoodTense.indicativeFuture, SearchSubject.nosotros),
  indicativeFutureVosotros(
      SearchMoodTense.indicativeFuture, SearchSubject.vosotros),
  indicativeFutureEllos(SearchMoodTense.indicativeFuture, SearchSubject.ellos),
  indicativeConditionalYo(
      SearchMoodTense.indicativeConditional, SearchSubject.yo),
  indicativeConditionalTu(
      SearchMoodTense.indicativeConditional, SearchSubject.tu),
  indicativeConditionalEl(
      SearchMoodTense.indicativeConditional, SearchSubject.el),
  indicativeConditionalNosotros(
      SearchMoodTense.indicativeConditional, SearchSubject.nosotros),
  indicativeConditionalVosotros(
      SearchMoodTense.indicativeConditional, SearchSubject.vosotros),
  indicativeConditionalEllos(
      SearchMoodTense.indicativeConditional, SearchSubject.ellos),
  imperativeTu(SearchMoodTense.imperative, SearchSubject.tu),
  imperativeEl(SearchMoodTense.imperative, SearchSubject.el),
  imperativeNosotros(SearchMoodTense.imperative, SearchSubject.nosotros),
  imperativeVosotros(SearchMoodTense.imperative, SearchSubject.vosotros),
  imperativeEllos(SearchMoodTense.imperative, SearchSubject.ellos),
  subjunctivePresentYo(SearchMoodTense.subjunctivePresent, SearchSubject.yo),
  subjunctivePresentTu(SearchMoodTense.subjunctivePresent, SearchSubject.tu),
  subjunctivePresentEl(SearchMoodTense.subjunctivePresent, SearchSubject.el),
  subjunctivePresentNosotros(
      SearchMoodTense.subjunctivePresent, SearchSubject.nosotros),
  subjunctivePresentVosotros(
      SearchMoodTense.subjunctivePresent, SearchSubject.vosotros),
  subjunctivePresentEllos(
      SearchMoodTense.subjunctivePresent, SearchSubject.ellos),
  subjunctivePastYo(SearchMoodTense.subjunctivePast, SearchSubject.yo),
  subjunctivePastTu(SearchMoodTense.subjunctivePast, SearchSubject.tu),
  subjunctivePastEl(SearchMoodTense.subjunctivePast, SearchSubject.el),
  subjunctivePastNosotros(
      SearchMoodTense.subjunctivePast, SearchSubject.nosotros),
  subjunctivePastVosotros(
      SearchMoodTense.subjunctivePast, SearchSubject.vosotros),
  subjunctivePastEllos(SearchMoodTense.subjunctivePast, SearchSubject.ellos);

  const SearchConjugationMatchKey(this.moodTense, this.subject);
  final SearchMoodTense moodTense;
  final SearchSubject subject;
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
  subjunctivePast
}

enum SearchSubject { yo, tu, el, nosotros, vosotros, ellos }
