Flutter採用担当者が短時間で「設計力・実装力・品質」を判断できる流れがよいです。

1. **プロジェクト概要**
   - アプリの目的、主な利用者、解決する課題

   - スペイン語学習アプリ
   - 動詞の変化が多すぎて、文中の単語の意味を検索すらも難しい
   - 動詞の変化の暗記
   - どのデバイスからでも、即座に続きから学習可能

2. **デモ**
   - スクリーンショットやGIF
   - 動作環境、試せるリンクがあれば掲載
一応WEBデモアプリはあるが、使用しているデータが公開しない方が良いものなので、スクリーンショットでの紹介に留める。
[➥Web版デモアプリ (https://my-dic-flutter-portfolio.web.app/)](https://my-dic-flutter-portfolio.web.app/)

<div style="display:flex; gap:12px;">
  <img src="https://github.com/user-attachments/assets/4008e30b-9689-4567-afef-ecaab5491fc8" width="200" />
  <img src="https://github.com/user-attachments/assets/f9ee5e44-1032-46e5-9ff9-eddacb37a026" width="200" />
  <img src="https://github.com/user-attachments/assets/5031443d-af1d-466b-bfa6-e7bcf52599ac" width="200" />
</div>

<div style="display:flex; gap:12px; margin-top:12px; ">
  <img src="https://github.com/user-attachments/assets/0a59e743-5450-4a25-bc20-5ff5c8e69900" width="200" />
  <img src="https://github.com/user-attachments/assets/a98baa2c-0c49-4de2-a9e7-67ca57440ee6" width="200" />
  <img src="https://github.com/user-attachments/assets/5f2f539a-16c5-4c4d-aa07-ab0ce3396b55" width="200" />
</div>

3. **主な機能**
   - 単語検索。語形変化したままで検索
   - 日本語、スペイン語どちらからでも検索
   - クラウド同期で、学習進捗を複数デバイスで共有
   - 単語の語形変化をフラッシュカード形式で覚えるクイズ機能
   - 単語のブックマーク、学習済み管理
   - 自分で単語を追加可能（スラングなどやフレーズなど）

4. **技術構成**
   - Flutter/Dartのバージョン
   - 状態管理、DB、主要パッケージ

    - Flutter / Dart    
    - Riverpod（状態管理・DI）
    - GoRouter（ルーティング）
    - Drift（SQLite / IndexDb）
    - Firebase（Auth / Firestore）
    - Python（データ整備 / CLI）

5. **設計・実装上の工夫**
   - アーキテクチャ、ディレクトリ構成
   - 保守性、パフォーマンス、UXへの配慮
   - 技術選定の理由
## 設計

機能単位でモジュールを分割し、各機能内を `Presentation / Application / Domain / Infrastructure` に整理しています。外部には `port` の公開インターフェースだけを公開し、機能同士は `integration` のAdapterを介して連携することで、依存関係を明確にしています。

Riverpodは状態管理とDIに使用し、依存オブジェクトの組み立ては `app/bootstrap` に集約しています。辞書検索や学習データはDriftでローカル管理し、Firebase Authentication・Firestoreによって認証と端末間同期を実現しています。設計上の境界は自動テストで継続的に検証しています。
   
## 同期設計

同期処理は各機能から分離し、共通のSync Engineに集約しています。ローカルの変更はOutboxとしてDriftへ永続化し、成功確認後にキューから削除します。取得済み位置はCursorとして保存し、差分データのみを反映する設計です。

通信失敗時はエラーを分類して指数バックオフで再試行し、復旧不能な変更はDead Letterとして扱います。また、同一アカウントでの重複実行防止や、ログアウト・アカウント切替時の処理中断を行い、古いセッションのデータが反映されることを防いでいます。

各機能はデータ変換と保存処理だけを担当し、キュー、再試行、進捗管理などの同期方針はSync側で一元管理しています。

6. **品質管理**
   - テスト、Lint、エラーハンドリング、CI/CDなど

7. **セットアップ方法**
   - 必要環境と、実行までの最短手順

8. **今後の改善点**
   - 現在の制約や追加したい機能
   - 自分で課題を把握できていることを示す

最後に、採用者向けREADMEでは「機能の多さ」よりも、**なぜその設計にしたか**と**どこを工夫したか**を具体的に見せるのが重要です。次はリポジトリを確認し、このプロジェクト固有のREADME構成に落とし込めます。
