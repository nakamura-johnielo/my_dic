# Local-first同期トラック

このトラックは、同期対象の業務データと同期metadataについてDriftをアプリ内の唯一の読み書き先とし、Firebaseを非同期replicaとして扱うための横断計画である。

## Source of Truthの境界

- UI、ViewModel、UseCase、通常のRepositoryはDriftだけを読み書きする。
- FirebaseへアクセスできるのはSyncEngine配下のremote adapterだけとする。
- remoteから取得したデータもDriftへ反映してからUIへ公開する。
- Firebase Auth、Security Rules、role、subscription、account provisioningはremote authorityとして維持する。
- theme、locale、device IDなど端末固有設定は同期対象外であり、SharedPreferences等を利用してよい。

## 実行ゲート

```text
Phase 0完了
  ├── Local-first 1〜4: 契約・schema・Queue・Engine
  └── Phase 1-1・1-2・1-4: composition・import・session
                    ↓ 両方完了
Local-first 5〜7: status → MyWord → User Profile
                    ↓
Local-first 8 → Phase 2・Phase 3
```

Local-first 1〜4はPhase 1-1・1-2・1-4と並行可能である。ただしdatasetのproduction切替は、SyncEngineの所有・起動・account切替が新しい境界へ接続された後に行う。

## タスク一覧

| 順序 | 文書 | 内容 |
| --- | --- | --- |
| 1 | [`1-define-local-first-contract.md`](1-define-local-first-contract.md) | SoT、dataset、競合、削除、ackの共通契約を固定する |
| 2 | [`2-build-drift-sync-schema.md`](2-build-drift-sync-schema.md) | account scope、outbox、checkpoint、tombstoneのschemaを作る |
| 3 | [`3-build-sync-queue.md`](3-build-sync-queue.md) | Drift永続outboxとretry・ackを実装する |
| 4 | [`4-build-sync-engine.md`](4-build-sync-engine.md) | dataset同期のorchestrationと`SyncReport`を実装する |
| 5 | [`5-migrate-word-status.md`](5-migrate-word-status.md) | Esp-Jpn/Jpn-Esp statusを最初の縦切りdatasetとして移行する |
| 6 | [`6-migrate-my-word.md`](6-migrate-my-word.md) | MyWordとMyWordStatusを親子順に移行する |
| 7 | [`7-migrate-user-profile.md`](7-migrate-user-profile.md) | 編集可能User Profileとguest統合を移行する |
| 8 | [`8-cut-over-and-remove-legacy-sync.md`](8-cut-over-and-remove-legacy-sync.md) | 新Engineへ全面切替し旧同期経路を削除する |

## 全タスク共通の不変条件

- 業務レコード更新とoutbox追加は同一Drift transactionで行う。
- remote反映とserver cursor更新は同一Drift transactionで行う。
- 同じdatasetを旧同期と新SyncEngineで同時に処理しない。
- 配送保証はat-least-onceとし、mutation IDとrevisionで冪等にする。
- Firebase SDKがlocal cacheへ受理した時点ではackせず、server-confirmed acknowledgment後だけoutboxを完了する。
- account Aのrow、queue、checkpointをaccount Bから参照・送信しない。
- remote変更のDrift反映から新しいoutboxを生成しない。

## 初期リリースの同期起動条件

- app startup
- sign-in後のsession ready
- app resume
- network復帰
- local mutation後のwake signal
- manual refresh

OS background taskは初期リリースの対象外とし、foreground同期の収束性を確認した後に別タスクとして追加する。

