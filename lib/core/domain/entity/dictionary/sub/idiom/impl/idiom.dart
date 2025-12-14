import 'package:flutter/foundation.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/idiom/i_idiom.dart';

@immutable
class Idiom implements IIdiom {
  @override
  final int idiomId;
  @override
  final String idiom;
  @override
  final String description;

  const Idiom({
    required this.idiomId,
    required this.idiom,
    required this.description,
  });

  Idiom copyWith({
    int? idiomId,
    String? idiom,
    String? description,
  }) {
    return Idiom(
      idiomId: idiomId ?? this.idiomId,
      idiom: idiom ?? this.idiom,
      description: description ?? this.description,
    );
  }
}
