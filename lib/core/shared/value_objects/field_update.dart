sealed class FieldUpdate<T> {
  const FieldUpdate();

  const factory FieldUpdate.unchanged() = Unchanged<T>;
  const factory FieldUpdate.set(T value) = SetValue<T>;

  bool get isChanged => this is SetValue<T>;
}

final class Unchanged<T> extends FieldUpdate<T> {
  const Unchanged();
}

final class SetValue<T> extends FieldUpdate<T> {
  const SetValue(this.value);

  final T value;
}
