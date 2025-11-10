// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$JpnEspWord {
  int get id => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  bool get isLearned => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  bool get hasNote => throw _privateConstructorUsedError;

  /// Create a copy of JpnEspWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JpnEspWordCopyWith<JpnEspWord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JpnEspWordCopyWith<$Res> {
  factory $JpnEspWordCopyWith(
          JpnEspWord value, $Res Function(JpnEspWord) then) =
      _$JpnEspWordCopyWithImpl<$Res, JpnEspWord>;
  @useResult
  $Res call(
      {int id, String word, bool isLearned, bool isBookmarked, bool hasNote});
}

/// @nodoc
class _$JpnEspWordCopyWithImpl<$Res, $Val extends JpnEspWord>
    implements $JpnEspWordCopyWith<$Res> {
  _$JpnEspWordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JpnEspWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
    Object? hasNote = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNote: null == hasNote
          ? _value.hasNote
          : hasNote // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JpnEspWordImplCopyWith<$Res>
    implements $JpnEspWordCopyWith<$Res> {
  factory _$$JpnEspWordImplCopyWith(
          _$JpnEspWordImpl value, $Res Function(_$JpnEspWordImpl) then) =
      __$$JpnEspWordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, String word, bool isLearned, bool isBookmarked, bool hasNote});
}

/// @nodoc
class __$$JpnEspWordImplCopyWithImpl<$Res>
    extends _$JpnEspWordCopyWithImpl<$Res, _$JpnEspWordImpl>
    implements _$$JpnEspWordImplCopyWith<$Res> {
  __$$JpnEspWordImplCopyWithImpl(
      _$JpnEspWordImpl _value, $Res Function(_$JpnEspWordImpl) _then)
      : super(_value, _then);

  /// Create a copy of JpnEspWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
    Object? hasNote = null,
  }) {
    return _then(_$JpnEspWordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      hasNote: null == hasNote
          ? _value.hasNote
          : hasNote // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$JpnEspWordImpl implements _JpnEspWord {
  const _$JpnEspWordImpl(
      {required this.id,
      required this.word,
      this.isLearned = false,
      this.isBookmarked = false,
      this.hasNote = false});

  @override
  final int id;
  @override
  final String word;
  @override
  @JsonKey()
  final bool isLearned;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  @JsonKey()
  final bool hasNote;

  @override
  String toString() {
    return 'JpnEspWord(id: $id, word: $word, isLearned: $isLearned, isBookmarked: $isBookmarked, hasNote: $hasNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JpnEspWordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.isLearned, isLearned) ||
                other.isLearned == isLearned) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.hasNote, hasNote) || other.hasNote == hasNote));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, word, isLearned, isBookmarked, hasNote);

  /// Create a copy of JpnEspWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JpnEspWordImplCopyWith<_$JpnEspWordImpl> get copyWith =>
      __$$JpnEspWordImplCopyWithImpl<_$JpnEspWordImpl>(this, _$identity);
}

abstract class _JpnEspWord implements JpnEspWord {
  const factory _JpnEspWord(
      {required final int id,
      required final String word,
      final bool isLearned,
      final bool isBookmarked,
      final bool hasNote}) = _$JpnEspWordImpl;

  @override
  int get id;
  @override
  String get word;
  @override
  bool get isLearned;
  @override
  bool get isBookmarked;
  @override
  bool get hasNote;

  /// Create a copy of JpnEspWord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JpnEspWordImplCopyWith<_$JpnEspWordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
