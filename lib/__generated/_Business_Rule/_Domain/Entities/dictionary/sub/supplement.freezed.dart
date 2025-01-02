// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../../_Business_Rule/_Domain/Entities/dictionary/sub/supplement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Supplement {
  int get supplementId => throw _privateConstructorUsedError;
  String get supplement => throw _privateConstructorUsedError;

  /// Create a copy of Supplement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplementCopyWith<Supplement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplementCopyWith<$Res> {
  factory $SupplementCopyWith(
          Supplement value, $Res Function(Supplement) then) =
      _$SupplementCopyWithImpl<$Res, Supplement>;
  @useResult
  $Res call({int supplementId, String supplement});
}

/// @nodoc
class _$SupplementCopyWithImpl<$Res, $Val extends Supplement>
    implements $SupplementCopyWith<$Res> {
  _$SupplementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Supplement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supplementId = null,
    Object? supplement = null,
  }) {
    return _then(_value.copyWith(
      supplementId: null == supplementId
          ? _value.supplementId
          : supplementId // ignore: cast_nullable_to_non_nullable
              as int,
      supplement: null == supplement
          ? _value.supplement
          : supplement // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplementImplCopyWith<$Res>
    implements $SupplementCopyWith<$Res> {
  factory _$$SupplementImplCopyWith(
          _$SupplementImpl value, $Res Function(_$SupplementImpl) then) =
      __$$SupplementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int supplementId, String supplement});
}

/// @nodoc
class __$$SupplementImplCopyWithImpl<$Res>
    extends _$SupplementCopyWithImpl<$Res, _$SupplementImpl>
    implements _$$SupplementImplCopyWith<$Res> {
  __$$SupplementImplCopyWithImpl(
      _$SupplementImpl _value, $Res Function(_$SupplementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Supplement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supplementId = null,
    Object? supplement = null,
  }) {
    return _then(_$SupplementImpl(
      supplementId: null == supplementId
          ? _value.supplementId
          : supplementId // ignore: cast_nullable_to_non_nullable
              as int,
      supplement: null == supplement
          ? _value.supplement
          : supplement // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SupplementImpl implements _Supplement {
  const _$SupplementImpl(
      {required this.supplementId, required this.supplement});

  @override
  final int supplementId;
  @override
  final String supplement;

  @override
  String toString() {
    return 'Supplement(supplementId: $supplementId, supplement: $supplement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplementImpl &&
            (identical(other.supplementId, supplementId) ||
                other.supplementId == supplementId) &&
            (identical(other.supplement, supplement) ||
                other.supplement == supplement));
  }

  @override
  int get hashCode => Object.hash(runtimeType, supplementId, supplement);

  /// Create a copy of Supplement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplementImplCopyWith<_$SupplementImpl> get copyWith =>
      __$$SupplementImplCopyWithImpl<_$SupplementImpl>(this, _$identity);
}

abstract class _Supplement implements Supplement {
  const factory _Supplement(
      {required final int supplementId,
      required final String supplement}) = _$SupplementImpl;

  @override
  int get supplementId;
  @override
  String get supplement;

  /// Create a copy of Supplement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplementImplCopyWith<_$SupplementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
