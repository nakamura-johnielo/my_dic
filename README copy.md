# **Index**
<details>
<summary>目次</summary>

1. [**Summary**](#overview)<br>
    1-1. [web版デモアプリ](#demo) <br>
    1-2. [技術スタック](#tech-stack) <br>
    1-3. [アーキテクチャ](#architecture) <br>
    1-4. [対応プラットフォーム](#supported-platform)
4. [**主要機能**  ](#key-features) <br>
    4-1. 検索 <br>
    4-2. 同期 <br>
    4-3. 学習機能 <br>
    4-4. 辞書
5. [**技術ハイライト** ](#engineering-highlights) <br>
    5-1. Clean Architecture  <br>
    5-2. Riverpod StreamProvider  <br>
    5-3. Provider スコープ最適化<br>
    5-4. Drift Migration  <br>
    5-5. Python 効率化CLI  
6. [**フォルダ構成図**](#architecture)
7. [**使用技術**](#tech-stack)
8. [**開発支援 (CLI / Python）**](#tooling)
9. [**Data Preparation（辞書データ生成 / Python）**](#)
10. [ **Technology Transition（技術選定の変遷）**](#)
11. [ **In Development（開発中機能）**](#)
12. [ **Motivation（開発動機）**](#)
13. [ **Challenges & Learnings（課題と学び）**](#)
14. [ **Setup（セットアップ方法）**](#)
15. [ **License（ライセンス）**](#)
16. [ **Contact（連絡先）**](#)

</details>

## Import-boundary check
TODO: コマンドライン省略化
Architecture import rules are checked locally and in CI:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
```

See [the import-boundary guide](docs/architecture/import-boundaries.md) for
rules and baseline updates.

## Firestore Emulator rules test

The sync remote schema and Firestore Rules are checked separately from the
Flutter unit suite.  Install the Node test dependencies, then run the Auth and
Firestore emulators together:

```powershell
npm --prefix firebase-tests ci
Push-Location firebase-tests
npx --yes firebase-tools@13.35.1 --config firebase.json emulators:exec --project my-dic-sync --only auth,firestore "npm test"
Pop-Location
```

This requires Java 21 or later. The `firestore-emulator` CI job uses the same
command, including the production `firestore.rules` file loaded by the test
harness.


---


# 1. **Overview** <a id="overview"></a>

**多様な検索方法と学習方法・リアルタイム同期** を提供する、<br>
**スペイン語学習特化Flutterアプリ**です。

**対応プラットフォーム**： Android / Windows / Web

[➥Web版デモアプリ (https://my-dic-flutter-portfolio.web.app/)](https://my-dic-flutter-portfolio.web.app/) <br>
web用に最適化していないため少々重いです。

<div style="display:flex; gap:12px;">
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
</div>

<div style="display:flex; gap:12px; margin-top:12px; ">
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
  <img src="https://dummyimage.com/270x400/cccccc/000000&text=App+Demo+Screen" width="200" />
</div>

## デモアプリ <a id="demo"></a>
[➥Web版デモアプリ (https://my-dic-flutter-portfolio.web.app/)](https://my-dic-flutter-portfolio.web.app/)

web用に最適化していないため少々重いです。

## 技術スタック  <a id="tech-stack"></a>
- Flutter / Dart
- Riverpod（状態管理・DI）
- GoRouter（ルーティング）
- Drift（SQLite / IndexDb）
- Firebase（Auth / Firestore）
- Python（データ整備 / CLI）

## アーキテクチャ  <a id="architecture"></a>
- Clean Architecture
- Feature Module
- MVVM
- CQRS

---

# 2. **主要機能**  <a id="key-features"></a>

### 🔍 **検索**

- フィルタ
    - 一致 / 除外
    - 品詞・ステータス・重複の ON/OFF
- 1つの検索窓からマルチに検索可能
    - 日本語 -> スペイン語
    - スペイン語 -> 日本語
    - 変化形 -> 原形
- ページネーション + 無限スクロール
    

### 🔄 **同期**

- Firebase Authenticationでユーザー管理
- Firestore によるデバイス間同期


### 🧩 **学習機能**

- ブックマーク / 学習済み管理
- myWord の登録
- フラッシュカードでのクイズ機能
- 単語頻出順ランキング


### 📚 **辞書**

- 語義・品詞・例文・イディオム表示
- 動詞の語形変化一覧
    

---

# 3. **技術ハイライト** <a id="engineering-highlights"></a>

### **1. Feature Module x Clean Architecture による高い拡張性**

- 変更、機能追加に強い構造
- 保守性、拡張性、責務を意識して分離
    

### **２. Stream × CQRS でリアルタイム更新＆パフォーマンス最適化**

- localをidごとにwatchし、UiStateとしてUIへ反映
- remoteを変更追加のみ通知を得る用にwatchし、同期用に使用
- 状態(stream -> UiState <- UI)と操作(command)を完全分離し、責務を明確化


### **3. Result型でエラーハンドリング**

- エラー型とResult型を定義してエラーハンドリング
- UsecaseとrepositoryがResult型を返す


### **4. Drift Migration による無停止スキーマ更新 & web対応IndexDB化**

- ユーザーデータを保持したまま DB 更新が可能
- バージョンごとにデータ、テーブルの操作
- web対応のためDBのIndexDB化とimport処理へも対応

### **5.Python によるデータ整備 & 自動生成 CLI**

- スクレイピングと正規表現解析で辞書用データ抽出
- clean architecture用のフォルダファイル自動生成CLIの制作で、デメリットである開発時の手間を軽減

    
---


# 4. **フォルダ構成(簡略)** <a id="architecture"></a>

```
lib/
 ├── core/
 │    ├── di/
 │    ├── application/
 │    ├── infra/
 │    ├── domain/
 │    ├── presentation/
 │    └── shared/
 ├── features/
 │    ├── ranking/
 │    │     ├── di/
 │    │     ├── data/
 │    │     ├── domain/
 │    │     └── presentation/
 │    ├── quiz/
 │    ├── word_page/
 │    └── search/
 └── shared/
```

Feature-Modular × Clean Architecture による拡張可能な構成。

---

# 5. **Tech Stack** <a id="tech-stack"></a>

### **App / Frontend**

- Flutter / Dart
- Riverpod（DI・状態管理）
- GoRouter
- ThemeData（カラースキーム管理）
    
### **Database**

- Drift（ORM / Query Builder）
- SQLite（ローカル DB）
- IndexDB（Web用ローカル DB）
- Firebase Firestore（リモートDB）
    
### **Backend / Infrastructure**

- Firebase Authentication
- Firebase Firestore
    
### **Others**

- Python（スクレイピング / データ整形）
- Clean Architecture（責務分離）
- CQRS（コマンドとクエリの分離）
    

---

# 6. **開発支援ツール (CLI / Python）** <a id="tooling"></a>

- フィル名とタイプからフォルダとファイルを自動生成する  **Clean Architecture 用テンプレ生成 CLI（Windows）** を作成  
- 設定ファイルに、責務タイプ、ファイル名を記入（他にも細かい設定あり）


---

# 📦 **Data Preparation（辞書データ生成プロセス / Python）**

アプリ実装とは独立した**データ準備工程**です。
- Webスクレイピング（Python + selenium）
- 正規表現で語義・品詞・例文を解析し構造化
- SQLite スキーマへ整形

---

# **技術選定の遷移**

- 初期版：Android / Java で辞書アプリを構築
- → パフォーマンスの観点から Room + Kotlin を検討
- → desktopでもアプリを使いたかった & 複数デバイスで使いたかった
- → マルチプラットフォーム対応 **Flutterに移行**
    
ベストプラクティスを求めた結果、いちから学びなおすなら「desktopとmobile両方対応で、前から興味があったflutterに乗り換えよう！」と決意

---


# **開発中** <a id="in-development"></a>

- 動詞「時制 × 主語」指定の例文検索
- 例文中の単語タップ → 辞書へジャンプ
- 忘却曲線アルゴリズムによるリマインド通知
- 例文検索 / イディオム検索
- AI を用いたスラング辞書生成
- ~~myWord 同期~~
- オフライン同期プロセス強化
- 検索アルゴリズム改善
- 検索履歴
    

---

# 🎯 **動機** <a id="motivation"></a>

スペイン語動詞は **主語 × 時制** の組み合わせにより  
1動詞あたり **約50形態** を覚える必要があります。
しかし、

- 変化形から原形の検索
- 辞書
- 語形変化一覧

が統合されたサービスは存在しなかったため、ネットで変化形から原形を特定し、その原形の意味と語形変化表を検索するのが手間でした

そこで、 **「学習と無関係な部分での挫折をなくす」** 体験を構築する ことを目的に開発を開始しました。
    

---

# 🧩 **Challenges & Learnings**

### **Clean Architecture の運用**

ファイル責務の明確化に苦労したが、「変更追加に強い」構造を実感し開発が安定。

### **CQRS と StreamProvider の組み合わせ**
状態と操作の完全分離で、リアルタイム更新とパフォーマンス最適化を両立できた。

### **StreamProvider のリアクティブ設計**

手動 DB 問い合わせから脱却し、リアルタイムアプリの設計に自信がついた。


---

# ✉️ **Contact**

📩 [nakamura.johnielo@gmail.com](mailto:nakamura.johnielo@gmail.com)  



