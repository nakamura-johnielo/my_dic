/// A one-shot UI instruction. Effects are separate from durable screen state.
sealed class UiEffect {
  const UiEffect();
}

final class UiNoticeEffect extends UiEffect {
  const UiNoticeEffect(this.message);

  final String message;
}

final class UiNavigateEffect extends UiEffect {
  const UiNavigateEffect(this.route);

  final String route;
}

final class UiCloseDialogEffect extends UiEffect {
  const UiCloseDialogEffect();
}

final class UiReloadEffect extends UiEffect {
  const UiReloadEffect();
}

/// A one-shot effect with a stable ID for exactly-once consumption.
class UiEffectEnvelope<E extends UiEffect> {
  const UiEffectEnvelope({required this.id, required this.effect});

  final String id;
  final E effect;
}

/// Contract a ViewModel exposes when it has a pending one-shot effect.
///
/// A listener handles [pendingEffect] and then calls [consumeEffect] with the
/// same ID. Implementations must leave a newer effect in place when an older
/// ID is consumed.
abstract interface class UiEffectConsumer {
  UiEffectEnvelope<UiEffect>? get pendingEffect;

  void consumeEffect(String id);
}

/// Returns whether [effect] is the one currently pending for [id].
///
/// This small helper makes stale-listener guards explicit in ViewModels that
/// keep their effect state immutable.
bool shouldConsumeEffect({
  required UiEffectEnvelope<UiEffect>? pendingEffect,
  required String id,
}) =>
    pendingEffect?.id == id;
