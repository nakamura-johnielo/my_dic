// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../../../../_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/solo_idiom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SoloIdiom {
  int get idiomId => throw _privateConstructorUsedError;
  String get idiom => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Create a copy of SoloIdiom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SoloIdiomCopyWith<SoloIdiom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoloIdiomCopyWith<$Res> {
  factory $SoloIdiomCopyWith(SoloIdiom value, $Res Function(SoloIdiom) then) =
      _$SoloIdiomCopyWithImpl<$Res, SoloIdiom>;
  @useResult
  $Res call({int idiomId, String idiom, String description});
}

/// @nodoc
class _$SoloIdiomCopyWithImpl<$Res, $Val extends SoloIdiom>
    implements $SoloIdiomCopyWith<$Res> {
  _$SoloIdiomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SoloIdiom
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
abstract class _$$SoloIdiomImplCopyWith<$Res>
    implements $SoloIdiomCopyWith<$Res> {
  factory _$$SoloIdiomImplCopyWith(
          _$SoloIdiomImpl value, $Res Function(_$SoloIdiomImpl) then) =
      __$$SoloIdiomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int idiomId, String idiom, String description});
}

/// @nodoc
class __$$SoloIdiomImplCopyWithImpl<$Res>
    extends _$SoloIdiomCopyWithImpl<$Res, _$SoloIdiomImpl>
    implements _$$SoloIdiomImplCopyWith<$Res> {
  __$$SoloIdiomImplCopyWithImpl(
      _$SoloIdiomImpl _value, $Res Function(_$SoloIdiomImpl) _then)
      : super(_value, _then);

  /// Create a copy of SoloIdiom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idiomId = null,
    Object? idiom = null,
    Object? description = null,
  }) {
    return _then(_$SoloIdiomImpl(
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

class _$SoloIdiomImpl implements _SoloIdiom {
  const _$SoloIdiomImpl(
      {required this.idiomId, required this.idiom, required this.description});

  @override
  final int idiomId;
  @override
  final String idiom;
  @override
  final String description;

  @override
  String toString() {
    return 'SoloIdiom(idiomId: $idiomId, idiom: $idiom, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoloIdiomImpl &&
            (identical(other.idiomId, idiomId) || other.idiomId == idiomId) &&
            (identical(other.idiom, idiom) || other.idiom == idiom) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode => Object.hash(runtimeType, idiomId, idiom, description);

  /// Create a copy of SoloIdiom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SoloIdiomImplCopyWith<_$SoloIdiomImpl> get copyWith =>
      __$$SoloIdiomImplCopyWithImpl<_$SoloIdiomImpl>(this, _$identity);
}

abstract class _SoloIdiom implements SoloIdiom {
  const factory _SoloIdiom(
      {required final int idiomId,
      required final String idiom,
      required final String description}) = _$SoloIdiomImpl;

  @override
  int get idiomId;
  @override
  String get idiom;
  @override
  String get description;

  /// Create a copy of SoloIdiom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SoloIdiomImplCopyWith<_$SoloIdiomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
