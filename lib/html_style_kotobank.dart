// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

final base = Style(
  lineHeight: LineHeight(1.5),
  margin: Margins.all(0),
  padding: HtmlPaddings.all(0),
);

final meaning = Style(
  margin: Margins.only(top: 10),
);

final supplement = Style(
  margin: Margins.only(top: 0, left: 20),
);

final example = Style(
  margin: Margins.only(top: 0, left: 15),
);

final type_partOfSpeech = Style(
  margin: Margins.only(top: 30, left: 0),
  fontSize: FontSize(18),
);

final headword_saiki = Style(
  margin: Margins.only(top: 30, left: 0),
  fontSize: FontSize(18),
);

final div_idiom = Style(
  margin: Margins.only(top: 20, left: 10),
);

final headword_idiom = Style(
  margin: Margins.only(top: 0, left: 0),
  fontWeight: FontWeight.bold,
);

final meaning_inIdiom = Style(
  margin: Margins.only(top: 0, left: 0),
);
final excf = Style(
  padding: HtmlPaddings.only(bottom: 50),
);

final headword = Style(
    margin: Margins.only(top: 0, left: 0),
    fontWeight: FontWeight.bold,
    fontSize: FontSize(22));

final Map<String, Style> htmlStyles = {
  '*': base,
  ".hw": headword,
  "[data-orgtag=meaning]": meaning,
  "[type=補足]": supplement,
  "[type=' 補足']": supplement,
  "[data-orgtag=example]": example,
  "[type=品詞区分]": type_partOfSpeech,
  "[data-orgtag=subheadword][type=再帰動詞]": headword_saiki,
  "[data-orgtag=subhead][type=成句]": div_idiom,
  "[data-orgtag=subhead][type=' 成句']": div_idiom,
  "[data-orgtag=subheadword][type=成句]": headword_idiom,
  "[data-orgtag=subheadword][type=' 成句']": headword_idiom,
  "div[data-orgtag=subhead][type=' 成句'] p[data-orgtag=meaning]":
      meaning_inIdiom,
  "div[data-orgtag=subhead][type='成句'] p[data-orgtag=meaning]": meaning_inIdiom,
  '.ex.cf': excf,
};
