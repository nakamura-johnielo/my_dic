import 'package:my_dic/features/catalog/internal/domain/idiom/catalog_idiom.dart';

class Idiom implements CatalogIdiom {
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

  Idiom copyWith({int? idiomId, String? idiom, String? description}) {
    return Idiom(
      idiomId: idiomId ?? this.idiomId,
      idiom: idiom ?? this.idiom,
      description: description ?? this.description,
    );
  }
}
