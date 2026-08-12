# Ranking feature リファクタ計画

この計画は [`feature-design-rules.md`](../architecture/feature-design-rules.md) を
Ranking featureへ適用するための設計と移行手順です。DB schema、同期protocol、route、
画面仕様は変更せず、ビルド可能な縦スライスで境界を置き換えます。

## 1. 目的

- Rankingが画面projection、filter解釈、paging、request fenceを所有する
- Catalogがランキング元データ、品詞、見出し語、活用有無を所有する
- WordStatusがaccount別の学習済み、bookmark、note状態を所有する
- RankingはCatalog／WordStatusの公開contractだけに依存する
- DB、Drift row、他featureのtable、RiverpodをRankingのbusiness portから排除する
- feature外のbusiness importを`features/ranking/port/ranking.dart`へ限定する
- error、absence、paging、invalid rowの扱いをtyped contractとtestで固定する

## 2. Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | `CatalogWordRef`、ranking source row、順位、品詞、見出し語、活用有無、保存値の解釈 | Ranking画面のfilter選択、page size、status条件、表示policy |
| WordStatus | account別のlearned／bookmarked／note状態とその永続化・同期 | Rankingの候補選定、paging、warning |
| Ranking | filterのinclude／exclude解釈、`multiLemma`相当のgrouping、page形成、画面projection、request fence、retry、表示state | Catalog／WordStatusの正本と永続化、他featureのwrite lifecycle |
| `lib/integration/catalog_ranking` | Catalog DTO／errorからRanking required portへの変換 | filter、grouping、paging policy、SQL |
| `lib/integration/word_status_ranking` | WordStatus DTO／errorからRanking required portへの変換 | status filterの採否、warning、SQL |
| `app/bootstrap` | gateway、Ranking composition、Riverpod lifetime／overrideの組み立て | Rankingのfilter、paging、error semantics |
| app router | Rankingのnavigation callbackをdestination routeへ変換 | Ranking内部widget／provider／view model |

## 3. 変更してはいけない挙動

Phase 0で次をcharacterization testとして固定します。

- pageは0始まり、sizeは正数、account scopeは空でない
- 品詞とstatusはinclude／excludeを区別する
- 複数のinclude statusはOR、include条件とexclude条件はANDで合成する
- status条件は指定accountだけを参照し、guest／login／relogin epochを混同しない
- statusと品詞のfilterをpagingより前に適用する
- `multiLemma`選択時だけ同一`CatalogWordRef`のrowをまとめる
- 通常時は同じwordの複数ranking rowを別itemとして保持する
- rowの順序はranking number順とし、同順位のtie-breakを決定的にする
- `size + 1`相当のlook-aheadで正確な`hasMore`を返す
- 必須値が欠けた保存rowは公開DTOへsentinel変換しない
- page 0は置換、後続pageはappendし、stable row identityで重複を除く
- 同一requestの多重実行、filter reset後のlate completion、dispose後のcompletionを破棄する
- retryは失敗したpage identityを再実行し、勝手にpageを進めない
- WordStatus buttonはpage snapshotではなくlive stateを表示する
- Word detail／Quizへの遷移は`CatalogWordRef`とoptional display hintをcallbackで渡す

### Phase 0で決定する契約上の論点

現在の`RankingListItem.rankingId`は物理`rankings.ranking_id`由来ですが、Catalog計画では
ranking metadataをCatalog所有としています。通常時に同じwordの複数rowを保持し、page間で
安定してdedupeするにはrow identityが必要です。

推奨決定は、Catalog所有のopaque value object `CatalogRankingEntryRef`を公開し、
serializationとlifecycleをCatalog ADR／public surfaceへ明記することです。Rankingはadapterで
これを`RankingItemId`へ値変換してもよいですが、物理PKの意味を解釈してはいけません。
物理PKを安定した業務identityと認められない場合は、Catalog側で永続的なbusiness keyを
導入する別migrationが必要です。indexやschema変更は本リファクタへ混ぜません。

## 4. 現状の問題

### Public surface

- `port/ranking.dart`がなく、外部testが`port/model/**`をdeep importしている
- `IRankingQueryRepository`と`RankingReaderPort`が同じoperationを公開し、
  `InternalRankingReaderPort`は単なるpass-throughになっている
- `port/query.dart`と`port/filter.dart`がcommentだけの未完成barrelである
- `LoadRankingsInputData`がmutable `Map<Enum, int>`をcontractにし、
  `UpdateRankingFilterInputData`／`OutputData`は`Object`とmagic numberを公開している
- 公開errorがなく、`DatabaseError`がRanking境界から漏れる

### Ownership／integration

- `RankingDao`がCatalog、WordStatus、Conjugationのtableを直接JOIN／`EXISTS`し、
  Rankingが他ownerの保存形式とcolumnを解釈している
- `FeatureTag`がstatus filter、Ranking固有grouping、未対応のMyWordを一つのenumに混在させる
- public queryにraw account `String`とprovider都合のfilterが混ざっている
- `RankingListItem`がraw `wordId`を公開し、共有identityの`CatalogWordRef`を使っていない

### Application／presentation／composition

- filter更新use caseは入力をそのまま返すだけで、業務処理になっていない
- ViewModelがfilter型変換、use case DTO生成、paging、request fenceを一か所に抱える
- Riverpod providerが`internal/composition`と`internal/presentation/provider`へ分散し、
  app-owned composition seamがない
- `RankingCard`がWordStatus presentation entryを直接importしている
- testの一部が存在しない旧path `internal/composition/view_model_di.dart`を参照している

## 5. 目標構造

必要なdirectoryだけを作り、最終形を次に揃えます。

```text
lib/features/ranking/
├─ port/
│  ├─ ranking.dart
│  ├─ reader/ranking_page_reader_port.dart
│  ├─ gateway/ranking_catalog_gateway.dart
│  ├─ gateway/ranking_word_status_gateway.dart
│  ├─ query/ranking_page_query.dart
│  ├─ model/ranking_filter.dart
│  ├─ model/ranking_item.dart
│  ├─ model/ranking_item_id.dart
│  ├─ result/ranking_page.dart
│  ├─ error/ranking_read_error.dart
│  ├─ composition.dart
│  ├─ presentation_dependencies.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   │  ├─ read_ranking_page.dart
   │  ├─ ranking_page_assembler.dart
   │  └─ ranking_filter_policy.dart
   ├─ domain/
   │  └─ ranking_filter_selection.dart
   ├─ presentation/
   │  ├─ provider/
   │  ├─ ui_model/
   │  ├─ view_model/
   │  └─ view/
   └─ composition/
      └─ ranking_composition_factory.dart

lib/integration/
├─ catalog_ranking/
│  ├─ catalog_backed_ranking_gateway.dart
│  └─ catalog_ranking_providers.dart
└─ word_status_ranking/
   ├─ word_status_backed_ranking_gateway.dart
   └─ word_status_ranking_providers.dart
```

移行完了後、Rankingの`internal/infrastructure/drift/**`は削除します。Rankingが独自の
materialized read modelを将来所有する場合だけ、別ADRとschema migrationを伴う
infrastructureを再導入します。

## 6. Public contract

### 唯一のbusiness facade

`port/ranking.dart`が明示的にexportするものを次に限定します。

- `RankingPageReaderPort`
- `RankingPageQuery`
- `RankingFilter`
- `RankingStatusFilter`
- `RankingItem`／`RankingItemId`
- `RankingPage`
- `RankingReadError`
- integrationが実装する`RankingCatalogGateway`／`RankingWordStatusGateway`

`composition.dart`、`presentation_dependencies.dart`、`presentation_entry.dart`は
technical seamとし、business facadeからre-exportしません。

### Query／filter

`RankingPageQuery`は生成時に次を保証します。

- `page >= 0`
- `size > 0`
- account scopeが空でない
- collectionをdefensive copyする
- status filterは`learned`、`bookmarked`、`hasNote`だけを許可する
- groupingは`groupByCatalogWord`の明示boolまたはtyped optionにする

filter stateは`Map<Enum, int>`ではなく、include／exclude／neutralを表すenumまたは
include setとexclude setで表現します。同じ値をincludeとexcludeへ同時指定した場合の
扱いはcharacterization後に決め、現行挙動を変える場合は明示的な仕様変更にします。

### Result／identity／absence

- `RankingItem`は`RankingItemId`、`CatalogWordRef`、rank、表示用headword／lemma、
  `hasConjugation`を持つpure DTOとする
- collection 0件は`Result.success(RankingPage(items: [], hasMore: false))`
- providerに存在しないoptional statusは全flag false相当の事実として扱うか、
  missingとして扱うかをWordStatus contract testで固定する
- invalid source row、Catalog障害、WordStatus障害、想定外をtyped `RankingReadError`へ変換する
- `DatabaseError`、Drift row、SQL column、raw status wire valueを公開しない

### Required ports

`RankingCatalogGateway`はCatalogのranking feedをprovider-neutralなchunkとして返します。
feedにはopaque row identity、`CatalogWordRef`、順位、品詞、見出し語、活用有無、
continuation／source上の次row有無を含めます。Rankingのpage number、warning、filter stateは
含めません。

`RankingWordStatusGateway`は`CatalogWordRef`のbatchに対して、指定accountのstatus factsを
返します。Ranking applicationがinclude／excludeを解釈し、gatewayは候補選定をしません。

このためにCatalogへconsumer非依存のranked-entry feed ReaderPort、WordStatusへread-only
batch ReaderPortを追加します。既存の単語別`CatalogRankingReaderPort`やwrite可能な
`WordStatusRepository`をRanking向けに流用しません。

## 7. Application flow

`ReadRankingPage`は次の順に処理します。

1. `RankingPageQuery`からimmutableなfilter snapshotを受け取る
2. Catalog gatewayから決定的順序のchunkを読む
3. Ranking所有の品詞条件とgrouping policyを適用する
4. 対象`CatalogWordRef`のstatusをbatch取得する
5. Ranking所有のstatus include／exclude policyを適用する
6. filter後のoffsetへ到達するまでchunkを続けて読み、最大`size + 1`件を集める
7. `size`件へ切り詰め、余剰1件の有無から`hasMore`を決める
8. provider errorを`RankingReadError`へ正規化して返す

これにより他ownerのtableを直接JOINせず、status filterをpaging前に適用する現行semanticsを
維持します。offset pageが深い場合は先頭からのscan costが増えるため、fixture規模と実assetで
計測します。許容値を超える場合は、Ranking-owned materialized projectionまたはopaque cursor
を別ADRで検討し、integration adapterへpolicyやSQLを押し込みません。

## 8. Presentationとrouting

- `RankingViewModel`は`RankingPageReaderPort`、session scope、pure filter stateだけを受け取る
- pass-throughの`UpdateRankingFilterInteractor`とその`Object` DTOを削除し、filter更新を
  typed state transitionへ置き換える
- request generation、page identity、retry、late-completion fenceはRanking presentationが保持する
- `RankingNormalizedFilter`はtyped `RankingFilter`をsnapshotとして使い、Flutterの
  `mapEquals`へ業務identityを依存させない
- `RankingCard`へWordStatus表示componentまたはcallbackをentry dependencyとして注入し、
  Ranking internalからWordStatus presentationを直接importしない
- `RankingFragment`の`onOpenWordDetail`／`onOpenQuiz`は`CatalogWordRef`とoptional hintだけを渡す
- app routerだけがcallbackをWordDetail／Quiz route contractへ変換する
- Flutter公開は`port/presentation_entry.dart`の`RankingFragment`に限定する

## 9. Composition

- Ranking internal factoryは2つのrequired gatewayから`RankingPageReaderPort`を構築する
- `port/composition.dart`はfactoryを呼ぶcontrolled seamだけを公開する
- `port/presentation_dependencies.dart`はRanking reader、WordStatus表示dependency、
  session dependencyをRiverpodへ接続する
- `app/bootstrap`がCatalog／WordStatus composition、2つのintegration adapter、Ranking
  compositionを組み立てる
- resolverやRiverpod `Ref`をapplication service、query、result、gatewayへ渡さない
- adapter本体はpure Dart、`*_providers.dart`だけがRiverpodへ依存する

## 10. 段階的な実装計画

### Phase 0: ADRとcharacterization

1. ownership matrixをRanking ADRへ記録する
2. `CatalogRankingEntryRef`の意味、lifecycle、serialization、tie-breakを決定する
3. 現行のfilter合成、grouping、invalid row、paging、request fenceをtestで固定する
4. 実assetで代表queryの件数、順序、深いpageの所要時間をbaseline化する

完了条件: 変更してはいけない挙動と、意図的に変える挙動がtest名で区別されている。

### Phase 1: Ranking public contract

1. typed query、filter、item、page、error、required gatewayを追加する
2. `RankingPageReaderPort`を唯一のread facadeにする
3. `port/ranking.dart`を追加し、contract testをfacade importへ切り替える
4. legacy port／DTOはこのphaseでは残すが、新規参照を禁止する

完了条件: business portがpure Dartで、validation、immutability、absence、typed errorのtestが通る。

### Phase 2: provider側のread能力

1. Catalogへconsumer非依存のranked-entry feed portとinternal readerを追加する
2. WordStatusへaccount-scoped batch reader portとinternal readerを追加する
3. provider境界でDB errorとinvalid rowをtyped errorへ正規化する
4. ownerごとのin-memory／Drift contract testを追加する

完了条件: Ranking型をimportせずにCatalog／WordStatusのprovided portが実装される。

### Phase 3: integration adapter

1. `catalog_ranking`のpure adapterとRiverpod wiringを分離して実装する
2. `word_status_ranking`のpure adapterとRiverpod wiringを分離して実装する
3. DTO、identity、error、missing itemの変換testを追加する

完了条件: adapterがfeature facadeだけをimportし、filter／paging／SQLを持たない。

### Phase 4: Ranking application

1. chunk scan、品詞／status filter、grouping、`size + 1`を`ReadRankingPage`へ実装する
2. provider errorを`RankingReadError`へ正規化する
3. legacy DAOと新Readerを同じfixtureへ当てるparity testを作る
4. 通常、空、partial missing、provider failure、深いpageをtestする

完了条件: parity対象の現行queryが同じitems／順序／`hasMore`を返す。

### Phase 5: presentation縦スライス

1. ViewModelをtyped filterと新Readerへ切り替える
2. page 0、append、retry、reset、session epoch、late completion testを新contractへ移す
3. WordStatus componentをpresentation dependencyとして注入する
4. route callbackを`CatalogWordRef`中心に統一する
5. widget／Gate B acceptance testをpublic entryから実行する

完了条件: Ranking画面がlegacy use case／repository／internal providerを参照しない。

### Phase 6: composition切替とlegacy削除

1. app bootstrapを新compositionとintegration wiringへ切り替える
2. `IRankingQueryRepository`、`InternalRankingReaderPort`、旧use case、旧filter DTOを削除する
3. `RankingDao`、`DriftRankingQueryRepository`、`RankingQueryRow`とgenerated partを削除する
4. commentだけのbarrelと旧DI providerを削除する
5. productionとtestの参照が0であることを`rg`で確認する

完了条件: re-export shim、typedef alias、重複model、旧path参照が残らない。

### Phase 7: 境界自動検査と文書化

1. feature外からRanking `internal/**`と個別`port/**`へのimportを禁止する
2. Ranking business portからFlutter、Riverpod、Driftへのimportを禁止する
3. integrationからfeature internal、DAO、SDKへのimportを禁止する
4. Ranking internalから他feature internal／presentation entryへのimportを禁止する
5. app routingからRanking internalへのimportを禁止する
6. ADR、public surface manifest、import boundary文書を最終実装へ合わせる

完了条件: checker fixtureが各禁止例を検出し、repositoryの実違反が0になる。

## 11. テスト計画

### Port contract

- page／size／account scope validation
- filter collectionのdefensive copyとvalue equality
- include／excludeの型安全性
- empty page、exact-size最終page、look-aheadありのpage
- typed `RankingReadError`
- `RankingItemId`と`CatalogWordRef`のidentity保持

### Owner internal contract

- Catalog feedの順序、tie-break、duplicate word row、invalid row
- WordStatus batchのaccount分離、missing item、empty batch
- bind variable利用と特殊値
- infrastructure errorのowner errorへの正規化

### Integration adapter

- Catalog／WordStatus DTOからRanking DTOへの変換
- provider errorからRanking gateway errorへの変換
- opaque row identityと`CatalogWordRef`の保持
- batchのmissing key保持

### Ranking application

- 品詞include／exclude
- status include OR、exclude、include＋exclude
- filter後pagingと正確な`hasMore`
- chunk境界をまたぐpage形成
- grouping有無とstable dedupe
- provider failure単位とinvalid source item
- legacy DAOとのfixture parity

### Presentation／acceptance

- page 0 replace、後続append、same-page多重実行防止
- filter reset、retry、session epoch、dispose／late completion fence
- live WordStatus表示
- public presentation entryから初期load、filter、scroll、error、retry
- navigation callback payload

## 12. 検証順序

各phaseでfocused testを先に実行し、最終phaseでは次の順に確認します。

1. Ranking port／application／presentationのunit test
2. Catalog／WordStatus provider contract test
3. `catalog_ranking`／`word_status_ranking` adapter test
4. Ranking widget testとGate B acceptance test
5. import boundary checker
6. `dart analyze`
7. repository全体の`flutter test`

Flutter／Dart commandはrepositoryの`AGENTS.md`に従いsandbox外で直接実行します。

## 13. Scope外

- DB schema、ranking table、indexの変更
- sync／asset import protocolの変更
- filter項目や画面デザインの追加
- route path、route name、deep linkの変更
- WordStatus write APIの再設計
- deep page性能のためのmaterialized projection導入

これらが必要になった場合は、本計画の構造変更と分離したADR／migrationとして扱います。
