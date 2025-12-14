import 'package:flutter/foundation.dart';

@immutable
class Participles {
  final String present;
  final String past;

  const Participles({
    required this.present,
    required this.past,
  });

  Participles copyWith({
    String? present,
    String? past,
  }) {
    return Participles(
      present: present ?? this.present,
      past: past ?? this.past,
    );
  }
}
