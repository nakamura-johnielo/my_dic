import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

@DataClassName('MyWordTableData')
class MyWords extends Table {
  IntColumn get myWordId => integer().named('my_word_id').autoIncrement()();
  TextColumn get word => text().named('word')();
  TextColumn get contents => text().named('contents').nullable()();
  TextColumn get editAt => text().named('edit_at')();
  /* TextColumn get partOfSpeech => text().named('part_of_speech').nullable()();
  TextColumn get partOfSpeechMark =>
      text().named('part_of_speech_mark').nullable()(); */

  @override
  Set<Column> get primaryKey => {myWordId};
}

class MyWordDTO {
  static const String collectionName = "MyWords";

  static const String fieldMyWordId = "wordId";
  static const String fieldMyWord = "word";
  static const String fieldContents = "contents";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";

  //!TODO finalにすべき？copywith?

  final int myWordId;
  String word;
  String contents;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;

  MyWordDTO({
    required this.myWordId,
    required this.word,
    required this.contents,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ----------------------------
  /// Firestore → AppUser に変換
  /// ----------------------------
  factory MyWordDTO.fromFirebase(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MyWordDTO(
        myWordId: data[fieldMyWordId],
        word: data[fieldMyWord],
        contents: data[fieldContents],
        updateBy: data[fieldupdateBy],
        createdAt: (data[fieldCreatedAt] as Timestamp).toDate().toUtc(),
        updatedAt: (data[fieldUpdatedAt] as Timestamp).toDate().toUtc());
  }

  MyWord toEntity() {
    return MyWord(
      wordId: myWordId,
      word: word,
      contents: contents,
      isLearned: false,
      isBookmarked: false,
      editAt: updatedAt,
    );
  }

  /// ----------------------------
  /// AppUser → Firestore へ保存
  /// ----------------------------
  Map<String, dynamic> toFirebase() {
    return {
      fieldMyWordId: myWordId,
      fieldMyWord: word,
      fieldContents: contents,
      fieldupdateBy: updateBy,
      fieldCreatedAt: Timestamp.fromDate(createdAt.toUtc()),
      fieldUpdatedAt: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  factory MyWordDTO.fromAppEntity(MyWord data, {DateTime? dateTime}) {
    //final data = doc.data()!;
    return MyWordDTO(
        myWordId: data.wordId,
        word: data.word,
        contents: data.contents,
        updateBy: "data.updateBy",
        createdAt:dateTime?? MyDateTime.sentinel,
        updatedAt: data.editAt);
  }

  /// ----------------------------
  /// コピー（更新用）
  /// ----------------------------
  // WordStatusEntity copyWith({
  //   String? userName,
  //   String? email,
  //   SubscriptionStatus? subscriptionStatus,
  // }) {
  //   return WordStatusEntity(
  //     userId: userId,
  //     email: email ?? this.email,
  //     userName: userName ?? this.userName,
  //     //photoUrl: photoUrl ?? this.photoUrl,
  //     //devices: deviceId ?? this.devices,
  //     createdAt: createdAt,
  //     updatedAt: DateTime.now().toUtc(),
  //     subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
  //   );
  // }
}
