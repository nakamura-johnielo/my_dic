// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../_Business_Rule/_Domain/Entities/word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Word {
  int get wordId => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  List<PartOfSpeech> get partOfSpeech => throw _privateConstructorUsedError;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordCopyWith<Word> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordCopyWith<$Res> {
  factory $WordCopyWith(Word value, $Res Function(Word) then) =
      _$WordCopyWithImpl<$Res, Word>;
  @useResult
  $Res call({int wordId, String word, List<PartOfSpeech> partOfSpeech});
}

/// @nodoc
class _$WordCopyWithImpl<$Res, $Val extends Word>
    implements $WordCopyWith<$Res> {
  _$WordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? partOfSpeech = null,
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
      partOfSpeech: null == partOfSpeech
          ? _value.partOfSpeech
          : partOfSpeech // ignore: cast_nullable_to_non_nullable
              as List<PartOfSpeech>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WordImplCopyWith<$Res> implements $WordCopyWith<$Res> {
  factory _$$WordImplCopyWith(
          _$WordImpl value, $Res Function(_$WordImpl) then) =
      __$$WordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int wordId, String word, List<PartOfSpeech> partOfSpeech});
}

/// @nodoc
class __$$WordImplCopyWithImpl<$Res>
    extends _$WordCopyWithImpl<$Res, _$WordImpl>
    implements _$$WordImplCopyWith<$Res> {
  __$$WordImplCopyWithImpl(_$WordImpl _value, $Res Function(_$WordImpl) _then)
      : super(_value, _then);

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wordId = null,
    Object? word = null,
    Object? partOfSpeech = null,
  }) {
    return _then(_$WordImpl(
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      partOfSpeech: null == partOfSpeech
          ? _value._partOfSpeech
          : partOfSpeech // ignore: cast_nullable_to_non_nullable
              as List<PartOfSpeech>,
    ));
  }
}

/// @nodoc

class _$WordImpl extends _Word {
  const _$WordImpl(
      {required this.wordId,
      required this.word,
      required final List<PartOfSpeech> partOfSpeech})
      : _partOfSpeech = partOfSpeech,
        super._();

  @override
  final int wordId;
  @override
  final String word;
  final List<PartOfSpeech> _partOfSpeech;
  @override
  List<PartOfSpeech> get partOfSpeech {
    if (_partOfSpeech is EqualUnmodifiableListView) return _partOfSpeech;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_partOfSpeech);
  }

  @override
  String toString() {
    return 'Word(wordId: $wordId, word: $word, partOfSpeech: $partOfSpeech)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordImpl &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.word, word) || other.word == word) &&
            const DeepCollectionEquality()
                .equals(other._partOfSpeech, _partOfSpeech));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId, word,
      const DeepCollectionEquality().hash(_partOfSpeech));

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      __$$WordImplCopyWithImpl<_$WordImpl>(this, _$identity);
}

abstract class _Word extends Word {
  const factory _Word(
      {required final int wordId,
      required final String word,
      required final List<PartOfSpeech> partOfSpeech}) = _$WordImpl;
  const _Word._() : super._();

  @override
  int get wordId;
  @override
  String get word;
  @override
  List<PartOfSpeech> get partOfSpeech;

  /// Create a copy of Word
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordImplCopyWith<_$WordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
