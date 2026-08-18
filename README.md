# My Dic

スペイン語の活用形から原形と意味を探し、そのまま学習・復習できるFlutter製の辞書アプリ

スペイン語は動詞の活用が多く、文章中で見つけた語形から原形へたどり着くこと自体が学習の障壁になります。日本語・スペイン語・活用形のいずれからでも検索できる辞書に、フラッシュカード、学習状態管理、複数端末同期を組み合わせ、学習障壁を下げることを目的としています。

## Screenshots

辞書データの公開範囲を制限しているため、現在はスクリーンショットのみの公開です。

<div>
  <img src="https://github.com/user-attachments/assets/4008e30b-9689-4567-afef-ecaab5491fc8" width="200" alt="検索画面" />
  <img src="https://github.com/user-attachments/assets/f9ee5e44-1032-46e5-9ff9-eddacb37a026" width="200" alt="検索結果画面" />
  <img src="https://github.com/user-attachments/assets/5031443d-af1d-466b-bfa6-e7bcf52599ac" width="200" alt="単語詳細画面" />
</div>

<div>
  <img src="https://github.com/user-attachments/assets/0a59e743-5450-4a25-bc20-5ff5c8e69900" width="200" alt="クイズ画面" />
  <img src="https://github.com/user-attachments/assets/a98baa2c-0c49-4de2-a9e7-67ca57440ee6" width="200" alt="ランキング画面" />
  <img src="https://github.com/user-attachments/assets/5f2f539a-16c5-4c4d-aa07-ab0ce3396b55" width="200" alt="プロフィール画面" />
</div>

## デモ
デモ用にWeb版を公開しています。<br>
~~[➥Web版デモアプリ ]()~~ <br>
ローカルファーストで動作するため初期DBデータインストールに数秒かかります。<br>
※辞書データの公開が制限されているため、デモの共有を停止しています。


## 技術ハイライト
- nativeAPIを用いて、Androidのオートフォーカス＆キーボード表示を実現
- Riverpodを用いた状態管理と、Composition Rootでの型安全な依存性注入
- Feature単位のモジュール分割と、公開API（`port`）による依存方向の制御
- DriftとFirebaseを組み合わせたLocal-first / Offline-firstなデータ同期
- Unit・Widget・Integration・Securityテストによる継続的な品質確認

## 主な機能

- 日本語・スペイン語の双方向検索
- 活用後の語形から原形を検索
- 単語の意味・用例・動詞活用の表示
- フラッシュカード形式の活用クイズ
- ブックマークと学習済みステータスの管理
- スラングやフレーズを含むユーザー辞書への単語追加
- Firebase Authenticationによるアカウント管理
- 学習データのオフライン編集とFirestore経由の複数端末同期
- 学習状況のランキング表示

## 技術スタック

| 領域 | 技術 | 採用理由 |
| --- | --- | --- |
| UI / マルチプラットフォーム | Flutter / Dart | 単一コードベースでAndroid・Windowsへ展開するため |
| 状態管理 / DI | Riverpod | UI状態と依存関係を型安全に管理し、テスト時に差し替えやすくするため |
| ルーティング | GoRouter | 画面遷移を宣言的に管理するため |
| ローカルDB | Drift / SQLite / IndexedDB | 型安全なクエリと、Native・Web双方でのオフライン利用を実現するため |
| 認証 / クラウド | Firebase Authentication / Cloud Firestore | アカウント単位のデータ保存と複数端末同期を実現するため |
| モデル / Serialization | Freezed / json_serializable | Immutableなモデルと変換処理を安全に実装するため |
| 品質管理 | flutter_test / mocktail / dart_code_linter | レイヤーごとのテストと静的解析を自動化するため |

## アーキテクチャ

機能追加による変更範囲を限定するため、`search`、`quiz`、`my_word`、`sync`などのFeature単位でモジュールを分割しています。

各Featureは、外部へ公開する契約を置く`port`と、具象実装を置く`internal`に分離しています。他Featureは相手の`internal`やDBの行型を直接参照せず、`port`の純粋なDartインターフェースを介して連携します。Feature間のデータ変換は`integration`配下のAdapterが担当します。


<img  alt="project layer dependencies" src="https://github.com/user-attachments/assets/1f70cf58-0ce7-4009-86fa-9c2281fb09df" />

### ディレクトリ構成

```text
lib/
├── app/          # 起動、ルーティング、セッション、Composition Root
├── features/     # 機能単位の公開契約・業務ロジック・UI・データアクセス
├── integration/  # Feature間を接続するAdapterとProvider
└── core/         # DB、ログ、共通エラーなどの横断的な基盤
```

Feature内部は主に次の責務へ分けています。

- `Presentation`: Widget、画面状態、ユーザー操作
- `Application`: ユースケースの実行と処理の調整
- `Domain`: 業務ルールと値オブジェクト
- `Infrastructure`: Drift、Firebaseなど外部技術との接続

処理の基本方向は`Presentation → Application → Domain / Infrastructure`です。DB行やFirebase SDKの型を上位レイヤーへ漏らさず、公開DTOや`Result`型へ変換します。RiverpodはPresentationとCompositionで使用し、業務ロジックはProviderへ直接依存させていません。

依存ルールは文書化するだけでなく、専用のImport Boundary CheckerとFeature Dependency Checkerで検査できます。設計判断の経緯はADRとして記録しています。

- [Feature設計ルール](docs/architecture/feature-design-rules.md)
- [Import Boundary](docs/architecture/import-boundaries.md)
- [Architecture Decision Records](docs/architecture/decisions/README.md)

## Offline-first同期

通信状況にかかわらず操作を完了できるよう、編集内容は先にローカルDBへ保存し、同じトランザクションで送信待ちのOutboxへ追加します。同期時に変更をFirestoreへ送信し、その後に他端末の変更を取得します。

```mermaid
flowchart LR
    Edit[ユーザー操作] --> Local[(Driftへ保存)]
    Local --> Outbox[Outboxへ追加]
    Outbox --> Push[Firestoreへ送信]
    Push --> Complete[成功項目を完了]
    Complete --> Pull[サーバーの差分を取得]
    Pull --> Apply[端末へ反映]
    Apply --> Cursor[取得位置を保存]
```

同期処理では、実運用で起こり得る中断や競合も考慮しています。

- 送信中の項目へLeaseを付与し、アプリ終了後も期限切れで再送可能にする
- 版番号を確認し、古い送信結果で新しい編集を完了扱いにしない
- 未送信のローカル編集をサーバー取得結果で上書きしない
- Exponential Backoffで再試行し、継続的に失敗する項目はDead Letterへ隔離する
- 同期要求を直列化し、処理中の追加要求は完了後に一度だけ再実行する
- ログアウトやアカウント切替時に処理を中止し、異なる利用者のデータ混在を防ぐ

各Featureは同期対象の変換と保存に集中し、再試行、順序制御、Outbox管理などの共通処理は`sync` Featureへ集約しています。

## テストと品質管理

`test/`配下には、現在138本のテストファイルがあります。

| カテゴリ | ファイル数 | 主な対象 |
| --- | ---: | --- |
| Unit | 110 | Domain、UseCase、Repository、同期制御 |
| Widget | 13 | 画面表示、入力、Riverpodによる状態遷移 |
| Integration | 12 | Feature間連携、DB互換性、主要ユーザーフロー |
| Security | 1 | 認証情報などのセンシティブなログ出力防止 |
| Tool | 2 | アーキテクチャ境界チェッカー |

現在、`flutter analyze`はエラーなしで通過します。`flutter test`はFeature公開APIのリファクタリングに対して一部のテストコードが未追従のため、テスト側の旧import・旧型名を更新中です。

GitHub Actionsでは、次の処理をPush / Pull Requestごとに実行します。

1. `flutter analyze`
2. `flutter test`
3. Firebase Emulatorを用いたAuthentication / Firestore Security Rulesの検証

ローカルでは追加で依存境界を検査できます。

```bash
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
dart run tool/check_feature_dependencies.dart
```

## セットアップ

辞書データを公開していないため、この以下の手順のみでは動作しません。

### 動作確認環境

- Flutter 3.38.9（stable）
- Dart 3.10.8
- 対象: Web / Android / Windows

### 実行

```bash
flutter pub get
flutter run 
```


## 今後の改善

- UI/UX作り直し
- navigation作り直し
- 命名規則と共通基盤（`core`）の責務整理
- Feature公開APIの変更に対する既存テストの追従
- 動詞の「時制 × 主語」を指定した例文検索
- 例文中の単語から辞書詳細へ移動できる導線
- 忘却曲線を考慮した復習リマインド
- 例文・イディオム検索と検索履歴
- 検索アルゴリズムの精度・速度改善


