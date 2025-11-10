// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_dictionary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$JpnEspDictionary {
  int get id => throw _privateConstructorUsedError;
  int get wordId => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  String? get headword => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  List<JpnEspExampleWith>? get examples => throw _privateConstructorUsedError;

  /// Create a copy of JpnEspDictionary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JpnEspDictionaryCopyWith<JpnEspDictionary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JpnEspDictionaryCopyWith<$Res> {
  factory $JpnEspDictionaryCopyWith(
          JpnEspDictionary value, $Res Function(JpnEspDictionary) then) =
      _$JpnEspDictionaryCopyWithImpl<$Res, JpnEspDictionary>;
  @useResult
  $Res call(
      {int id,
      int wordId,
      String word,
      String? headword,
      String? content,
      List<JpnEspExampleWith>? examples});
}

/// @nodoc
class _$JpnEspDictionaryCopyWithImpl<$Res, $Val extends JpnEspDictionary>
    implements $JpnEspDictionaryCopyWith<$Res> {
  _$JpnEspDictionaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JpnEspDictionary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordId = null,
    Object? word = null,
    Object? headword = freezed,
    Object? content = freezed,
    Object? examples = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      headword: freezed == headword
          ? _value.headword
          : headword // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: freezed == examples
          ? _value.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<JpnEspExampleWith>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JpnEspDictionaryImplCopyWith<$Res>
    implements $JpnEspDictionaryCopyWith<$Res> {
  factory _$$JpnEspDictionaryImplCopyWith(_$JpnEspDictionaryImpl value,
          $Res Function(_$JpnEspDictionaryImpl) then) =
      __$$JpnEspDictionaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int wordId,
      String word,
      String? headword,
      String? content,
      List<JpnEspExampleWith>? examples});
}

/// @nodoc
class __$$JpnEspDictionaryImplCopyWithImpl<$Res>
    extends _$JpnEspDictionaryCopyWithImpl<$Res, _$JpnEspDictionaryImpl>
    implements _$$JpnEspDictionaryImplCopyWith<$Res> {
  __$$JpnEspDictionaryImplCopyWithImpl(_$JpnEspDictionaryImpl _value,
      $Res Function(_$JpnEspDictionaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of JpnEspDictionary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wordId = null,
    Object? word = null,
    Object? headword = freezed,
    Object? content = freezed,
    Object? examples = freezed,
  }) {
    return _then(_$JpnEspDictionaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      headword: freezed == headword
          ? _value.headword
          : headword // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: freezed == examples
          ? _value._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<JpnEspExampleWith>?,
    ));
  }
}

/// @nodoc

class _$JpnEspDictionaryImpl implements _JpnEspDictionary {
  const _$JpnEspDictionaryImpl(
      {required this.id,
      required this.wordId,
      required this.word,
      this.headword,
      this.content,
      final List<JpnEspExampleWith>? examples})
      : _examples = examples;

  @override
  final int id;
  @override
  final int wordId;
  @override
  final String word;
  @override
  final String? headword;
  @override
  final String? content;
  final List<JpnEspExampleWith>? _examples;
  @override
  List<JpnEspExampleWith>? get examples {
    final value = _examples;
    if (value == null) return null;
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'JpnEspDictionary(id: $id, wordId: $wordId, word: $word, headword: $headword, content: $content, examples: $examples)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JpnEspDictionaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.headword, headword) ||
                other.headword == headword) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._examples, _examples));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, wordId, word, headword,
      content, const DeepCollectionEquality().hash(_examples));

  /// Create a copy of JpnEspDictionary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JpnEspDictionaryImplCopyWith<_$JpnEspDictionaryImpl> get copyWith =>
      __$$JpnEspDictionaryImplCopyWithImpl<_$JpnEspDictionaryImpl>(
          this, _$identity);
}

abstract class _JpnEspDictionary implements JpnEspDictionary {
  const factory _JpnEspDictionary(
      {required final int id,
      required final int wordId,
      required final String word,
      final String? headword,
      final String? content,
      final List<JpnEspExampleWith>? examples}) = _$JpnEspDictionaryImpl;

  @override
  int get id;
  @override
  int get wordId;
  @override
  String get word;
  @override
  String? get headword;
  @override
  String? get content;
  @override
  List<JpnEspExampleWith>? get examples;

  /// Create a copy of JpnEspDictionary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JpnEspDictionaryImplCopyWith<_$JpnEspDictionaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
