/* 
直接法      Indicative
  現在        Present
  点過去      Preterite
  線過去      Imperfect
  未来        Future
  過去未来    Conditional
        
命令        Imperative

接続法      Subjunctive
  現在        present
  過去        past
 */

enum MoodTense {
  participlePresent,
  participlePast,
  indicativePresent, // 直接法現在
  indicativePreterite, // 直接法点過去
  indicativeImperfect, // 直接法線過去
  indicativeFuture, // 直接法未来
  indicativeConditional, // 直接法過去未来
  imperative, // 命令
  subjunctivePresent, // 接続法現在
  subjunctivePast // 接続法過去
}

extension MoodTenseExtension on MoodTense {
  String get jap {
    switch (this) {
      case MoodTense.participlePresent:
        return '現在分詞';
      case MoodTense.participlePast:
        return '過去分詞';
      case MoodTense.indicativePresent:
        return '直接法現在';
      case MoodTense.indicativePreterite:
        return '直接法点過去';
      case MoodTense.indicativeImperfect:
        return '直接法線過去';
      case MoodTense.indicativeFuture:
        return '直接法未来';
      case MoodTense.indicativeConditional:
        return '直接法過去未来';
      case MoodTense.imperative:
        return '命令';
      case MoodTense.subjunctivePresent:
        return '接続法現在';
      case MoodTense.subjunctivePast:
        return '接続法過去';
    }
  }
}

extension MoodTenseDBColExtension on MoodTense {
  String get column {
    switch (this) {
      case MoodTense.participlePresent:
        return 'present_participle';
      case MoodTense.participlePast:
        return 'past_participle';
      case MoodTense.indicativePresent:
        return 'indicative_present';
      case MoodTense.indicativePreterite:
        return 'indicative_preterite';
      case MoodTense.indicativeImperfect:
        return 'indicative_imperfect';
      case MoodTense.indicativeFuture:
        return 'indicative_future';
      case MoodTense.indicativeConditional:
        return 'indicative_conditional';
      case MoodTense.imperative:
        return 'imperative';
      case MoodTense.subjunctivePresent:
        return 'subjunctive_present';
      case MoodTense.subjunctivePast:
        return 'subjunctive_past';
    }
  }
}

extension MoodTenseColumnExtension on MoodTense {
  String get shorten {
    switch (this) {
      case MoodTense.participlePresent:
        return '現分';
      case MoodTense.participlePast:
        return '過分';
      case MoodTense.indicativePresent:
        return '直現在';
      case MoodTense.indicativePreterite:
        return '直点過去';
      case MoodTense.indicativeImperfect:
        return '直線過去';
      case MoodTense.indicativeFuture:
        return '直未来';
      case MoodTense.indicativeConditional:
        return '直過去未来';
      case MoodTense.imperative:
        return '命令';
      case MoodTense.subjunctivePresent:
        return '接現在';
      case MoodTense.subjunctivePast:
        return '接過去';
    }
  }
}

extension TenseExtension on MoodTense {
  String get tenseName {
    switch (this) {
      case MoodTense.participlePresent:
        return '現在';
      case MoodTense.participlePast:
        return '過去';
      case MoodTense.indicativePresent:
        return '現在';
      case MoodTense.indicativePreterite:
        return '点過去';
      case MoodTense.indicativeImperfect:
        return '線過去';
      case MoodTense.indicativeFuture:
        return '未来';
      case MoodTense.indicativeConditional:
        return '過去未来';
      case MoodTense.imperative: //!todo 命令はなし？？？
        return '';
      case MoodTense.subjunctivePresent:
        return '現在';
      case MoodTense.subjunctivePast:
        return '過去';
    }
  }
}

extension Mood on MoodTense {
  String get moodName {
    switch (this) {
      case MoodTense.participlePresent:
      case MoodTense.participlePast:
        return '分詞';
      case MoodTense.indicativePresent:
      case MoodTense.indicativePreterite:
      case MoodTense.indicativeImperfect:
      case MoodTense.indicativeFuture:
      case MoodTense.indicativeConditional:
        return '直接法';
      case MoodTense.imperative:
        return '命令法';
      case MoodTense.subjunctivePresent:
      case MoodTense.subjunctivePast:
        return '接続法';
    }
  }
}
