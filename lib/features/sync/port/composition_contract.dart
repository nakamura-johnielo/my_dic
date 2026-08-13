/// Framework-free lookup supplied by an app composition root.
typedef SyncDependencyQueryPort = T Function<T>(Object dependency);

/// Opaque dependency keys. Only app composition maps these to its providers.
final class SyncCompositionDependencies {
  const SyncCompositionDependencies._();

  static const database = _SyncDependency('database');
  static const sessionFence = _SyncDependency('sessionFence');
}

final class _SyncDependency {
  const _SyncDependency(this.name);
  final String name;
}
