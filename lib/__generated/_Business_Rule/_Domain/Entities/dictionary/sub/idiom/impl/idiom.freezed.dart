// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../../../../_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/idiom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Idiom {
  int get idiomId => throw _privateConstructorUsedError;
  String get idiom => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Create a copy of Idiom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdiomCopyWith<Idiom> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdiomCopyWith<$Res> {
  factory $IdiomCopyWith(Idiom value, $Res Function(Idiom) then) =
      _$IdiomCopyWithImpl<$Res, Idiom>;
  @useResult
  $Res call({int idiomId, String idiom, String description});
}

/// @nodoc
class _$IdiomCopyWithImpl<$Res, $Val extends Idiom>
    implements $IdiomCopyWith<$Res> {
  _$IdiomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Idiom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idiomId = null,
    Object? idiom = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      idiomId: null == idiomId
          ? _value.idiomId
          : idiomId // ignore: cast_nullable_to_non_nullable
              as int,
      idiom: null == idiom
          ? _value.idiom
          : idiom // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdiomImplCopyWith<$Res> implements $IdiomCopyWith<$Res> {
  factory _$$IdiomImplCopyWith(
          _$IdiomImpl value, $Res Function(_$IdiomImpl) then) =
      __$$IdiomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int idiomId, String idiom, String description});
}

/// @nodoc
class __$$IdiomImplCopyWithImpl<$Res>
    extends _$IdiomCopyWithImpl<$Res, _$IdiomImpl>
    implements _$$IdiomImplCopyWith<$Res> {
  __$$IdiomImplCopyWithImpl(
      _$IdiomImpl _value, $Res Function(_$IdiomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Idiom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idiomId = null,
    Object? idiom = null,
    Object? description = null,
  }) {
    return _then(_$IdiomImpl(
      idiomId: null == idiomId
          ? _value.idiomId
          : idiomId // ignore: cast_nullable_to_non_nullable
              as int,
      idiom: null == idiom
          ? _value.idiom
          : idiom // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IdiomImpl implements _Idiom {
  const _$IdiomImpl(
      {required this.idiomId, required this.idiom, required this.description});

  @override
  final int idiomId;
  @override
  final String idiom;
  @override
  final String description;

  @override
  String toString() {
    return 'Idiom(idiomId: $idiomId, idiom: $idiom, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdiomImpl &&
            (identical(other.idiomId, idiomId) || other.idiomId == idiomId) &&
            (identical(other.idiom, idiom) || other.idiom == idiom) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, idiomId, idiom, description);

  /// Create a copy of Idiom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdiomImplCopyWith<_$IdiomImpl> get copyWith =>
      __$$IdiomImplCopyWithImpl<_$IdiomImpl>(this, _$identity);
}

abstract class _Idiom implements Idiom {
  const factory _Idiom(
      {required final int idiomId,
      required final String idiom,
      required final String description}) = _$IdiomImpl;

  @override
  int get idiomId;
  @override
  String get idiom;
  @override
  String get description;

  /// Create a copy of Idiom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdiomImplCopyWith<_$IdiomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
