// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../../_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Conjugacions {
//required int conjugacionId,
  int get wordId => throw _privateConstructorUsedError;
  Map<MoodTense, TenseConjugacion> get conjugacions =>
      throw _privateConstructorUsedError;

  /// Create a copy of Conjugacions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConjugacionsCopyWith<Conjugacions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConjugacionsCopyWith<$Res> {
  factory $ConjugacionsCopyWith(
          Conjugacions value, $Res Function(Conjugacions) then) =
      _$ConjugacionsCopyWithImpl<$Res, Conjugacions>;
  @useResult
  $Res call({int wordId, Map<MoodTense, TenseConjugacion> conjugacions});
}

/// @nodoc
class _$ConjugacionsCopyWithImpl<$Res, $Val extends Conjugacions>
    implements $ConjugacionsCopyWith<$Res> {
  _$ConjugacionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conjugacions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? conjugacions = null,
  }) {
    return _then(_value.copyWith(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      conjugacions: null == conjugacions
          ? _value.conjugacions
          : conjugacions // ignore: cast_nullable_to_non_nullable
              as Map<MoodTense, TenseConjugacion>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConjugacionsImplCopyWith<$Res>
    implements $ConjugacionsCopyWith<$Res> {
  factory _$$ConjugacionsImplCopyWith(
          _$ConjugacionsImpl value, $Res Function(_$ConjugacionsImpl) then) =
      __$$ConjugacionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int wordId, Map<MoodTense, TenseConjugacion> conjugacions});
}

/// @nodoc
class __$$ConjugacionsImplCopyWithImpl<$Res>
    extends _$ConjugacionsCopyWithImpl<$Res, _$ConjugacionsImpl>
    implements _$$ConjugacionsImplCopyWith<$Res> {
  __$$ConjugacionsImplCopyWithImpl(
      _$ConjugacionsImpl _value, $Res Function(_$ConjugacionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conjugacions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? conjugacions = null,
  }) {
    return _then(_$ConjugacionsImpl(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      conjugacions: null == conjugacions
          ? _value._conjugacions
          : conjugacions // ignore: cast_nullable_to_non_nullable
              as Map<MoodTense, TenseConjugacion>,
    ));
  }
}

/// @nodoc

class _$ConjugacionsImpl implements _Conjugacions {
  const _$ConjugacionsImpl(
      {required this.wordId,
      required final Map<MoodTense, TenseConjugacion> conjugacions})
      : _conjugacions = conjugacions;

//required int conjugacionId,
  @override
  final int wordId;
  final Map<MoodTense, TenseConjugacion> _conjugacions;
  @override
  Map<MoodTense, TenseConjugacion> get conjugacions {
    if (_conjugacions is EqualUnmodifiableMapView) return _conjugacions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_conjugacions);
  }

  @override
  String toString() {
    return 'Conjugacions(wordId: $wordId, conjugacions: $conjugacions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConjugacionsImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            const DeepCollectionEquality()
                .equals(other._conjugacions, _conjugacions));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, wordId, const DeepCollectionEquality().hash(_conjugacions));

  /// Create a copy of Conjugacions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConjugacionsImplCopyWith<_$ConjugacionsImpl> get copyWith =>
      __$$ConjugacionsImplCopyWithImpl<_$ConjugacionsImpl>(this, _$identity);
}

abstract class _Conjugacions implements Conjugacions {
  const factory _Conjugacions(
          {required final int wordId,
          required final Map<MoodTense, TenseConjugacion> conjugacions}) =
      _$ConjugacionsImpl;

//required int conjugacionId,
  @override
  int get wordId;
  @override
  Map<MoodTense, TenseConjugacion> get conjugacions;

  /// Create a copy of Conjugacions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConjugacionsImplCopyWith<_$ConjugacionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
