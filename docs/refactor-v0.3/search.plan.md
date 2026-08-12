# Search feature リファクタ計画

この計画は [`feature-design-rules.md`](../architecture/feature-design-rules.md) を
Search featureへ適用するための設計と移行手順です。既に導入済みの
`SearchCatalogGateway`、`CatalogBackedSearchGateway`、Search presentationのrequest
fenceを土台にし、検索結果、paging、warning、画面仕様を変えずに境界を完成させます。

## 1. 目的とスコープ

- Searchが検索語の解釈、検索方向、結果projection、活用候補、部分失敗、paging表示を所有する
- Catalogが辞書identity、見出し語、意味、活用、frequency、ranking metadataの正本を所有する
- SearchはCatalogの公開contractだけを、consumer-owned required port越しに利用する
- feature外のbusiness importを`features/search/port/search.dart`へ限定する
- Riverpod／Flutterをbusiness facadeから分離し、technical seamだけに閉じ込める
- raw `AppError`、文字列operation、重複した数値ID、provider変換を公開DTOから排除する
- 壊れていて未参照の旧use case／DI／widgetを、参照ゼロ確認後に削除する
- import boundary checker、contract test、public surface manifestで完成した境界を維持する

DB schema、Catalogの検索アルゴリズム、route、画面デザイン、検索結果の並び順は変更しません。

## 2. Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | `CatalogWordRef`、辞書ごとのidentity、見出し語、意味、活用形、frequency、ranking metadata、source上の次row有無、複数sourceの優先順位 | Search語の方向判定、活用候補の表示条件、warning化、画面paging、retry |
| Search | 検索語のtrimと方向解釈、page request、primary結果projection、enrichmentの採否、活用候補policy、partial-failure／warning policy、画面state | Catalogのtable／row、保存値、検索SQL、metadataの正本 |
| `lib/integration/catalog_search` | Catalog DTOからSearch required-port DTOへの値変換、Catalog errorからSearch gateway errorへの変換 | 検索方向policy、候補件数、warning化、paging推測、SQL |
| `app/bootstrap` | CatalogとSearchのruntime instance、Riverpod lifetime、overrideの組み立て | Search queryの意味、failure／warning semantics |
| app router | Searchのnavigation callbackをWordDetail／Quiz route contractへ変換 | Search内部widget、provider、view model |

共有を認めるCatalog所有型は`CatalogWordRef`だけとします。`CatalogId`をSearchの検索方向から
導く責務はintegration adapterに置き、Searchの公開modelへCatalog mappingを持たせません。

## 3. 変更してはいけない挙動

Phase 0で、現在通っているunit／widget／Gate B testをcharacterization testとして整理し、
少なくとも次を固定します。

- 検索語はtrim後の空文字を拒否する
- Latin文字またはスペイン語文字を含む語は西日、含まない語は日西として扱う
- pageは0始まり、sizeは正数とする
- primary検索の失敗だけが検索全体をfailureにする
- meaning、frequency、ranking、活用候補の失敗は、取得済みの基本結果を捨てずwarningにする
- 日西検索ではSpanish-onlyのranking／frequency／活用readerを呼ばない
- 活用候補は西日、page 0、候補取得有効時だけ取得する
- Catalogが返した`hasMore`をSearchの`hasNext`として保持し、item数から推測しない
- page 0は結果を置換し、後続pageは`CatalogWordRef`で重複除去してappendする
- 同一pageのin-flight requestを多重実行しない
- 同一result generation中に複数pageを並行実行しない
- query変更前、dispose後、より古いattemptのcompletionを画面stateへ反映しない
- retryは失敗したpage、query、sizeを再実行し、勝手に次pageへ進めない
- empty result、primary failure、enrichment warningを別のUI stateとして表示する
- WordDetail／Quiz callbackへ`CatalogWordRef`を渡し、Quizのdisplay hintはidentityにしない

### Phase 0で明文化する論点

現行実装ではapplicationが活用候補を4件取得し、presentationが先頭2件だけを表示します。
この「4件取得して2件表示」を互換仕様として残す理由（重複回避、将来余地等）はコード上で
説明されていません。Phase 0では実assetと既存画面を確認し、次のいずれかをADRで決定します。

1. 現行どおりfetch limit 4／display limit 2をSearch-owned policyとして明示する
2. 表示上必要な2件だけを取得するよう意図的な仕様変更として分離する

構造リファクタ中は既存値を維持し、決定前に件数を変更しません。

## 4. 現状の評価

### 既に活用できる部分

- Search-owned required portの`SearchCatalogGateway`がある
- Catalogとのpure adapterとRiverpod wiringが別fileになっている
- Catalogのstable identityとして`CatalogWordRef`を利用している
- Search applicationにprimary／enrichment／suggestionのpolicyが集約されている
- presentationにpage identity、retry target、request generation、late-completion fenceがある
- Catalog adapter、Search application、view model、widget、Gate B acceptanceのtestが存在する

### Public contractの問題

- 唯一のbusiness facadeである`port/search.dart`がなく、production／testが
  `port/reader.dart`、`port/model/**`、`port/error/**`をdeep importしている
- `port/query.dart`はqueryだけでなくresultやitemもまとめる不明瞭なbarrelになっている
- `SearchQuery`のpage／size検証が`assert`だけで、release buildのinvariantにならない
- 空文字validationが`InternalSearchReaderPort`と旧`SearchWordInteractor`に重複している
- `SearchResultItem`と`ConjugationSearchItem`が`CatalogWordRef`に加えてraw `wordId`を重複保持する
- `SearchIssue`がraw `String source`と汎用`AppError`を公開し、許可されるfailure単位が型で閉じていない
- `SearchCatalogQuery`にもpage／size／空文字の生成時validationがない
- `SearchGatewayError` typedefが移行shimとして残っている
- `SearchDirectionCatalogWordRef`がSearch port内で`SearchDirection`から`CatalogId`を解釈し、
  integration adapterのmappingと重複している

### Application／integrationの問題

- `InternalSearchReaderPort`が`internal/`直下にあり、application serviceとしての配置が曖昧である
- `SearchHeadwordMetadata`はheadwordとfrequencyを返すが、Searchはfrequencyしか利用していない
- Catalogの活用matchからSearch matchへの変換がenum index依存で、enum追加時に誤変換し得る
- primary gateway errorがSearchの公開read errorへ正規化されず、そのまま上位へ流れる
- warningの順序、同じsourceの複数failure、missing metadataの扱いがcontractとして明示されていない
- Search presentationが方向判定の正規表現を直接所有し、壊れた旧判定use caseも別に残っている

### Legacy／構造上の問題

- `judge_search_word/**`は存在しない`internal/domain/**`をimportし、対象`dart analyze`で
  13件のerrorを発生させる一方、productionから参照されていない
- `SearchWordInteractor`はvalidation後に`SearchReaderPort`へ委譲するだけのpass-throughである
- `internal/di/usecase_di.dart`のproviderは現行presentationから参照されていない
- `SearchCard`、`JpnEspSearchCard`、`ConjugacionSearchCard`、`reverse_curve.dart`はproduction／testから
  参照されず、現行`SearchResultCard`と役割が重複する
- `presentation_entry.dart`はinternal widgetをexportしているが、公開入力とcallbackをmanifestで
  明文化していない
- 現行checkerはCatalog／MyWordのfacade規則を持つが、Search固有のsole facade規則を持たない

## 5. 目標構造

必要な責務だけを残し、最終形を次に揃えます。

```text
lib/features/search/
├─ port/
│  ├─ search.dart
│  ├─ reader/search_reader_port.dart
│  ├─ gateway/search_catalog_gateway.dart
│  ├─ query/search_query.dart
│  ├─ query/search_catalog_query.dart
│  ├─ model/search_direction.dart
│  ├─ model/search_conjugation_match.dart
│  ├─ model/search_result_item.dart
│  ├─ result/search_result_page.dart
│  ├─ result/search_catalog_page.dart
│  ├─ error/search_read_error.dart
│  ├─ error/search_catalog_gateway_error.dart
│  ├─ composition.dart
│  ├─ presentation_dependencies.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   │  ├─ search_reader.dart
   │  ├─ search_result_assembler.dart
   │  └─ search_enrichment_policy.dart
   ├─ domain/
   │  └─ search_direction_policy.dart
   ├─ presentation/
   │  ├─ components/
   │  ├─ provider/
   │  ├─ ui_model/
   │  ├─ view_model/
   │  └─ view/
   └─ composition/
      └─ search_composition_factory.dart

lib/integration/catalog_search/
├─ catalog_backed_search_gateway.dart
└─ catalog_search_providers.dart
```

file分割は責務の大きさに合わせて調整してよいですが、公開contract、technical seam、internal
実装の3境界は維持します。

## 6. Public contract

### 唯一のbusiness facade

`port/search.dart`が次だけを明示的にexportします。

- `SearchReaderPort`
- `SearchQuery`
- `SearchDirection`
- `SearchResultPage`、`SearchResultItem`、活用候補item
- `SearchConjugationMatchKey`と必要なtyped value
- `SearchReadError`とtyped warning／issue
- integrationが実装する`SearchCatalogGateway`とそのquery／result／error
- 共有identityとして利用するCatalog facade由来の`CatalogWordRef`は、Searchから再exportせず、
  利用者がCatalog facadeからimportする

`composition.dart`、`presentation_dependencies.dart`、`presentation_entry.dart`はtechnical seamとし、
business facadeからre-exportしません。

### Query validation

- `SearchQuery`はtrim済みで空でないtext、`page >= 0`、`size > 0`を生成時に保証する
- invalid queryは`ArgumentError`でfail-fastし、実行時I/O failureと混同しない
- `includeConjugationSuggestions`を公開callerが決める必要があるかを見直す。Search画面専用policyなら
  application inputから除き、Search内部でdirection／pageに基づいて決める
- required-port用`SearchCatalogQuery`も自身のpage／size／text invariantを保証する
- collection／mapを受ける公開DTOはdefensive copyする

### Result、identity、absence

- item identityは`CatalogWordRef`だけとし、派生可能なraw `wordId`を削除する
- empty collectionは`Result.success(SearchResultPage(items: [], ...))`とする
- optional metadataが存在しない場合は`null`、reader failureはtyped warningとして区別する
- primary read failureはtyped `SearchReadError`、enrichment failureはtyped `SearchIssue`とする
- issue sourceはenumまたはsealed typeにし、任意文字列を許可しない
- 公開errorのfield型を`AppError`にせず、Search-owned error／causeとして閉じる
- resultに検索方向を明示し、空page時に先頭itemから方向を推測しない

### Required port

`SearchCatalogGateway`はSearch use caseが必要とするprovider-neutralな能力だけを持ちます。

- primary hit page
- conjugation hit page
- word batchに対するmeaning
- word batchに対するfrequency
- word batchに対するranking metadata

各operationのfailure単位は維持します。gatewayはwarning化、活用候補の表示条件、表示件数を
決めません。使用していないheadwordをmetadata DTOへ含めず、operationとDTOを実際の要求に
合わせます。Catalogの`CatalogWordRef`以外のmodelはSearch required-port DTOへ流用しません。

## 7. Application flow

新しいSearch readerは次の順に処理します。

1. validation済み`SearchQuery`を受け取る
2. Catalog gatewayからprimary pageを取得する
3. primary failureを`SearchReadError`へ正規化し、そこで処理を終了する
4. primary itemの`CatalogWordRef`をbatch化し、必要なmeaning／frequency／rankingを取得する
5. enrichment failureをfailure単位を保った`SearchIssue`へ変換し、成功した基本itemを返す
6. 西日、page 0、候補有効の条件を満たす場合だけ活用候補を取得・enrichする
7. Search-owned DTOへprojectionし、Catalogの`hasMore`をそのまま`hasNext`へ渡す
8. issueを決定済みの順序で返し、presentationがwarningとして表示する

方向判定はpureな`SearchDirectionPolicy`へ集約し、presentationはその結果をqueryへ渡します。
正規表現の失敗をI/O failureとして扱わず、判定規則そのものをunit testで固定します。

## 8. Integration、composition、presentation

### Catalog integration

- pure adapterはCatalog facadeとSearch facadeだけをimportする
- `CatalogId` mappingはadapter内のexhaustive switch一か所に限定する
- 活用match変換はenum indexを使わず、全variantを明示的にmappingする
- Catalog errorはoperationをtyped valueで保持した`SearchCatalogGatewayError`へ変換する
- adapter testでpage、`hasMore`、`CatalogWordRef`、match、optional metadata、cause／stackを固定する
- `catalog_search_providers.dart`だけがRiverpodとapp-owned Catalog providerを利用する

### Composition

- `internal/composition/search_composition_factory.dart`がrequired gatewayからSearch readerを構築する
- `port/composition.dart`はinternal factoryを呼ぶcontrolled seamだけを公開する
- `port/presentation_dependencies.dart`はpresentationに必要なSearch readerだけをRiverpodへ接続する
- `app/bootstrap`がCatalog composition、integration adapter、Search composition、overrideを組み立てる
- Riverpod `Ref`やservice locatorをSearch applicationへ渡さない

### Presentation／routing

- `SearchViewModel`はquery generation、page identity、retry target、request fenceを引き続き所有する
- direction regexはpure policyへ移し、ViewModelからloggingを伴う例外fallbackを除く
- `SearchResults`はresultが持つ明示的directionを使い、itemの有無から推測しない
- warning retryはprimary page retryと区別し、現行どおり全体reloadする仕様をtestで明示する
- `SearchFragment`のcallbackは`CatalogWordRef`とoptional display hintだけを渡す
- app routerだけがWordDetail／Quiz route contractへ変換する
- Flutter entryは`port/presentation_entry.dart`の`SearchFragment`だけに限定する

## 9. 段階的な実装計画

### Phase 0: ADRとcharacterization

1. ownership matrixと共有identityをSearch ADRへ記録する
2. 現行27 testを、contract／application／presentation／acceptanceの責務別に整理する
3. 方向判定、活用候補件数、warning順序、missing metadata、exact-size pageを追加testで固定する
4. 現行の「4件取得／2件表示」を維持するか、別仕様変更にするか決定する
5. `dart analyze lib/features/search lib/integration/catalog_search`の13 errorが未参照legacy由来で
   あることを追跡項目に記録する

完了条件: 維持する挙動と意図的に変える挙動がADRとtest名で区別されている。

### Phase 1: Public contractの完成

1. `port/search.dart`を追加し、公開型を明示的にexportする
2. query／result／gateway／reader／errorを責務別directoryへ整理する
3. constructor validation、immutability、typed issue／error、explicit directionを導入する
4. raw `wordId`、raw issue source、generic `AppError` field、`SearchGatewayError` typedefを廃止する
5. Search port contract testをfacade importだけへ切り替える

完了条件: business facadeがpure Dartで、validation、absence、identity、errorのcontract testが通る。

### Phase 2: Application縦スライス

1. `InternalSearchReaderPort`を`internal/application`へ移し、projectionとpolicyを分割する
2. blank validationの重複を除き、invalid DTOとruntime failureを分ける
3. direction、enrichment、suggestion eligibility、warning orderingをSearch-owned policyとして実装する
4. primary、empty、各enrichment failure、日西、西日、paging境界のparity testを実行する

完了条件: 旧readerと同じfixtureでitems、suggestions、`hasNext`、issuesが一致する。

### Phase 3: Catalog adapterの契約切替

1. adapterを新Search facadeのrequired portへ切り替える
2. unused headword metadataを除き、frequency operationをfocused contractにする
3. enum index mappingをexhaustive mappingへ置き換える
4. DTO、identity、error、stack、pagingのpure adapter testを追加する

完了条件: adapterが両featureのfacadeだけをimportし、Search policyやframeworkを含まない。

### Phase 4: Presentation縦スライス

1. ViewModel／UI modelを新reader、typed result、explicit directionへ切り替える
2. direction判定をpure policyへ集約する
3. page 0、append、retry、query reset、same-page dedupe、late completion、dispose testを維持する
4. widget／Gate B acceptance testのbusiness型importをSearch facadeへ切り替える
5. technical seamから公開するentry／dependencyとcallback payloadをtestで固定する

完了条件: Search画面が旧use case／旧DI／個別port定義fileを参照しない。

### Phase 5: Composition切替とlegacy削除

1. app bootstrapと`catalog_search_providers.dart`を新compositionへ切り替える
2. `JudgeSearchWord*`、`ISearchWordUseCase`、`SearchWordInteractor`、旧DI providerを削除する
3. 未参照の旧Search card群と`reverse_curve.dart`を削除する
4. `port/query.dart`、旧path、typedef shim、重複modelを削除する
5. productionとtestの全参照が0であることを`rg`で確認する

完了条件: Search対象の`dart analyze`が0 issueで、legacy shimと壊れたimportが残らない。

### Phase 6: Boundary checkerと文書化

1. feature外のbusiness codeからSearch `internal/**`へのimportを禁止する
2. feature外のbusiness codeからSearchの個別`port/**`へのdeep importを禁止する
3. `composition.dart`はapp bootstrap／Catalog-Search wiring、`presentation_dependencies.dart`は
   bootstrap／same-feature presentation、`presentation_entry.dart`はapp routing／acceptance testだけに許可する
4. Search business portからFlutter、Riverpod、Drift、Firebase、GoRouterへのimportを禁止する
5. `lib/integration/catalog_search`からfeature internal／DAO／SDKへのimportを禁止する
6. Search internalから他feature internal／presentation entryへのimportを禁止する
7. checker fixture、Search ADR、Search public surface manifestを最終実装に合わせる

完了条件: checkerが各禁止fixtureを検出し、repository内のSearch境界違反が0になる。

## 10. テスト計画

### Port contract

- blank text、negative page、zero sizeのfail-fast validation
- DTO list／mapのdefensive copy
- empty page、optional metadata、typed primary failure、typed partial issue
- `CatalogWordRef`のidentity保持とraw ID重複の不在
- explicit directionとpaging情報の保持

### Search application

- 西日／日西の方向判定文字境界
- primary failureだけが全体failureになること
- meaning／frequency／ranking／conjugation failureごとのfallbackとissue
- 日西でSpanish-only gatewayを呼ばないこと
- 活用候補のpage／direction／enabled条件
- exact-size最終pageと`hasMore`ありpageの伝播
- warning順序とmissing batch key

### Integration adapter

- Catalog page／hit／metadataからSearch DTOへの変換
- 全活用match variantのexhaustive mapping
- `CatalogWordRef`と`hasMore`の保持
- Catalog errorからSearch gateway errorへの変換とcause／stack保持
- empty batch、missing key、unexpected exception

### Presentation／acceptance

- page 0 replace、後続append、stable identity dedupe
- failed-page retry、same-page in-flight dedupe、generation fence、dispose fence
- query変更時に旧結果を表示しないこと
- empty、primary error、warning付きdataの表示とretry
- public presentation entryから検索、scroll、retry、navigation callbackまでのGate B test

## 11. 検証順序

各phaseではfocused testを先に実行し、最終phaseで次の順に確認します。

1. Search port／application／presentation unit test
2. `catalog_search` pure adapter test
3. Search widget testとGate B acceptance test
4. feature dependency／import boundary checker
5. `dart analyze lib/features/search lib/integration/catalog_search`
6. repository全体の`dart analyze`
7. repository全体の`flutter test`

Flutter／Dart commandはrepositoryの`AGENTS.md`に従いsandbox外で直接実行します。

## 12. Scope外

- Catalog DB schema、index、SQL検索方式の変更
- LIKE wildcard／escaping semanticsの変更
- Catalog asset、sync、serialization protocolの変更
- 検索結果のranking／frequency計算変更
- 新しいfilter、sort、suggestion種別の追加
- UIデザイン、文言、route path、deep linkの変更
- WordStatus表示／write操作のSearch画面への追加
- debounce、全文検索、cursor paging等の性能機能追加

必要になった場合は、構造リファクタと分離したADR／migrationとして扱います。
