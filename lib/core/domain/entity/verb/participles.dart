import 'package:flutter/foundation.dart';

@immutable
class EspParticiples {
  final String present;
  final String past;

  const EspParticiples({
    required this.present,
    required this.past,
  });

  EspParticiples copyWith({
    String? present,
    String? past,
  }) {
    return EspParticiples(
      present: present ?? this.present,
      past: past ?? this.past,
    );
  }
}
