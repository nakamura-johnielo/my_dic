import 'package:flutter/foundation.dart';

@immutable
class Supplement {
  final int supplementId;
  final String supplement;

  const Supplement({
    required this.supplementId,
    required this.supplement,
  });

  Supplement copyWith({
    int? supplementId,
    String? supplement,
  }) {
    return Supplement(
      supplementId: supplementId ?? this.supplementId,
      supplement: supplement ?? this.supplement,
    );
  }
}
