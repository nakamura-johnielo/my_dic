# Web Database Seeding Guide

## Overview

このプロジェクトはWeb対応のために、SQLiteデータベースをGzip圧縮JSONに変換してIndexedDBにインポートする戦略を採用しています。

## アーキテクチャ

### Mobile/Desktop
- **Storage**: File-based SQLite (NativeDatabase)
- **Data**: Assets内の.dbファイルをそのままコピー
- **Size**: ~180MB (非圧縮)

### Web
- **Storage**: IndexedDB (WebDatabase via Drift)
- **Data**: Gzip圧縮JSON → 初回起動時にIndexedDBにインポート
- **Size**: ~20MB (圧縮時) → ~140MB (IndexedDB展開後)

## ビルド手順

### 1. データベースのJSONエクスポート

Web向けビルドの前に、最新のデータベースをJSONに変換:

```bash
# Gzip圧縮版を生成（推奨）
dart scripts/export_db_to_json_compressed.dart

# 出力:
# - assets/data/kotobank.json.gz (20.30 MB)
# - assets/data/es_en_conjugacions.json.gz (0.15 MB)
```

### 2. Web向けビルド

```bash
flutter build web --release
```

### 3. デプロイ

```bash
# Firebase Hosting
firebase deploy --only hosting

# または他のホスティングサービス
# build/web/ ディレクトリをデプロイ
```

## 初回起動フロー

1. ユーザーがWebアプリにアクセス
2. `DatabaseProvider` が `kIsWeb` を検出
3. `WebDatabase('my_dic_db')` でIndexedDBに接続
4. データベースが空の場合 (`onCreate` フック):
   - `WebDatabaseSeeder.seedFromJson()` を呼び出し
   - `assets/data/kotobank.json.gz` をロード
   - Gzip解凍 (20MB → 140MB)
   - JSONパース
   - Drift APIで全テーブルにバッチINSERT
5. 初回ロード完了（2-5分程度）
6. 以降はIndexedDBキャッシュを利用

## パフォーマンス

### 初回ロード時間（推定）
- **ダウンロード**: ~2-10秒 (20MB @ 2-10Mbps)
- **解凍**: ~5-15秒
- **パース**: ~10-30秒
- **INSERT**: ~60-180秒 (40万行以上)
- **合計**: ~2-5分

### 2回目以降
- IndexedDBから即座に読み込み（ミリ秒）

## ストレージ要件

### ブラウザごとのIndexedDB容量制限

| ブラウザ | デフォルト制限 | 最大容量 |
|---------|---------------|----------|
| Chrome | ディスク空き容量の60% | 制限なし（実質） |
| Firefox | ディスク空き容量の50% | グループごと2GB |
| Safari | 1GB | ユーザー承認で拡大可 |
| Edge | Chromeと同様 | 制限なし（実質） |

展開後のIndexedDBサイズ: **~140MB** (十分に余裕あり)

## トラブルシューティング

### エラー: "QuotaExceededError"

**原因**: ブラウザのストレージ制限を超過

**対策**:
1. ブラウザのキャッシュをクリア
2. 他のサイトのIndexedDBデータを削除
3. ディスク容量を確保
4. Chrome/Edgeを推奨（容量制限が緩い）

### エラー: "Failed to load asset"

**原因**: .json.gz ファイルがビルドに含まれていない

**対策**:
```bash
# JSONを再生成
dart scripts/export_db_to_json_compressed.dart

# pubspec.yamlにアセットが登録されているか確認
# flutter clean して再ビルド
flutter clean
flutter pub get
flutter build web
```

### 初回ロードが遅い

**正常**: 40万行以上のデータを処理するため2-5分かかります

**高速化オプション**:
1. Web Workerでバックグラウンド処理（将来の改善）
2. サーバー側でIndexedDBダンプを配信（高度）
3. 遅延ロード戦略（頻繁に使うデータのみ先行ロード）

## メンテナンス

### データベース更新時

1. `assets/*.db` を更新
2. エクスポートスクリプトを実行:
   ```bash
   dart scripts/export_db_to_json_compressed.dart
   ```
3. Webアプリを再ビルド・デプロイ
4. ユーザーはブラウザリロードで新バージョン取得

### スキーマ変更時

- `schemaVersion` を increment
- Migration処理を `onUpgrade` に追加
- Web環境でも自動的にマイグレーション実行

## ファイル構成

```
lib/core/infrastructure/database/drift/
├── database_provider.dart          # メインDB接続（プラットフォーム判定）
├── web_database_seeder.dart        # Web用シーディング実装
└── web_database_seeder_stub.dart   # モバイル/デスクトップ用スタブ

scripts/
├── export_db_to_json.dart                # 非圧縮JSON生成（デバッグ用）
└── export_db_to_json_compressed.dart     # Gzip圧縮JSON生成（本番用）

assets/data/
├── kotobank.json.gz                # メイン辞書（20MB圧縮）
└── es_en_conjugacions.json.gz      # 英語活用（0.15MB圧縮）
```

## セキュリティ考慮事項

- JSONファイルはpublicアセット → 辞書データは公開前提
- ユーザーデータ（my_words, word_status）はFirestoreで同期
- IndexedDBは同一オリジンのみアクセス可能

## 今後の改善案

1. **プログレスインジケーター**: 初回ロード進捗を表示
2. **チャンク分割**: 複数の小さなJSONに分割して段階的ロード
3. **Service Worker**: オフラインキャッシュ対応
4. **Web Worker**: メインスレッドをブロックしない処理
5. **差分更新**: 変更分のみダウンロード

---

Last Updated: 2025-12-26
