# **Index**

1. **Summary**
2. **Demo（デモ）**
**スペイン語学習向けマルチプラットフォーム辞書アプリ**

TL;DR
- Flutterで実装した辞書兼学習アプリ。ローカルDB（Drift/SQLite）を中心に、Firebaseでの認証・デバイス間同期を組み合わせ、検索・語形変化逆引き・クイズ・ブックマーク同期を提供します。

採用担当向けハイライト
- 役割：設計・実装（アーキテクチャ設計、DB設計、同期ロジック、主要UI）
- 技術：Flutter, Riverpod, GoRouter, Drift（SQLite）, Firebase Auth/Firestore
- 何を示せるか：マルチプラットフォーム対応／オフライン同期設計／Feature-modularなクリーンアーキテクチャ

主な実績（短く・強調）
- オフライン優先設計＋クラウド同期を実装し、ローカル主体で高速な検索体験を維持
- Clean Architecture に基づくモジュール化で機能追加・保守を容易に実装
- テスト（ユニット／ウィジェット）とデータ整備用のPythonツールを導入し品質を担保

主な機能（要点）
- 日本語 ↔ スペイン語 双方向検索（語形変化の逆引き含む）
- 動詞語形変化一覧とクイズ機能
- myWord（ブックマーク）とFirestoreによるデバイス間同期
- マルチプラットフォーム（Android / Web / Windows）対応

簡単なセットアップ
1. `flutter pub get` で依存を取得
2. Firebase 設定（`PRIVATES` に非公開ファイルを置く必要があります）
3. ローカルで起動：`flutter run`

参考リンク（技術確認用）
- [pubspec.yaml](pubspec.yaml#L1)
- [lib/main.dart](lib/main.dart#L1)
- [lib/router.dart](lib/router.dart#L1)
- [lib/core/infrastructure/database/drift/database_provider.dart](lib/core/infrastructure/database/drift/database_provider.dart#L1)

もっと詳細が必要な技術担当者向けには「詳細版README」を用意しています（セットアップ手順、アーキテクチャ図、テスト手順、スクリーンショット入り）。詳しくは [README_DETAILED.md](README_DETAILED.md).

---

もしこのリポジトリを採用資料として整備する場合、スクリーンショット（ホーム／検索／クイズ）と短い「この機能で何を達成したか」の定量的メモ（例：同期データ量、主要最適化でのレスポンス改善）を追加すると刺さります。


web用に最適化していないので少々動作が重いです

