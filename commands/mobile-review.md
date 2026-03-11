---
description: Run mobile-architect and ui-ux-reviewer agents in parallel for comprehensive mobile app review.
---

# /mobile-review コマンド

モバイルアプリの包括的レビューを実行するコマンド。`mobile-architect` エージェントと `ui-ux-reviewer` エージェントを並列に起動し、アーキテクチャと UI/UX の両面からレビューを行う。

---

## 実行手順

### 1. 並列エージェント起動

以下の 2 つのエージェントを **並列に** 起動する。

#### Agent 1: mobile-architect

アーキテクチャレビューを担当する。

**レビュー観点:**

| カテゴリ | チェック項目 |
|---------|------------|
| レイヤー分離 | Clean Architecture の data / domain / presentation が正しく分離されているか |
| 依存方向 | 依存の方向が内側（domain）に向かっているか。presentation → domain ← data |
| 状態管理 | BLoC / Riverpod / Provider が一貫して使用されているか |
| DI | get_it / injectable で依存性注入が適切に設定されているか |
| エラーハンドリング | Result 型（Either / sealed class）で適切にエラーを伝搬しているか |
| データフロー | Repository → UseCase → Bloc/Notifier のデータフローが一方向か |
| テスタビリティ | 各レイヤーが独立してテスト可能か |
| パフォーマンス | 不要なリビルドが発生していないか（const, equatable） |

#### Agent 2: ui-ux-reviewer

UI/UX レビューを担当する。

**レビュー観点:**

| カテゴリ | チェック項目 |
|---------|------------|
| HIG 準拠 | iOS の Human Interface Guidelines に準拠しているか |
| MD3 準拠 | Material Design 3 のコンポーネント・トークンを使用しているか |
| アクセシビリティ | Semantics ラベル、タップターゲットサイズ (48x48dp)、コントラスト比 |
| レスポンシブ | 画面サイズ（SE 〜 Pro Max, タブレット）に対応しているか |
| ダークモード | ライト / ダーク両テーマでの表示確認 |
| ローディング | Shimmer / Skeleton による適切なローディング表示 |
| エラー状態 | エラー画面、リトライボタン、オフライン表示 |
| 空状態 | データなし時の Empty State 表示 |

### 2. 統合レビューレポート出力

両エージェントの結果を統合し、以下の形式でレポートを出力する。

```markdown
## Mobile Review Report

### Architecture Review (mobile-architect)
| 重要度 | 件数 |
|--------|------|
| CRITICAL | N 件 |
| HIGH | N 件 |
| MEDIUM | N 件 |

#### 指摘事項
1. [CRITICAL] ...
2. [HIGH] ...

### UI/UX Review (ui-ux-reviewer)
| 重要度 | 件数 |
|--------|------|
| CRITICAL | N 件 |
| HIGH | N 件 |
| MEDIUM | N 件 |

#### 指摘事項
1. [CRITICAL] ...
2. [HIGH] ...

### 対応優先度
1. CRITICAL（即座に対応）
2. HIGH（このスプリントで対応）
3. MEDIUM（バックログに追加）
```

### 3. 対応

- **CRITICAL** の指摘は即座に修正する
- **HIGH** の指摘はこのスプリント内で対応する
- **MEDIUM** の指摘はバックログに追加し、優先度を検討する
