# **Index**

1. **Summary**
2. **Demo（デモ）**
3. **Overview（概要）**
4. **Key Features（主要機能）**  
    　4-1. 検索
    　4-2. 辞書
    　4-3. 頻出単語リスト  
    　4-4. 学習機能
    　4-5. 同期
5. **Engineering Highlights（技術的工夫）**  
    　5-1. Clean Architecture  
    　5-2. Riverpod StreamProvider  
    　5-3. Provider スコープ最適化
    　5-4. Drift Migration  
    　5-5. Python 効率化CLI  
6. **Architecture（構成図）**
7. **Tech Stack（使用技術）**
8. **Tooling（開発支援 CLI / Python）**
9. **Data Preparation（辞書データ生成 / Python）**
10. **Technology Transition（技術選定の変遷）**
11. **In Development（開発中機能）**
12. **Motivation（開発動機）**
13. **Challenges & Learnings（課題と学び）**
14. **Setup（セットアップ方法）**
15. **License（ライセンス）**
16. **Contact（連絡先）**
    

---


# 🌎 **Summary**

**多様な検索・語形変化学習・デバイス間リアルタイム同期** に対応した、  **スペイン語学習フロー最適化のための Flutter アプリケーション**です。

📱 **Multi-Platform（Android / Windows）**  
⚡ **Firebase × Drift × Riverpod × Clean Architecture**

---

## 🚀 **Demo（Sample）**

![demo-sample](https://dummyimage.com/800x400/cccccc/000000&text=App+Demo+Sample)

---

# 📘 **Overview**

スペイン語学習に必要となる  
**辞書／語形変化（逆引き）／暗記**  
を一つのアプリで完結させることを目的に開発しています。
アプリは **検索 → 辞書 → 語形変化 → 暗記** という学習フローを最適化するため、  
**UI・データ構造・アーキテクチャ**をゼロから設計しました。

---

# 🧰 **Key Features**

### 🔍 **検索**

- 日本語 ↔ スペイン語 双方向検索
- 語形変化した単語の逆引き
- 無限スクロール

### 📚 **辞書**

- 語義・品詞・例文・イディオム表示
- 動詞の語形変化一覧

### 📊 **頻出単語リスト

- 一致 / 除外フィルター
- 品詞・ステータス・重複の ON/OFF
- ページネーション + 無限スクロール
    

### 🧩 **学習機能**

- ブックマーク / 学習済み管理
- myWord の登録
- 動詞の語形変化クイズ
    

### 🔄 **同期**

- Firebase Authentication
- Firestore によるデバイス間同期
    

---
# 🧠 **Engineering Highlights**

### 🏗 **1. Clean Architecture による高い拡張性**

- 変更、機能追加に強い構造
- Domain / Data / Presentation の責務を徹底分離
    

### 🔄 **２. Riverpod × StreamProvider でリアルタイム更新**

- ブックマーク変更をアプリ全体へ即時反映
- UIはローカルのみを監視し、リモートの変更がローカルに変更されると自動でUIも更新。
- 手動での問い合わせの排除 → コード量削減 & バグ低減

### ⚡ **3. ListView 内 StreamProvider のパフォーマンス最適化**

- item 単位で provider をoverrideし、rebuild を最小化
- 大量データでも快適な UI を維持

### 🗄 **4. Drift Migration による無停止スキーマ更新**

- ユーザーデータを保持したまま DB 更新が可能
- バージョンごとにデータ、テーブルの操作

### ⚡ **5.Python によるデータ整備 & 自動生成 CLI**

- スクレイピングと正規表現解析で辞書用データ抽出
- clean architecture用のフォルダファイル自動生成CLIの制作で、デメリットである開発時の手間を軽減

    
---


# 🏗 **Architecture（Sample Structure）**

```
lib/
 ├── core/
 ├── features/
 │    ├── dictionary/
 │    │     ├── data/
 │    │     ├── domain/
 │    │     └── presentation/
 │    ├── conjugation/
 │    ├── bookmark/
 │    └── myword/
 └── shared/
```

Feature-Modular × Clean Architecture による拡張可能な構成。
## repositoryの実装例

---

# 🛠 **Tech Stack**

### **App / Frontend**

- Flutter / Dart
- Riverpod（DI・状態管理）
- GoRouter
- ThemeData（カラースキーム管理）
    
### **Database**

- Drift（ORM / Query Builder）
- SQLite（ローカル DB）
- Firebase Firestore（同期）
    
### **Backend / Infrastructure**

- Firebase Authentication
- Firebase Firestore
    
### **Others**

- Python（スクレイピング / データ整形）
- Clean Architecture（責務分離）
    

---

# 🔧 **Tooling（開発支援ツール / Python CLI）**

- フィル名とタイプからフォルダとファイルを自動生成する  **Clean Architecture 用テンプレ生成 CLI（Windows）** を作成  
- 設定ファイルに、責務タイプ、ファイル名を記入（他にも細かい設定あり）


---

# 📦 **Data Preparation（辞書データ生成プロセス / Python）**

アプリ実装とは独立した “データ整備工程” です。
- Webスクレイピング（Python + selenium）
- 正規表現で語義・品詞・例文を解析し構造化
- クレンジング → SQLite スキーマへ整形

---

# 🛤 **Technology Transition**

- 初期版：Android / Java で辞書アプリを構築
- → Room + Kotlin を検討
- → マルチプラットフォーム対応 + 同期要件から  
    **Flutter + Firebase + Drift + Clean Architecture に移行**
    
ベストプラクティスを求めた結果、いちから学びなおすなら「イケイケのflutterにしよう！」と決意

---


# 🔧 **In Development**

- 動詞「時制 × 主語」指定の例文検索
- 例文中の単語タップ → 辞書へジャンプ
- 忘却曲線アルゴリズムによるリマインド通知
- 例文検索 / イディオム検索
- AI を用いたスラング辞書生成
- myWord 同期
- オフライン同期プロセス強化
- 検索アルゴリズム改善
    

---

# 🎯 **Motivation**

スペイン語動詞は **主語 × 時制** の組み合わせにより  
1動詞あたり **約50形態** を覚える必要があります。
しかし、
- 語形変化逆引き
- 辞書
- 語形変化一覧
が統合されたアプリは存在しなかったため、 **「学習と無関係な部分での挫折をなくす」** 体験を構築する ことを目的に開発を開始しました。
    

---

# 🧩 **Challenges & Learnings**

### **Clean Architecture の運用**

ファイル責務の明確化に苦労したが、「変更に強く、読みやすい」構造を実感し運用が安定。

### **Riverpod の増加管理**

Provider が増えすぎて混乱 →  命名ルール / Feature 切りで整理。

### **StreamProvider のリアクティブ設計**

手動 DB 問い合わせから脱却し、リアルタイムアプリの設計に自信がついた。

---

# 🔌 **Setup（Sample）**

```
git clone https://github.com/yourname/linguaforge.git
cd linguaforge
flutter pub get
flutter run
```

---

# 📄 **License**

MIT License

---

# ✉️ **Contact**

📩 [email@example.com](mailto:email@example.com)  
🌐 portfolio-site.com


