## new rule
- featureはport,internalの2層構成
- featureを使うときはport以下にのみアクセス可能。
- feature内のentityは外部に公開せず、portの契約型を通してのみ利用する。Command,Query,Result,EventなどのDTOとしてportに置く。
- featureを跨ぐ機能はより上位のworkflow内でとりまとめてapp配下に置く。
- 画面などもrouteをportから公開し、直接importを極力避ける

## concept
結論として、方向性は次が最も自然です。

- `auth / ranking / quiz / my_word / search / word_detail` は独立Feature
- `catalog` を新しい業務モジュールとして明示する
- `word_status` は西日・日西を統合する
- `conjugation` は現時点ではCatalog内のサブモジュール
- 辞書語とMyWordは統合しない
- `sync` は独立境界だが、分類上はFeatureより横断Workflow/基盤

重要なのは、すべてを同じ種類の「Feature」と考えないことです。

| 種類 | 対象 |
|---|---|
| ユーザーFeature | Search、WordDetail、Quiz、Ranking、MyWord、Auth/Profile |
| 業務能力モジュール | Catalog、WordStatus |
| 横断Workflow/基盤 | Sync、Session lifecycle、Guest migration |

フォルダをすべて `features/` 配下に置いても構いません。ただし役割と依存方向は区別します。

## テックリードとしての判断基準

私は次の順序で判断します。

1. データの正本を誰が所有するか
2. 作成・更新・削除のライフサイクルが同じか
3. 守る業務ルール・トランザクション境界が同じか
4. 変更要求が同時に発生するか
5. 独立したユーザーゴールか
6. 分離後にEntity共有や相互importが増えすぎないか

「フィールドが似ている」は弱い統合理由です。一方、「同じ正本・同じライフサイクル・同じ業務ルール」は強い統合理由です。

## 推奨構成

```text
lib/
├── app/
│   ├── bootstrap/
│   ├── routing/
│   └── workflows/
│       ├── session_lifecycle/
│       ├── guest_migration/
│       └── sync_trigger/
│
├── core/
│   ├── error/
│   ├── result/
│   ├── ui/
│   └── database_runtime/
│
└── features/
    ├── auth/
    ├── user_profile/
    │
    ├── catalog/
    │   ├── port/
    │   │   ├── catalog_id.dart
    │   │   ├── catalog_word_ref.dart
    │   │   ├── catalog_route.dart
    │   │   ├── catalog_reader.dart
    │   │   └── conjugation_reader.dart
    │   └── internal/
    │       ├── domain/
    │       │   ├── word/
    │       │   ├── dictionary_entry/
    │       │   ├── example/
    │       │   └── conjugation/
    │       └── infrastructure/
    │           ├── esp_jpn/
    │           └── jpn_esp/
    │
    ├── search/
    ├── word_detail/
    ├── word_status/
    ├── my_word/
    ├── quiz/
    ├── ranking/
    └── sync/
```

`word_page` は画面名なので、変更理由を表す `word_detail` または `entry_detail` への変更を推奨します。

## Catalogは何を所有するか

現在 `core` に置かれている以下の概念は、技術的な共通物ではなく辞書Catalogの業務概念です。

- Word、見出し語
- DictionaryEntry、語義
- Example、Idiom、Supplement
- 品詞
- Conjugation
- CatalogのRepository・DAO・Mapper

例えば現在の `EspJpnWord` や辞書Entityはここにあります。

- [word.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/core/domain/entity/word/word.dart:5)
- [esj_dictionary.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/core/domain/entity/dictionary/esj_dictionary.dart:7)
- [jpn_esp_dictionary.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart:5)

これらは `core` ではなく `catalog/internal/domain` の所有です。

ただし西日辞書と日西辞書を、一つの巨大なnullable Entityに統合する必要はありません。構造が異なるため、同じCatalog内のsealed variantにします。

```dart
sealed class CatalogEntryDetail {}

final class EspJpnEntryDetail extends CatalogEntryDetail {
  final List<EspJpnDictionaryEntry> entries;
  final SpanishConjugation? conjugation;
}

final class JpnEspEntryDetail extends CatalogEntryDetail {
  final List<JpnEspDictionaryEntry> entries;
}
```

現在の `WordDetailViewData` は、すでにこの考え方に近いです。

## Conjugationを独立Featureにしない理由

現状のConjugationには、独立した作成・編集・削除や画面遷移がありません。

主な用途は次です。

- Searchの活用形候補
- WordDetailの活用表
- Quizの出題材料
- RankingのQuiz可否判定

つまり、現時点では独立したユーザーゴールではなく、Catalogが提供する業務能力です。

そのため、

```text
catalog/internal/domain/conjugation/
```

に置き、外部には必要最小限の `ConjugationReader` を公開するのがよいです。

現在のRepositoryにはQuiz専用メソッドが入っています。

[IConjugacionsRepository](C:/Users/deded/Documents/LocalDev/my_dic/lib/core/domain/i_repository/i_conjugation_repository.dart:6)

```dart
getConjugacionByWordId(...)
getConjugacionByWordWithPage(...)
getQuizConjugacionByWordWithPage(...) // CatalogがQuizを知っている
```

`getQuiz...` はCatalog側から外します。Quiz側に次のようなportを定義し、Catalog adapterで実装します。

```dart
abstract interface class QuizCandidateSource {
  Future<List<QuizCandidate>> search(String query);
}
```

実際、現在はQuizがSearchの型とUseCaseを直接利用しています。

[quiz_search_view_model.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/quiz/presentation/view_model/quiz_search_view_model.dart:5)

これは次の依存へ変更します。

```text
現在: Quiz -> Search
推奨: Quiz -> QuizCandidateSource <- Catalog adapter
```

将来、活用表だけを検索・比較・編集する画面や、独自の更新・バージョン管理が生まれた時点で `conjugation` をトップレベルFeatureへ昇格させます。

## DirectionはFeature境界ではなく能力差

現状の能力差は次の通りです。

| 能力 | Esp→Jpn | Jpn→Esp |
|---|---:|---:|
| 単語検索 | ○ | ○ |
| 辞書詳細 | ○ | ○ |
| WordStatus | ○ | ○ |
| 活用検索・表示 | ○ | × |
| Quiz | ○ | × |
| Ranking | ○ | × |

SearchでもEsp→Jpnのときだけ活用候補を要求しています。

[SearchViewModel](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/search/presentation/view_model/viewmodel.dart:41)

WordDetailでもEsp→Jpnだけ辞書と活用を合成しています。

[LoadWordDetailQuery](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_page/application/query/load_word_detail_query.dart:26)

したがって、次のように方向ごとのFeatureを複製する必要はありません。

```text
esp_jpn_dictionary/
jpn_esp_dictionary/
esp_jpn_conjugation/
```

代わりにCatalog内部でadapterを選択します。

```text
Catalog
├── EspJpn adapter
│   ├── dictionary
│   ├── conjugation
│   ├── ranking metadata
│   └── quiz source
└── JpnEsp adapter
    └── dictionary
```

また、`Direction` より `CatalogId` の方が将来性があります。同じ言語方向に複数の辞書を持つ可能性があるためです。

```dart
enum CatalogId {
  espJpnMain,
  jpnEspMain,
}

final class CatalogWordRef {
  final CatalogId catalogId;
  final int wordId;
}
```

`WordType`、`SearchDirection`、`DictionaryDirection` が現在それぞれ存在するので、外部契約では `CatalogId` に寄せ、各Feature固有型との変換を一か所に集約します。

## WordStatusは統合する

`esp_jpn_word_status` と `jpn_esp_word_status` は統合すべきです。

両Entityは、名前以外ほぼ同じです。

- [EspJpn WordStatus](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/esp_jpn_word_status/domain/esp_word_status.dart:4)
- [JpnEsp WordStatus](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart:4)

DBも両方とも次を持っています。

- `(accountId, wordId)` 主キー
- `isLearned`
- `isBookmarked`
- `hasNote`
- revision、更新日時、削除情報

したがって論理モデルは一つにできます。

```dart
final class CatalogWordStatus {
  final CatalogWordRef word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime updatedAt;
}
```

共通化するものはdomain/application契約です。

方向別に残すものは次です。

- Drift table
- Firebase collection
- Mapper
- Sync handler/adapter
- `SyncDataset` のstable ID

つまり、既存DBや同期プロトコルを変更せず、内部adapterで吸収します。

```text
word_status/
├── external/
├── internal/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
│       ├── esp_jpn/
│       └── jpn_esp/
```

既存のリファクタ計画も同じ方向です。

[word status統合計画](C:/Users/deded/Documents/LocalDev/my_dic/docs/refactor/phase1/6-unify-word-status.md:9)

## 辞書語とMyWordは統合しない

これは明確に分離します。

| 辞書語 | MyWord |
|---|---|
| アプリ配布のCatalog | ユーザー所有 |
| 基本的にread-only | 作成・編集・削除 |
| int ID＋CatalogId | UUID文字列 |
| 全ユーザー共通 | account scoped |
| Catalog更新に従う | 個別同期・競合解決 |
| 親は削除されない | MyWord削除にStatusが従う |

MyWordには独自の登録Validationもあります。

[RegisterMyWordInteractor](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/my_word/application/usecase/my_word/create/register_my_word/register_my_word_interactor.dart:16)

Entityを統合すると、ほぼすべてのフィールドと処理に次の分岐が入ります。

```dart
if (word is CatalogWord) ...
if (word is MyWord) ...
```

これは共通化ではなく、異なるライフサイクルを一つのモデルに押し込めた状態です。

両方を同じ一覧に表示したいなら、write modelではなくread modelで統合します。

```dart
sealed class LibraryItemRef {}

final class CatalogLibraryItemRef extends LibraryItemRef {
  final CatalogWordRef word;
}

final class PersonalLibraryItemRef extends LibraryItemRef {
  final String myWordId;
}
```

必要になった時点で `library` や `my_vocabulary` Featureを作り、CatalogとMyWordをquery projectionで合成します。

## MyWordStatusはどうするか

現時点ではMyWord内に残します。

辞書WordStatusと似ていますが、

- MyWordの削除に連動する
- ID形式が異なる
- MyWordとの同期順序制約がある
- `hasNote` の扱いが一致していない

という差があります。

現在のMyWord用status adapterでも、`hasNote` は常にfalse、toggleはno-opです。

[word_status_buttons.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/app/presentation/word_status_buttons.dart:52)

したがって、今すぐ同一domain modelに統合すると「未実装の差」を共通仕様として固定してしまいます。

共通化するのはボタンUIや小さな操作契約までに留めます。将来、フィールド・削除ルール・同期競合ルールが一致したら、`StudyItemStatus` への昇格を再検討します。

なお現在の `MyWord` EntityにはStatusフィールドがありますが、Repositoryは常にfalseを設定しています。

[MyWordRepository](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/my_word/data/repository_impl/my_word_repository.dart:224)

これはMyWord本体とStatusの責務が混ざったサインなので、`isLearned/isBookmarked` はMyWord Entityから外し、一覧用projectionで合成するのがよいです。

## Search・WordDetail・Rankingの所有範囲

これらは独立Featureとして残しますが、単語Entityは所有しません。

- Search：検索条件、ページング、検索結果snippet、enrichment
- WordDetail：詳細画面用aggregation、部分失敗、表示model
- Ranking：filter、pagination、ランキング画面用projection
- Catalog：Word、DictionaryEntry、Conjugationの正本
- WordStatus：ユーザーごとの可変状態

RankingのDAOがCatalog、Status、ConjugationをJOINするのは、read-onlyの画面用projectionなら許容できます。ただし他Featureのテーブルへwriteしてはいけません。

## `hasConj`をRouteから外す

現在のRouteは `wordId / wordType / hasConj` を受け取ります。

[word_detail_route.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/app/routing/contracts/word_detail_route.dart:7)

しかし `hasConj` は識別子ではなく導出情報です。呼び出し側やdeep linkが誤った値を渡す可能性があります。

推奨Routeは次だけです。

```dart
WordDetailRoute(
  CatalogWordRef word,
)
```

活用の存在は詳細取得時にCatalogが判定します。UIは能力を表示制御に使えても、業務実行の正当性はCatalog側で再確認します。

## 移行順

ディレクトリ移動から始めるべきではありません。

1. Catalog、WordStatus、MyWordのownerをADRに記録
2. `CatalogId` と `CatalogWordRef` を定義
3. Catalogの公開portを作り、既存Repositoryへのadapterを実装
4. Quiz→Search依存をCatalog/Quiz-owned portへ変更
5. `hasConj` をRouteから除去
6. `core` のWord/Dictionary/ConjugationをCatalogへ移す
7. 西日・日西WordStatusのdomain/applicationを統合
8. DB table・Firebase collection・SyncDatasetは変更せずadapter化
9. MyWordとJpnEspWordからStatusフィールドを除去し、query projectionで合成
10. import boundaryをCIで固定
11. 最後にディレクトリ名を整理

この順番なら、構造変更・DB migration・同期プロトコル変更を同時に行わずに済みます。

最終的な一文はこれです。

> 辞書語とMyWordは別Aggregate、ConjugationはCatalog能力、Directionはadapter差、辞書WordStatusだけを一つに統合する。

今回は構成判断のための読み取り調査のみで、コード変更は行っていません。