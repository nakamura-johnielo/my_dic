// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../_Business_Rule/_Domain/Entities/my_word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MyWord {
  int get wordId => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  String get contents => throw _privateConstructorUsedError;
  bool get isLearned => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;

  /// Create a copy of MyWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyWordCopyWith<MyWord> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyWordCopyWith<$Res> {
  factory $MyWordCopyWith(MyWord value, $Res Function(MyWord) then) =
      _$MyWordCopyWithImpl<$Res, MyWord>;
  @useResult
  $Res call(
      {int wordId,
      String word,
      String contents,
      bool isLearned,
      bool isBookmarked});
}

/// @nodoc
class _$MyWordCopyWithImpl<$Res, $Val extends MyWord>
    implements $MyWordCopyWith<$Res> {
  _$MyWordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? contents = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
  }) {
    return _then(_value.copyWith(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      contents: null == contents
          ? _value.contents
          : contents // ignore: cast_nullable_to_non_nullable
              as String,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyWordImplCopyWith<$Res> implements $MyWordCopyWith<$Res> {
  factory _$$MyWordImplCopyWith(
          _$MyWordImpl value, $Res Function(_$MyWordImpl) then) =
      __$$MyWordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int wordId,
      String word,
      String contents,
      bool isLearned,
      bool isBookmarked});
}

/// @nodoc
class __$$MyWordImplCopyWithImpl<$Res>
    extends _$MyWordCopyWithImpl<$Res, _$MyWordImpl>
    implements _$$MyWordImplCopyWith<$Res> {
  __$$MyWordImplCopyWithImpl(
      _$MyWordImpl _value, $Res Function(_$MyWordImpl) _then)
      : super(_value, _then);

  /// Create a copy of MyWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? contents = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
  }) {
    return _then(_$MyWordImpl(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      contents: null == contents
          ? _value.contents
          : contents // ignore: cast_nullable_to_non_nullable
              as String,
      isLearned: null == isLearned
          ? _value.isLearned
          : isLearned // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MyWordImpl implements _MyWord {
  const _$MyWordImpl(
      {required this.wordId,
      required this.word,
      required this.contents,
      this.isLearned = false,
      this.isBookmarked = false});

  @override
  final int wordId;
  @override
  final String word;
  @override
  final String contents;
  @override
  @JsonKey()
  final bool isLearned;
  @override
  @JsonKey()
  final bool isBookmarked;

  @override
  String toString() {
    return 'MyWord(wordId: $wordId, word: $word, contents: $contents, isLearned: $isLearned, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyWordImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.contents, contents) ||
                other.contents == contents) &&
            (identical(other.isLearned, isLearned) ||
                other.isLearned == isLearned) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, wordId, word, contents, isLearned, isBookmarked);

  /// Create a copy of MyWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyWordImplCopyWith<_$MyWordImpl> get copyWith =>
      __$$MyWordImplCopyWithImpl<_$MyWordImpl>(this, _$identity);
}

abstract class _MyWord implements MyWord {
  const factory _MyWord(
      {required final int wordId,
      required final String word,
      required final String contents,
      final bool isLearned,
      final bool isBookmarked}) = _$MyWordImpl;

  @override
  int get wordId;
  @override
  String get word;
  @override
  String get contents;
  @override
  bool get isLearned;
  @override
  bool get isBookmarked;

  /// Create a copy of MyWord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyWordImplCopyWith<_$MyWordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
