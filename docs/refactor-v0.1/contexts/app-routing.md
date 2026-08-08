# App and Routing Map

最終更新: 2026-08-06

## Top-level

| file | 責務 | 状態 |
| --- | --- | --- |
| `lib/main.dart` | Flutter binding初期化後、`AppBootstrap`を起動 | 薄いentry point。`MyApp`を直接起動しない |
| `lib/firebase_options.dart` | FlutterFire CLI生成のFirebase設定 | 生成系。手編集は慎重に扱う |
| `lib/main_activity.dart` | `StatefulShellRoute`のnavigation shellを受け、bottom nav付きメイン画面を描画 | Router/tab state整理の対象 |
| `lib/native_API/android/keyboard_helper.dart` | Android keyboard操作のplatform channel helper | 小さいplatform境界。命名は`native_API`で旧式 |

## `lib/app`

| file | 責務 | 状態 |
| --- | --- | --- |
| `app/app.dart` | `MaterialApp.router`、theme、`DatabaseLoadingOverlay`を組み立てるroot widget | 描画寄り。Routerは`app/routing/router.dart`経由 |
| `app/bootstrap/app_dependencies.dart` | `AppDependencies`、Firebase initializer、SharedPreferences loader、bootstrapper | ProviderScope前の依存だけを持つ |
| `app/bootstrap/bootstrap.dart` | 起動Future、ProviderScope override、DB readiness、bootstrap loading/error UI | DB I/Oとeffect起動が残る移行途中 |
| `app/bootstrap/lifecycle_effects.dart` | auth effect、legacy auto sync、lifecycle observer、sync scheduler生成 | 横断effectの単一起動点として育てる |
| `app/bootstrap/sync_composition.dart` | Drift queue/checkpoint/outbox、session fence、single-flight、SyncEngine、SyncSchedulerのprovider | 新同期基盤の足場。handler registryは空 |
| `app/routing/contracts/route_parse_result.dart` | route parseの成功/失敗Result | 強制cast回避用のpure contract |
| `app/routing/contracts/word_detail_route.dart` | `word/:wordId?type=&hasConj=`のURL contract | WordPageへの共有契約 |
| `app/routing/contracts/quiz_game_route.dart` | `quiz-game/:wordId?word=`のURL contract | QuizGameへの共有契約。将来はwordをID再取得へ寄せる候補 |
| `app/routing/invalid_route_page.dart` | route parse失敗時の表示 | deep link/refreshのerror route |
| `app/routing/router.dart` | `lib/router/router.dart`のexport | 参照方向を先に固定するbridge |

## `lib/router`

| file | 責務 | 状態 |
| --- | --- | --- |
| `router/router.dart` | GoRouter本体、navigator keys、auth redirect、StatefulShellRoute定義 | 旧routingの中心。将来`app/routing`へ寄せる |
| `router/route_names.dart` | route name/path定数 | URL構造の旧正本 |
| `router/navigator_service.dart` | ViewModelからGoRouterへ遷移するservice | `WordDetailRoute`/`QuizGameRoute`は利用済み。Ref保持はPhase 2-4対象 |
| `router/study.dart` | dashboard/ranking/quiz/flashCard route builder | contract parseは導入済み。route本体は旧場所 |
| `router/word_detail.dart` | word detail route builder | `WordDetailRoute.parse`でinvalidを`InvalidRoutePage`へ落とす |

## リファクタ時の注意

- `app/routing/contracts`はpure route contractであり、Widget/ViewModelを入れない。
- `app/routing/router.dart`はbridgeであり、GoRouter本体ではない。
- `router/navigator_service.dart`はViewModelから利用される現役経路なので、route移行前に消さない。
- tab位置のsource of truthはまだGoRouterと独自providerが混在している。