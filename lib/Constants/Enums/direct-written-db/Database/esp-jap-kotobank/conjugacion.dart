enum ConjugacionsColumns {
  wordId,
  word,
  meaning,
  presentParticiple,
  pastParticiple,

  // 直接法 現在
  tyokuGenzaiYo,
  tyokuGenzaiTu,
  tyokuGenzaiEl,
  tyokuGenzaiNosotros,
  tyokuGenzaiVosotros,
  tyokuGenzaiEllos,

  // 直接法 点過去
  tyokuTenKakoYo,
  tyokuTenKakoTu,
  tyokuTenKakoEl,
  tyokuTenKakoNosotros,
  tyokuTenKakoVosotros,
  tyokuTenKakoEllos,

  // 直接法 線過去
  tyokuSenKakoYo,
  tyokuSenKakoTu,
  tyokuSenKakoEl,
  tyokuSenKakoNosotros,
  tyokuSenKakoVosotros,
  tyokuSenKakoEllos,

  // 直接法 未来
  tyokuMiraiYo,
  tyokuMiraiTu,
  tyokuMiraiEl,
  tyokuMiraiNosotros,
  tyokuMiraiVosotros,
  tyokuMiraiEllos,

  // 直接法 過去未来
  tyokuKakoMiraiYo,
  tyokuKakoMiraiTu,
  tyokuKakoMiraiEl,
  tyokuKakoMiraiNosotros,
  tyokuKakoMiraiVosotros,
  tyokuKakoMiraiEllos,

  // 命令
  meireiTu,
  meireiEl,
  meireiNosotros,
  meireiVosotros,
  meireiEllos,

  // 接続法 現在
  setuGenzaiYo,
  setuGenzaiTu,
  setuGenzaiEl,
  setuGenzaiNosotros,
  setuGenzaiVosotros,
  setuGenzaiEllos,

  // 接続法 過去
  setuKakoYo,
  setuKakoTu,
  setuKakoEl,
  setuKakoNosotros,
  setuKakoVosotros,
  setuKakoEllos,
}

extension ConjugacionsColumnsExtension on ConjugacionsColumns {
  String get description {
    switch (this) {
      case ConjugacionsColumns.wordId:
        return 'word_id';
      case ConjugacionsColumns.word:
        return 'word';
      case ConjugacionsColumns.meaning:
        return 'meaning';
      case ConjugacionsColumns.presentParticiple:
        return '現在分詞';
      case ConjugacionsColumns.pastParticiple:
        return '過去分詞';

      // 直接法 現在
      case ConjugacionsColumns.tyokuGenzaiYo:
        return '直現在yo';
      case ConjugacionsColumns.tyokuGenzaiTu:
        return '直現在tu';
      case ConjugacionsColumns.tyokuGenzaiEl:
        return '直現在el';
      case ConjugacionsColumns.tyokuGenzaiNosotros:
        return '直現在nosotros';
      case ConjugacionsColumns.tyokuGenzaiVosotros:
        return '直現在vosotros';
      case ConjugacionsColumns.tyokuGenzaiEllos:
        return '直現在ellos';

      // 直接法 点過去
      case ConjugacionsColumns.tyokuTenKakoYo:
        return '直点過去yo';
      case ConjugacionsColumns.tyokuTenKakoTu:
        return '直点過去tu';
      case ConjugacionsColumns.tyokuTenKakoEl:
        return '直点過去el';
      case ConjugacionsColumns.tyokuTenKakoNosotros:
        return '直点過去nosotros';
      case ConjugacionsColumns.tyokuTenKakoVosotros:
        return '直点過去vosotros';
      case ConjugacionsColumns.tyokuTenKakoEllos:
        return '直点過去ellos';

      // 直接法 線過去
      case ConjugacionsColumns.tyokuSenKakoYo:
        return '直線過去yo';
      case ConjugacionsColumns.tyokuSenKakoTu:
        return '直線過去tu';
      case ConjugacionsColumns.tyokuSenKakoEl:
        return '直線過去el';
      case ConjugacionsColumns.tyokuSenKakoNosotros:
        return '直線過去nosotros';
      case ConjugacionsColumns.tyokuSenKakoVosotros:
        return '直線過去vosotros';
      case ConjugacionsColumns.tyokuSenKakoEllos:
        return '直線過去ellos';

      // 直接法 未来
      case ConjugacionsColumns.tyokuMiraiYo:
        return '直未来yo';
      case ConjugacionsColumns.tyokuMiraiTu:
        return '直未来tu';
      case ConjugacionsColumns.tyokuMiraiEl:
        return '直未来el';
      case ConjugacionsColumns.tyokuMiraiNosotros:
        return '直未来nosotros';
      case ConjugacionsColumns.tyokuMiraiVosotros:
        return '直未来vosotros';
      case ConjugacionsColumns.tyokuMiraiEllos:
        return '直未来ellos';

      // 直接法 過去未来
      case ConjugacionsColumns.tyokuKakoMiraiYo:
        return '直過去未来yo';
      case ConjugacionsColumns.tyokuKakoMiraiTu:
        return '直過去未来tu';
      case ConjugacionsColumns.tyokuKakoMiraiEl:
        return '直過去未来el';
      case ConjugacionsColumns.tyokuKakoMiraiNosotros:
        return '直過去未来nosotros';
      case ConjugacionsColumns.tyokuKakoMiraiVosotros:
        return '直過去未来vosotros';
      case ConjugacionsColumns.tyokuKakoMiraiEllos:
        return '直過去未来ellos';

      // 命令
      case ConjugacionsColumns.meireiTu:
        return '命令tu';
      case ConjugacionsColumns.meireiEl:
        return '命令el';
      case ConjugacionsColumns.meireiNosotros:
        return '命令nosotros';
      case ConjugacionsColumns.meireiVosotros:
        return '命令vosotros';
      case ConjugacionsColumns.meireiEllos:
        return '命令ellos';

      // 接続法 現在
      case ConjugacionsColumns.setuGenzaiYo:
        return '接現在yo';
      case ConjugacionsColumns.setuGenzaiTu:
        return '接現在tu';
      case ConjugacionsColumns.setuGenzaiEl:
        return '接現在el';
      case ConjugacionsColumns.setuGenzaiNosotros:
        return '接現在nosotros';
      case ConjugacionsColumns.setuGenzaiVosotros:
        return '接現在vosotros';
      case ConjugacionsColumns.setuGenzaiEllos:
        return '接現在ellos';

      // 接続法 過去
      case ConjugacionsColumns.setuKakoYo:
        return '接過去yo';
      case ConjugacionsColumns.setuKakoTu:
        return '接過去tu';
      case ConjugacionsColumns.setuKakoEl:
        return '接過去el';
      case ConjugacionsColumns.setuKakoNosotros:
        return '接過去nosotros';
      case ConjugacionsColumns.setuKakoVosotros:
        return '接過去vosotros';
      case ConjugacionsColumns.setuKakoEllos:
        return '接過去ellos';
    }
  }
}
