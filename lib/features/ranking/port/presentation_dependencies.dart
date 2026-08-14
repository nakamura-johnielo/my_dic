import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';

/// App-owned dependencies for Ranking's controlled Flutter entry.
final class RankingPresentationDependencies {
  const RankingPresentationDependencies({
    required this.ports,
  });

  final RankingPorts ports;
}

final rankingPresentationDependenciesProvider =
    Provider<RankingPresentationDependencies>(
  (_) => throw StateError(
    'Ranking presentation dependencies were not supplied.',
  ),
);
