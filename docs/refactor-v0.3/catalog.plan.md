Catalogリファクタの方針と実装計画です。Phase 8 のCatalog facade、外部
deep-import移行、境界checker、ADRおよび公開surface文書まで実装済みです。
repository全体の完了条件にはCatalog外の既存違反が残るため、検証状況は
`remaining-work.md` に記録します。

# 確定した設計

## Ownership

- 辞書master、語義、活用、見出し語、`frequencyLevel`、`rankingNo` はCatalog所有
- Ranking featureは画面projection、filter、pagingを所有
- Search/Quizのquery解釈、warning、候補選定、表示方針は各consumer所有
- `CatalogWordRef` だけをfeature間の共有identityとする

## 依存方向

```text
Catalog ReaderPort
        ↑
lib/integration のadapter
        ↓
SearchCatalogGateway / QuizCatalogGateway
        ↓
Search / Quiz internal policy
```

- CatalogはSearch/Quiz固有の語彙を持たない
- Search/QuizはCatalog internalをimportしない
- DTO・error変換は`lib/integration`が担当する

# 目標ディレクトリ

```text
lib/
├─ features/
│  └─ catalog/
│     ├─ port/
│     │  ├─ catalog.dart
│     │  ├─ composition.dart
│     │  ├─ presentation_dependencies.dart
│     │  ├─ reader/
│     │  ├─ query/
│     │  ├─ result/
│     │  ├─ model/
│     │  └─ error/
│     └─ internal/
│        ├─ application/
│        ├─ domain/
│        ├─ infrastructure/
│        │  └─ drift/
│        │     ├─ dao/
│        │     ├─ mapper/
│        │     ├─ query/
│        │     └─ reader/
│        └─ composition/
└─ integration/
   ├─ catalog_search/
   │  ├─ catalog_backed_search_gateway.dart
   │  └─ catalog_search_providers.dart
   └─ catalog_quiz/
      ├─ catalog_backed_quiz_gateway.dart
      └─ catalog_quiz_providers.dart
```

Catalog外からimportできる入口は次だけにします。

```dart
import 'package:my_dic/features/catalog/port/catalog.dart';
```

`catalog/port/**` の個別ファイルへのdeep importと、`catalog/internal/**` のimportは境界checkerで禁止します。

## Riverpodの例外

ReaderPort、Query、Result、model、errorはpure Dartを維持します。

Riverpodは一旦、次の技術的公開ファイルにだけ許可します。

- `port/composition.dart`
- `port/presentation_dependencies.dart`

現在の `T Function<T>(Object)` dependency resolverは今回変更しません。

# 公開するReaderPort

すべて読み取り専用のapplication Query Serviceとし、`Result<T>`を返します。

```text
CatalogReadPorts
├─ CatalogEntryDetailReaderPort
├─ CatalogConjugationReaderPort
├─ CatalogWordSearchReaderPort
├─ CatalogConjugationSearchReaderPort
├─ CatalogEntrySummaryReaderPort
└─ CatalogRankingReaderPort
```

`CatalogEntrySummaryReaderPort` は部分失敗を維持するため、operationを分けます。

```dart
readMeanings(...)
readHeadwordMetadata(...)
```

`CatalogRankingReaderPort` も独立させ、語義などの取得失敗と分離します。

## 主な公開型

- `CatalogWordSearchQuery`
- `CatalogConjugationSearchQuery`
- `CatalogSearchPage<T>`
- `CatalogWordSearchHit`
- `CatalogConjugationSearchHit`
- `CatalogConjugationMatch`
- `CatalogMeaningSummary`
- `CatalogHeadwordMetadata`
- `CatalogFrequencyLevel`
- `CatalogRankingMetadata`
- `CatalogReadError`

`CatalogFrequencyLevel` は非負整数のvalue objectとし、通常範囲を0〜3として文書化します。

HTML、Drift row、SQL column名、活用形のwire文字列は公開しません。

# QueryとResultの契約

## Query validation

Query生成時に以下を検証します。

- `page >= 0`
- `size > 0`
- trim後の検索文字列が空でない
- 指定Catalogが対象能力をサポートする

不正値は同期的な`ArgumentError`とします。`CatalogInvalidQueryError`は作りません。

前後空白だけCatalog Queryが除去し、大文字小文字、アクセント、かな表記などは変更しません。

## Paging

Reader内部で`size + 1`件を取得します。

```dart
CatalogSearchPage<T>(
  items: 最大size件,
  hasMore: 実際に次のrowが存在するか,
)
```

これにより、最終ページがちょうど`size`件の場合の誤った`hasNext`を修正します。

## not found

- entry detailなし：`CatalogEntryNotFoundError`
- 活用なし：`Result.success(null)`
- 検索0件：空page
- batchの一部データなし：該当keyをMapへ含めない
- DB障害：`CatalogDataUnavailableError`
- 不正保存データ：`CatalogDataCorruptedError`
- 想定外：`CatalogUnexpectedReadError`

DatabaseErrorなどのインフラエラーはReader境界でCatalog errorへ変換します。

# データ取得仕様

## 語義

西日Catalogでは次の優先順位を維持します。

1. conjugation tableのmeaning
2. dictionary entryのmeaning

日西Catalogはdictionaryの最初のentryを使用します。

HTMLからplain textへの変換はCatalog internal mapperが担当します。

## 見出し語

Catalog internalでHTMLを解析し、次を公開します。

- cleanな見出し語
- `CatalogFrequencyLevel`

Search/Quiz側でHTMLや`<sup>(**)</sup>`を解析しません。

## Ranking

同じ`CatalogWordRef`に複数rowがある場合、最小の`ranking_no`を代表順位として返します。

現在の「最小の`ranking_id`を持つrowを選ぶ」挙動からの意図的変更です。

# 実装フェーズ

## Phase 0：既存挙動の固定

production code変更前にcharacterization testを追加します。

固定対象：

- 西日／日西の検索方向
- 検索順序
- 活用形の完全一致優先
- 語義fallback
- 見出し語HTMLからfrequency抽出
- enrichmentの部分失敗
- entry detailのnot found
- 活用なし
- 同一wordの複数ranking row
- paging境界

SQL安全化、最小`ranking_no`、正確な`hasMore`は既存挙動ではなく、新仕様のtestとして追加します。

## Phase 1：新しいCatalog public contract

新ReaderPort、Query、Result、model、errorを追加します。

- 旧raw portはまだ削除しない
- `CatalogReadPorts` bundleを追加
- `port/catalog.dart` を公開facadeにする
- Catalog外のimportを段階的にfacadeへ変更

この時点では既存機能を新portへ切り替えません。

## Phase 2：Catalog internal Reader実装

現在の以下をconsumer非依存な実装へ分解します。

- `internal/infrastructure/integration/search/**`
- `internal/infrastructure/integration/quiz_candidate/**`

移動先は概ね次です。

```text
internal/infrastructure/drift/query/
internal/infrastructure/drift/reader/
internal/infrastructure/drift/mapper/
```

実装するReader：

- Drift word search reader
- Drift conjugation search reader
- Drift entry summary reader
- Drift ranking reader

Quiz専用Readerは作らず、Quizも汎用Catalog Readerを利用します。

## Phase 3：SQL・mapper安全化

活用検索SQLを同時に修正します。

- 検索文字列をすべてbind variable化
- `%`、`_`、escape文字をliteral扱い
- prefix検索用の`%`だけCatalog側で付加
- 同じqueryの二重実行を削除
- DAOのデバッグログを削除
- wire keyを`CatalogConjugationMatch`へ変換
- HTML解析をCatalog mapperへ集約

## Phase 4：Catalog composition切替

[composition_contract.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/catalog/port/composition_contract.dart) を`CatalogReadPorts`中心へ変更します。

- resolver方式は維持
- 新Readerをbundleへ登録
- 旧raw Readerも移行期間中だけ併存
- presentation dependency providerを新しいReader型へ更新
- composition testで全Readerが同一scopeから取得されることを確認

## Phase 5：Search切替

`SearchCatalogGateway`をconsumer-owned required portとして整理します。

- gatewayの各operationを`Result`化
- Search所有のQuery／Result／errorを使用
- pure adapter本体とRiverpod providerを分離
- Catalog errorをSearch gateway errorへ変換
- paging、warning、部分失敗policyはSearch internalに残す
- wire key変換とHTML解析をSearchから削除

切替後、SearchはCatalog raw DTOへ依存しません。

## Phase 6：Quiz切替

新しい`QuizCatalogGateway`を追加します。

- Quiz所有のQuery／Result／errorを定義
- pure Catalog-backed adapterを`lib/integration/catalog_quiz`へ配置
- Riverpod providerを別ファイルへ配置
- Quiz candidate policyはQuiz internalに維持
- Catalogの`CatalogRawQuizCandidateReaderPort`依存を削除

## Phase 7：legacy削除

全consumer切替後に次を完全削除します。

- `CatalogRawSearchReaderPort`
- `CatalogRawQuizCandidateReaderPort`
- raw Query／Hit DTO
- Catalog内の`integration/search`
- Catalog内の`integration/quiz_candidate`
- Search/Quiz側のwire key parser
- Search/Quiz側のHTML frequency parser
- 一時的なcompatibility provider／alias
- 旧test

最終状態にshimは残しません。

## Phase 8：境界checkerとドキュメント

[check_import_boundaries.dart](C:/Users/deded/Documents/LocalDev/my_dic/tool/check_import_boundaries.dart) とfeature dependency checkerへ次を追加します。

- Catalog外からのimportは`port/catalog.dart`だけ許可
- Catalog internalへの外部import禁止
- `lib/integration/**` はfeature portだけimport可能
- integrationからDAO、Drift row、feature internalをimport禁止
- Catalog internalのpath／型名にSearch・Quiz固有語を残さない
- Riverpod importはCatalog portの2ファイルだけ許可

ADR、public surface manifest、remaining-workも新しい契約へ更新します。

# テスト構成

## In-memory Drift contract test

- 各ReaderPortのsuccess／failure
- 西日／日西分岐
- `size + 1` look-ahead
- exact-size最終ページ
- 最小`ranking_no`
- 語義優先順位
- missing batch entry
- frequency 0〜3と4以上
- HTML除去
- SQL bind
- `'`、`%`、`_`を含む検索
- Catalog error変換

## 実asset smoke test

- 西日の代表語
- 日西の代表語
- 活用形検索
- entry detail
- ranking参照整合性
- HTML／mapperと実データの整合性

## Integration adapter test

ProviderContainerなしでpure adapterをテストします。

- Catalog DTOからSearch/Quiz DTOへの変換
- Catalog errorからconsumer errorへの変換
- `CatalogWordRef`の保持
- `hasMore`の保持
- 部分失敗の伝播

既存のSearch/Quiz acceptance testも最終ゲートとして維持します。

# 完了条件

- 旧raw port参照が0件
- Catalog内のconsumer固有integration directoryが0件
- Catalog外からのCatalog deep importが0件
- Search/QuizからCatalog internal importが0件
- SQLへの検索文字列直接埋め込みが0件
- Search/QuizでのCatalog HTML解析が0件
- Search/QuizでのCatalog wire key解析が0件
- import boundary checkerがgreen
- `dart analyze`がgreen
- Catalog unit/contract testがgreen
- Search/Quiz integration・acceptance testがgreen
- full `flutter test`がgreen

この計画ではDB schema、同期protocol、画面仕様は変更しません。意図的な挙動変更は「正確な`hasMore`」「最小`ranking_no`」「SQL安全化」の3点です。
