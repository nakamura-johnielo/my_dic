enum WebDBLoadingType{
  download,
  decompressed,
  parsing,
  import
}


extension WebDBLoadingTypeExtension on WebDBLoadingType {
  String get name {
    switch (this) {
      case WebDBLoadingType.download:
        return 'DBデータのダウンロード';
      case WebDBLoadingType.decompressed:
        return 'データの解凍';
      case WebDBLoadingType.parsing:
        return 'jsonDecode (パース)';
      case WebDBLoadingType.import:
        return 'IndexDBの初期化 (インポート)';
        
    }
  }
}