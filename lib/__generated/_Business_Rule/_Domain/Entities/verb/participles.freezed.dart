// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../_Business_Rule/_Domain/Entities/verb/participles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Participles {
  String get present => throw _privateConstructorUsedError;
  String get past => throw _privateConstructorUsedError;

  /// Create a copy of Participles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticiplesCopyWith<Participles> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticiplesCopyWith<$Res> {
  factory $ParticiplesCopyWith(
          Participles value, $Res Function(Participles) then) =
      _$ParticiplesCopyWithImpl<$Res, Participles>;
  @useResult
  $Res call({String present, String past});
}

/// @nodoc
class _$ParticiplesCopyWithImpl<$Res, $Val extends Participles>
    implements $ParticiplesCopyWith<$Res> {
  _$ParticiplesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Participles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? present = null,
    Object? past = null,
  }) {
    return _then(_value.copyWith(
      present: null == present
          ? _value.present
          : present // ignore: cast_nullable_to_non_nullable
              as String,
      past: null == past
          ? _value.past
          : past // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParticiplesImplCopyWith<$Res>
    implements $ParticiplesCopyWith<$Res> {
  factory _$$ParticiplesImplCopyWith(
          _$ParticiplesImpl value, $Res Function(_$ParticiplesImpl) then) =
      __$$ParticiplesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String present, String past});
}

/// @nodoc
class __$$ParticiplesImplCopyWithImpl<$Res>
    extends _$ParticiplesCopyWithImpl<$Res, _$ParticiplesImpl>
    implements _$$ParticiplesImplCopyWith<$Res> {
  __$$ParticiplesImplCopyWithImpl(
      _$ParticiplesImpl _value, $Res Function(_$ParticiplesImpl) _then)
      : super(_value, _then);

  /// Create a copy of Participles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? present = null,
    Object? past = null,
  }) {
    return _then(_$ParticiplesImpl(
      present: null == present
          ? _value.present
          : present // ignore: cast_nullable_to_non_nullable
              as String,
      past: null == past
          ? _value.past
          : past // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ParticiplesImpl implements _Participles {
  const _$ParticiplesImpl({required this.present, required this.past});

  @override
  final String present;
  @override
  final String past;

  @override
  String toString() {
    return 'Participles(present: $present, past: $past)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticiplesImpl &&
            (identical(other.present, present) || other.present == present) &&
            (identical(other.past, past) || other.past == past));
  }

  @override
  int get hashCode => Object.hash(runtimeType, present, past);

  /// Create a copy of Participles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticiplesImplCopyWith<_$ParticiplesImpl> get copyWith =>
      __$$ParticiplesImplCopyWithImpl<_$ParticiplesImpl>(this, _$identity);
}

abstract class _Participles implements Participles {
  const factory _Participles(
      {required final String present,
      required final String past}) = _$ParticiplesImpl;

  @override
  String get present;
  @override
  String get past;

  /// Create a copy of Participles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticiplesImplCopyWith<_$ParticiplesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
