// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../../../../_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/solo_example.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SoloExample {
  int get exampleId => throw _privateConstructorUsedError;
  int get dictionaryId => throw _privateConstructorUsedError;
  String get japanese => throw _privateConstructorUsedError;
  String get espanol => throw _privateConstructorUsedError;

  /// Create a copy of SoloExample
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SoloExampleCopyWith<SoloExample> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoloExampleCopyWith<$Res> {
  factory $SoloExampleCopyWith(
          SoloExample value, $Res Function(SoloExample) then) =
      _$SoloExampleCopyWithImpl<$Res, SoloExample>;
  @useResult
  $Res call({int exampleId, int dictionaryId, String japanese, String espanol});
}

/// @nodoc
class _$SoloExampleCopyWithImpl<$Res, $Val extends SoloExample>
    implements $SoloExampleCopyWith<$Res> {
  _$SoloExampleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SoloExample
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exampleId = null,
    Object? dictionaryId = null,
    Object? japanese = null,
    Object? espanol = null,
  }) {
    return _then(_value.copyWith(
      exampleId: null == exampleId
          ? _value.exampleId
          : exampleId // ignore: cast_nullable_to_non_nullable
              as int,
      dictionaryId: null == dictionaryId
          ? _value.dictionaryId
          : dictionaryId // ignore: cast_nullable_to_non_nullable
              as int,
      japanese: null == japanese
          ? _value.japanese
          : japanese // ignore: cast_nullable_to_non_nullable
              as String,
      espanol: null == espanol
          ? _value.espanol
          : espanol // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SoloExampleImplCopyWith<$Res>
    implements $SoloExampleCopyWith<$Res> {
  factory _$$SoloExampleImplCopyWith(
          _$SoloExampleImpl value, $Res Function(_$SoloExampleImpl) then) =
      __$$SoloExampleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int exampleId, int dictionaryId, String japanese, String espanol});
}

/// @nodoc
class __$$SoloExampleImplCopyWithImpl<$Res>
    extends _$SoloExampleCopyWithImpl<$Res, _$SoloExampleImpl>
    implements _$$SoloExampleImplCopyWith<$Res> {
  __$$SoloExampleImplCopyWithImpl(
      _$SoloExampleImpl _value, $Res Function(_$SoloExampleImpl) _then)
      : super(_value, _then);

  /// Create a copy of SoloExample
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exampleId = null,
    Object? dictionaryId = null,
    Object? japanese = null,
    Object? espanol = null,
  }) {
    return _then(_$SoloExampleImpl(
      exampleId: null == exampleId
          ? _value.exampleId
          : exampleId // ignore: cast_nullable_to_non_nullable
              as int,
      dictionaryId: null == dictionaryId
          ? _value.dictionaryId
          : dictionaryId // ignore: cast_nullable_to_non_nullable
              as int,
      japanese: null == japanese
          ? _value.japanese
          : japanese // ignore: cast_nullable_to_non_nullable
              as String,
      espanol: null == espanol
          ? _value.espanol
          : espanol // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SoloExampleImpl implements _SoloExample {
  const _$SoloExampleImpl(
      {required this.exampleId,
      required this.dictionaryId,
      required this.japanese,
      required this.espanol});

  @override
  final int exampleId;
  @override
  final int dictionaryId;
  @override
  final String japanese;
  @override
  final String espanol;

  @override
  String toString() {
    return 'SoloExample(exampleId: $exampleId, dictionaryId: $dictionaryId, japanese: $japanese, espanol: $espanol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoloExampleImpl &&
            (identical(other.exampleId, exampleId) ||
                other.exampleId == exampleId) &&
            (identical(other.dictionaryId, dictionaryId) ||
                other.dictionaryId == dictionaryId) &&
            (identical(other.japanese, japanese) ||
                other.japanese == japanese) &&
            (identical(other.espanol, espanol) || other.espanol == espanol));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, exampleId, dictionaryId, japanese, espanol);

  /// Create a copy of SoloExample
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SoloExampleImplCopyWith<_$SoloExampleImpl> get copyWith =>
      __$$SoloExampleImplCopyWithImpl<_$SoloExampleImpl>(this, _$identity);
}

abstract class _SoloExample implements SoloExample {
  const factory _SoloExample(
      {required final int exampleId,
      required final int dictionaryId,
      required final String japanese,
      required final String espanol}) = _$SoloExampleImpl;

  @override
  int get exampleId;
  @override
  int get dictionaryId;
  @override
  String get japanese;
  @override
  String get espanol;

  /// Create a copy of SoloExample
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SoloExampleImplCopyWith<_$SoloExampleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
