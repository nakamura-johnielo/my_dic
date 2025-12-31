# my_dic — 詳細ドキュメント

## 概要
このドキュメントは技術担当者向けの詳細情報をまとめたものです。アーキテクチャ、主要ファイル、セットアップ手順、テスト、データ整備手順を含みます。

## 技術スタック
- Flutter / Dart
- Riverpod（状態管理・DI）
- GoRouter（ルーティング）
- Drift（SQLite）
- Firebase（Auth / Firestore）
- Python（データ整備 / CLI）

## アーキテクチャ
Feature-modular + Clean Architecture（Domain / Data / Presentation）を採用。

簡易構成例:
- `lib/core` : 共通インフラ（DB, DI, 共通ユーティリティ）
- `lib/features` : 機能モジュール（search, conjugation, my_word, ranking など）

主要ファイル:
- [lib/main.dart](lib/main.dart#L1) — アプリエントリ、Firebase 初期化
- [lib/router.dart](lib/router.dart#L1) — ルーティング定義 (GoRouter)
- [lib/core/di/data/data_di.dart](lib/core/di/data/data_di.dart#L1) — データ層 DI 設定
- [lib/core/infrastructure/database/drift/database_provider.dart](lib/core/infrastructure/database/drift/database_provider.dart#L1) — Drift DB 定義
- [pubspec.yaml](pubspec.yaml#L1) — 依存関係とアセット一覧

### アーキテクチャ図（概要）
以下は簡易ASCII図です。必要であれば PlantUML / PNG を追加します。

```
Client (Flutter UI)
	├─ Presentation (widgets / screens)
	│    └─ features/*/presentation
	├─ Domain (usecases / entities)
	│    └─ features/*/domain
	└─ Data (repositories / datasources)
			 ├─ core/infrastructure (Drift DB)
			 └─ core/infrastructure/firebase (Firestore sync)

DI: `lib/core/di` で依存注入（Riverpod/get_it）を組立て
```

（画像を追加する場合: `docs/architecture/architecture.png` を配置）

### 主要クラス図（参照あり）
以下は技術担当が早く把握できるように主要なクラス／ファイルと役割を列挙します。
- `lib/main.dart` — アプリ開始点、`ProviderScope` と `Firebase.initializeApp()` の起点 ([lib/main.dart](lib/main.dart#L1))
- `lib/router.dart` — 画面遷移・認証リダイレクト ([lib/router.dart](lib/router.dart#L1))
- `lib/core/infrastructure/database/drift/database_provider.dart` — Drift の DB 定義、テーブル／DAO の登録 ([lib/core/infrastructure/database/drift/database_provider.dart](lib/core/infrastructure/database/drift/database_provider.dart#L1))
- `lib/core/di/data/data_di.dart` — リポジトリ・データソースの注入設定、テスト時の差替えポイント
- `lib/features/search/presentation` — 検索画面の UI・検索ロジックの入り口（`search_fragment.dart` 等）
- `lib/features/conjugation` — 動詞語形変化とクイズ関連のドメイン/データ実装

（必要なら PlantUML 形式の `.puml` を追加して視覚化できます）

## テスト実行例
ローカルでの確認手順を示します。テストはユニットとウィジェットがあります。

1) すべてのテストを実行

```bash
flutter test
```

2) 特定ディレクトリのテスト（ユニット）

```bash
flutter test test/unit
```

3) ウィジェットテスト（個別ファイル実行の例）

```bash
flutter test test/widget/my_widget_test.dart
```

4) テスト実行時の注意
- Firebase を参照するテストはフェイク実装（`test/helpers`）を利用してください。
- DB（Drift）に接続するテストは一時的な in-memory DB を使うと安定します。

## 図／スクリーンショット追加ポイント
- `docs/screenshots/home.png` — ホーム画面
- `docs/screenshots/search.png` — 検索結果
- `docs/architecture/architecture.png` — アーキテクチャ図

---
追記: このファイルに PlantUML ファイルや画像を追加して私に指示いただければ、README 内の埋め込み位置を整備します。

## セットアップ（ローカル）
**前提**: Flutter SDK と Dart がインストール済み。Firebase プロジェクト・設定ファイル（`PRIVATES` に格納）が必要。

1. 依存取得

```bash
flutter pub get
```

2. Firebase 設定
- `PRIVATES` 配下に Firebase の設定ファイル（非公開）を配置します。Web 版は Firebase コンソールの設定を使用します。

3. DB シード（Web 用）
- `data/` にある JSON を利用して Web の seed を生成しています。必要であれば `scripts/export_db_to_json.dart` を参照してください。

4. 実行

```bash
flutter run
```

## テスト
- `test/unit` と `test/widget` にユニット／ウィジェットテストがあります。フェイク実装は `test/helpers` を参照。
- CI 設定（GitHub Actions 等）は含まれていません。CI を追加する場合は `flutter test` を実行する workflow を作成してください。

## データ整備
- Python スクリプトでスクレイピングと正規表現により辞書データを構築しています（詳細は `PRIVATES` の手順や `scripts/` を参照）。
- 自動生成 CLI は Clean Architecture の雛形を作成するための補助ツールです。

## 注意点（公開リポジトリ化する場合）
- `PRIVATES` フォルダ内に認証情報や設定ファイルが含まれる可能性があります。公開する際は除外してください。

## スクリーンショット（プレースホルダ）
- docs/screenshots/home.png
- docs/screenshots/search.png
- docs/screenshots/quiz.png

## コンタクト
- 開発者: email@example.com

---
更新履歴: README を採用向け短縮版 + 技術詳細版に分割しました。必要なら英語版も作成します。