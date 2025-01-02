import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/i_idiom.dart';
part '../../../../../../../__generated/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/solo_idiom.freezed.dart';

@freezed
class SoloIdiom with _$SoloIdiom implements IIdiom {
  const factory SoloIdiom({
    required int idiomId,
    required String idiom,
    required String description,
  }) = _SoloIdiom;
}
