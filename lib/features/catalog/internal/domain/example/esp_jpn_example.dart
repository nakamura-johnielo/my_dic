import 'package:my_dic/features/catalog/internal/domain/example/catalog_example.dart';

class EspJpnExample implements IExample {
  @override
  final int exampleId;
  @override
  final String japanese;
  @override
  final String espanol;

  const EspJpnExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
  });

  EspJpnExample copyWith({int? exampleId, String? japanese, String? espanol}) {
    return EspJpnExample(
      exampleId: exampleId ?? this.exampleId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
    );
  }
}
