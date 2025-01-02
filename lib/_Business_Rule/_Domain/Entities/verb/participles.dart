import 'package:freezed_annotation/freezed_annotation.dart';

// 生成されるdartファイルを記述
part '../../../../__generated/_Business_Rule/_Domain/Entities/verb/participles.freezed.dart';

@freezed
class Participles with _$Participles {
  // プロパティを指定
  const factory Participles({
    required String present,
    required String past,
    // デフォルト値は「@Default([デフォルト値]])」の形式で指定可能
  }) = _Participles;
}
