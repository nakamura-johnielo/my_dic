/// 一度だけ実行するUI指示。エフェクトは永続的な画面状態とは分離されます。
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

/// 一度だけ消費するための安定したIDを持つワンショットエフェクト。
class UiEffectEnvelope<E extends UiEffect> {
  const UiEffectEnvelope({required this.id, required this.effect});

  final String id;
  final E effect;
}

/// 保留中のワンショットエフェクトがある際にViewModelが公開する契約。
///
/// リスナーは [pendingEffect] を処理し、その後同じIDで [consumeEffect] を呼び出します。
/// 古いIDを消費した際も、実装は新しいエフェクトをそのまま残す必要があります。
abstract interface class UiEffectConsumer {
  UiEffectEnvelope<UiEffect>? get pendingEffect;

  void consumeEffect(String id);
}

/// [effect] が [id] に対して現在保留中のものかを返します。
///
/// この小さなヘルパーにより、エフェクト状態を不変に保つViewModelで古いリスナーを防ぐ
/// ガードを明示できます。
bool shouldConsumeEffect({
  required UiEffectEnvelope<UiEffect>? pendingEffect,
  required String id,
}) =>
    pendingEffect?.id == id;
