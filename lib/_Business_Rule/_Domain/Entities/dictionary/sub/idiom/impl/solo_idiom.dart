import 'package:flutter/foundation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/i_idiom.dart';

@immutable
class SoloIdiom implements IIdiom {
  @override
  final int idiomId;
  @override
  final String idiom;
  @override
  final String description;

  const SoloIdiom({
    required this.idiomId,
    required this.idiom,
    required this.description,
  });

  SoloIdiom copyWith({
    int? idiomId,
    String? idiom,
    String? description,
  }) {
    return SoloIdiom(
      idiomId: idiomId ?? this.idiomId,
      idiom: idiom ?? this.idiom,
      description: description ?? this.description,
    );
  }
}
