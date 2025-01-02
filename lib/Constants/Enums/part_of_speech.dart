enum PartOfSpeech {
  noun,
  abbreviation,
  preposition,
  prefix,
  adjective,
  verb,
  adverb,
  interjection,
  participle,
  pronoun,
  conjunction,
  article,
  auxiliaryVerb
}

extension PartOfSpeechExtension on PartOfSpeech {
  String get name {
    switch (this) {
      case PartOfSpeech.noun:
        return '名詞';
      case PartOfSpeech.abbreviation:
        return '略語';
      case PartOfSpeech.preposition:
        return '前置詞';
      case PartOfSpeech.prefix:
        return '接辞';
      case PartOfSpeech.adjective:
        return '形容詞';
      case PartOfSpeech.verb:
        return '動詞';
      case PartOfSpeech.adverb:
        return '副詞';
      case PartOfSpeech.interjection:
        return '間投詞';
      case PartOfSpeech.participle:
        return '分詞';
      case PartOfSpeech.pronoun:
        return '代名詞';
      case PartOfSpeech.conjunction:
        return '接続詞';
      case PartOfSpeech.article:
        return '冠詞';
      case PartOfSpeech.auxiliaryVerb:
        return '助動詞';
    }
  }
}

/* void main() {
  PartOfSpeech pos = PartOfSpeech.noun;
  print(pos.name); // 出力: 名詞
}
 */


/* 
名詞       Noun
略語       Abbreviation
前置詞     Preposition
接辞       Prefix
形容詞     Adjective
動詞       Verb
null       Null
副詞       Adverb
間投詞     Interjection
分詞       Participle
代名詞     Pronoun
接続詞     Conjunction
冠詞       Article
助動詞     Auxiliary Verb  
 */