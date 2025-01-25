// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../../../_Business_Rule/_Domain/Entities/ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Ranking {
  int get rank => throw _privateConstructorUsedError;
  String get rankedWord => throw _privateConstructorUsedError; //ランクに選定されてる形の単語
  String get lemma => throw _privateConstructorUsedError; //原形
  int get wordId => throw _privateConstructorUsedError;
  bool get isLearned => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  bool get hasNote => throw _privateConstructorUsedError;

  /// Create a copy of Ranking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RankingCopyWith<Ranking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RankingCopyWith<$Res> {
  factory $RankingCopyWith(Ranking value, $Res Function(Ranking) then) =
      _$RankingCopyWithImpl<$Res, Ranking>;
  @useResult
  $Res call(
      {int rank,
      String rankedWord,
      String lemma,
      int wordId,
      bool isLearned,
      bool isBookmarked,
      bool hasNote});
}

/// @nodoc
class _$RankingCopyWithImpl<$Res, $Val extends Ranking>
    implements $RankingCopyWith<$Res> {
  _$RankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ranking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? rankedWord = null,
    Object? lemma = null,
    Object? wordId = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
    Object? hasNote = null,
  }) {
    return _then(_value.copyWith(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      rankedWord: null == rankedWord
          ? _value.rankedWord
          : rankedWord // ignore: cast_nullable_to_non_nullable
              as String,
      lemma: null == lemma
          ? _value.lemma
          : lemma // ignore: cast_nullable_to_non_nullable
              as String,
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$RankingImplCopyWith<$Res> implements $RankingCopyWith<$Res> {
  factory _$$RankingImplCopyWith(
          _$RankingImpl value, $Res Function(_$RankingImpl) then) =
      __$$RankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int rank,
      String rankedWord,
      String lemma,
      int wordId,
      bool isLearned,
      bool isBookmarked,
      bool hasNote});
}

/// @nodoc
class __$$RankingImplCopyWithImpl<$Res>
    extends _$RankingCopyWithImpl<$Res, _$RankingImpl>
    implements _$$RankingImplCopyWith<$Res> {
  __$$RankingImplCopyWithImpl(
      _$RankingImpl _value, $Res Function(_$RankingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Ranking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? rankedWord = null,
    Object? lemma = null,
    Object? wordId = null,
    Object? isLearned = null,
    Object? isBookmarked = null,
    Object? hasNote = null,
  }) {
    return _then(_$RankingImpl(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      rankedWord: null == rankedWord
          ? _value.rankedWord
          : rankedWord // ignore: cast_nullable_to_non_nullable
              as String,
      lemma: null == lemma
          ? _value.lemma
          : lemma // ignore: cast_nullable_to_non_nullable
              as String,
      wordId: null == wordId
          ? _value.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
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

class _$RankingImpl implements _Ranking {
  const _$RankingImpl(
      {required this.rank,
      required this.rankedWord,
      required this.lemma,
      required this.wordId,
      this.isLearned = false,
      this.isBookmarked = false,
      this.hasNote = false});

  @override
  final int rank;
  @override
  final String rankedWord;
//ランクに選定されてる形の単語
  @override
  final String lemma;
//原形
  @override
  final int wordId;
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
    return 'Ranking(rank: $rank, rankedWord: $rankedWord, lemma: $lemma, wordId: $wordId, isLearned: $isLearned, isBookmarked: $isBookmarked, hasNote: $hasNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RankingImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.rankedWord, rankedWord) ||
                other.rankedWord == rankedWord) &&
            (identical(other.lemma, lemma) || other.lemma == lemma) &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.isLearned, isLearned) ||
                other.isLearned == isLearned) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.hasNote, hasNote) || other.hasNote == hasNote));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rank, rankedWord, lemma, wordId,
      isLearned, isBookmarked, hasNote);

  /// Create a copy of Ranking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RankingImplCopyWith<_$RankingImpl> get copyWith =>
      __$$RankingImplCopyWithImpl<_$RankingImpl>(this, _$identity);
}

abstract class _Ranking implements Ranking {
  const factory _Ranking(
      {required final int rank,
      required final String rankedWord,
      required final String lemma,
      required final int wordId,
      final bool isLearned,
      final bool isBookmarked,
      final bool hasNote}) = _$RankingImpl;

  @override
  int get rank;
  @override
  String get rankedWord; //ランクに選定されてる形の単語
  @override
  String get lemma; //原形
  @override
  int get wordId;
  @override
  bool get isLearned;
  @override
  bool get isBookmarked;
  @override
  bool get hasNote;

  /// Create a copy of Ranking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RankingImplCopyWith<_$RankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
