// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../../_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EsjDictionary {
  int get dictionaryId => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  String? get headword => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get origin => throw _privateConstructorUsedError;
  List<Example>? get examples => throw _privateConstructorUsedError;
  List<Idiom>? get idioms => throw _privateConstructorUsedError;
  List<Supplement>? get supplements => throw _privateConstructorUsedError;

  /// Create a copy of EsjDictionary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EsjDictionaryCopyWith<EsjDictionary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EsjDictionaryCopyWith<$Res> {
  factory $EsjDictionaryCopyWith(
          EsjDictionary value, $Res Function(EsjDictionary) then) =
      _$EsjDictionaryCopyWithImpl<$Res, EsjDictionary>;
  @useResult
  $Res call(
      {int dictionaryId,
      String word,
      String? headword,
      String? content,
      String? origin,
      List<Example>? examples,
      List<Idiom>? idioms,
      List<Supplement>? supplements});
}

/// @nodoc
class _$EsjDictionaryCopyWithImpl<$Res, $Val extends EsjDictionary>
    implements $EsjDictionaryCopyWith<$Res> {
  _$EsjDictionaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EsjDictionary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dictionaryId = null,
    Object? word = null,
    Object? headword = freezed,
    Object? content = freezed,
    Object? origin = freezed,
    Object? examples = freezed,
    Object? idioms = freezed,
    Object? supplements = freezed,
  }) {
    return _then(_value.copyWith(
      dictionaryId: null == dictionaryId
          ? _value.dictionaryId
          : dictionaryId // ignore: cast_nullable_to_non_nullable
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
      origin: freezed == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: freezed == examples
          ? _value.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>?,
      idioms: freezed == idioms
          ? _value.idioms
          : idioms // ignore: cast_nullable_to_non_nullable
              as List<Idiom>?,
      supplements: freezed == supplements
          ? _value.supplements
          : supplements // ignore: cast_nullable_to_non_nullable
              as List<Supplement>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EsjDictionaryImplCopyWith<$Res>
    implements $EsjDictionaryCopyWith<$Res> {
  factory _$$EsjDictionaryImplCopyWith(
          _$EsjDictionaryImpl value, $Res Function(_$EsjDictionaryImpl) then) =
      __$$EsjDictionaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int dictionaryId,
      String word,
      String? headword,
      String? content,
      String? origin,
      List<Example>? examples,
      List<Idiom>? idioms,
      List<Supplement>? supplements});
}

/// @nodoc
class __$$EsjDictionaryImplCopyWithImpl<$Res>
    extends _$EsjDictionaryCopyWithImpl<$Res, _$EsjDictionaryImpl>
    implements _$$EsjDictionaryImplCopyWith<$Res> {
  __$$EsjDictionaryImplCopyWithImpl(
      _$EsjDictionaryImpl _value, $Res Function(_$EsjDictionaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of EsjDictionary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dictionaryId = null,
    Object? word = null,
    Object? headword = freezed,
    Object? content = freezed,
    Object? origin = freezed,
    Object? examples = freezed,
    Object? idioms = freezed,
    Object? supplements = freezed,
  }) {
    return _then(_$EsjDictionaryImpl(
      dictionaryId: null == dictionaryId
          ? _value.dictionaryId
          : dictionaryId // ignore: cast_nullable_to_non_nullable
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
      origin: freezed == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: freezed == examples
          ? _value._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>?,
      idioms: freezed == idioms
          ? _value._idioms
          : idioms // ignore: cast_nullable_to_non_nullable
              as List<Idiom>?,
      supplements: freezed == supplements
          ? _value._supplements
          : supplements // ignore: cast_nullable_to_non_nullable
              as List<Supplement>?,
    ));
  }
}

/// @nodoc

class _$EsjDictionaryImpl implements _EsjDictionary {
  const _$EsjDictionaryImpl(
      {required this.dictionaryId,
      required this.word,
      this.headword,
      this.content,
      this.origin,
      final List<Example>? examples,
      final List<Idiom>? idioms,
      final List<Supplement>? supplements})
      : _examples = examples,
        _idioms = idioms,
        _supplements = supplements;

  @override
  final int dictionaryId;
  @override
  final String word;
  @override
  final String? headword;
  @override
  final String? content;
  @override
  final String? origin;
  final List<Example>? _examples;
  @override
  List<Example>? get examples {
    final value = _examples;
    if (value == null) return null;
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Idiom>? _idioms;
  @override
  List<Idiom>? get idioms {
    final value = _idioms;
    if (value == null) return null;
    if (_idioms is EqualUnmodifiableListView) return _idioms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Supplement>? _supplements;
  @override
  List<Supplement>? get supplements {
    final value = _supplements;
    if (value == null) return null;
    if (_supplements is EqualUnmodifiableListView) return _supplements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'EsjDictionary(dictionaryId: $dictionaryId, word: $word, headword: $headword, content: $content, origin: $origin, examples: $examples, idioms: $idioms, supplements: $supplements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EsjDictionaryImpl &&
            (identical(other.dictionaryId, dictionaryId) ||
                other.dictionaryId == dictionaryId) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.headword, headword) ||
                other.headword == headword) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.origin, origin) || other.origin == origin) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality().equals(other._idioms, _idioms) &&
            const DeepCollectionEquality()
                .equals(other._supplements, _supplements));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      dictionaryId,
      word,
      headword,
      content,
      origin,
      const DeepCollectionEquality().hash(_examples),
      const DeepCollectionEquality().hash(_idioms),
      const DeepCollectionEquality().hash(_supplements));

  /// Create a copy of EsjDictionary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EsjDictionaryImplCopyWith<_$EsjDictionaryImpl> get copyWith =>
      __$$EsjDictionaryImplCopyWithImpl<_$EsjDictionaryImpl>(this, _$identity);
}

abstract class _EsjDictionary implements EsjDictionary {
  const factory _EsjDictionary(
      {required final int dictionaryId,
      required final String word,
      final String? headword,
      final String? content,
      final String? origin,
      final List<Example>? examples,
      final List<Idiom>? idioms,
      final List<Supplement>? supplements}) = _$EsjDictionaryImpl;

  @override
  int get dictionaryId;
  @override
  String get word;
  @override
  String? get headword;
  @override
  String? get content;
  @override
  String? get origin;
  @override
  List<Example>? get examples;
  @override
  List<Idiom>? get idioms;
  @override
  List<Supplement>? get supplements;

  /// Create a copy of EsjDictionary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EsjDictionaryImplCopyWith<_$EsjDictionaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
