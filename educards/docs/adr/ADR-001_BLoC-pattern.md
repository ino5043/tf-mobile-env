# ADR-001: BLoC パターンの採用

| 項目 | 値 |
|------|-----|
| ステータス | 承認済 |
| 作成日 | 2026-03-15 |
| 作成者 | Claude AI |
| 影響範囲 | Presentation 層全体（DeckListBloc, StudySessionBloc, ProgressBloc） |
| 関連ADR | — |

## 1. コンテキスト

EduCards アプリの状態管理パターンを選定する必要がある。Flutter では複数の選択肢があり、プロジェクトの規模・テスト容易性・チームの慣れを考慮して判断が必要。

## 2. 決定

**BLoC (Business Logic Component) パターン**を採用する。`flutter_bloc` パッケージ（v9.x）を使用し、Event → BLoC → State の単方向データフローで状態を管理する。

## 3. 理由

### 検討した代替案

| 手法 | 利点 | 不採用理由 |
|------|------|----------|
| setState | シンプル | スケールしない、テスト困難 |
| Provider | 軽量 | 複雑な状態遷移に不向き |
| Riverpod | モダン | 学習コストが高い |
| GetX | 機能豊富 | 暗黙的すぎる、テスト困難 |

BLoC を選んだ理由:
- **テスト容易性**: `bloc_test` パッケージで Event → State 遷移を完全にテスト可能
- **予測可能性**: 単方向データフローにより状態変化が追跡しやすい
- **関心の分離**: UI とビジネスロジックが明確に分離される
- **tf-mobile-env 標準**: state-management skill が BLoC をサポート

## 4. 結果・影響

| 観点 | 影響 |
|------|------|
| ✅ テスト | Event → State 遷移を bloc_test で自動テスト可能 |
| ✅ 保守性 | 状態ロジックが BLoC に集約、UI は描画に専念 |
| ✅ デバッグ | BlocObserver でログ取得可能 |
| ⚠️ ボイラープレート | Event/State/BLoC の 3 ファイルが必要 |
| ⚠️ 学習コスト | Stream ベースの概念理解が必要 |
