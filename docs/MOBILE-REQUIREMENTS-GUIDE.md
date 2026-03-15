# モバイルアプリ開発 要件ガイド

tf-mobile-env を使ってモバイルアプリを開発する際の工程と、各工程でユーザーが整理すべき情報をまとめる。

---

## 全体工程フロー

```
Phase 1: 要件定義        ─→ 誰に、何を、どのプラットフォームで
Phase 2: アーキテクチャ設計 ─→ どう構成するか
Phase 3: UI/UX 設計       ─→ どう見せるか、どう触らせるか
Phase 4: データ・API 設計  ─→ どうつなぐか、オフラインでどう動くか
Phase 5: 実装            ─→ つくる
Phase 6: テスト           ─→ 確かめる
Phase 7: リリース・運用    ─→ 届けて、回し続ける
```

各フェーズの出力が次フェーズの入力になる。Phase 1〜4 が設計、Phase 5〜7 が実行。

---

## 情報補完のルール

ユーザーが空欄や曖昧な情報を渡した場合、エージェントは以下のルールに従う。

### 1. 推論と事実を明確に区別する

エージェントが不足情報を補完する際、**推論した部分**と**ユーザーから提供された事実**を必ず区別して表示する。

```markdown
## アーキテクチャの提案

| 項目 | 値 | 根拠 |
|------|-----|------|
| フレームワーク | Flutter | ✅ 確定: ユーザー指定 |
| 状態管理 | Riverpod | ⚡ 推論: 中規模アプリ + チーム2名から判断 |
| アーキテクチャ | Clean Architecture | ⚡ 推論: ドメインロジックの複雑さから判断 |
| オフライン方式 | Hive + キュー同期 | ❓ 未定: オフライン要件が不明 |
```

**表記ルール:**

- ✅ **確定**: ユーザーが明示的に提供した情報
- ⚡ **推論**: エージェントが文脈から推測した情報（根拠を必ず併記）
- ❓ **未定**: 情報不足で判断できない項目（質問として提示）

### 2. 推論部分は必ず確認を取る

推論した項目は一括で確認を求める。ユーザーが修正しやすいように選択肢を提示する。

```markdown
### 確認事項

以下は推論で補完しました。認識が合っているか確認してください。

1. **状態管理を Riverpod にしました**
   → 中規模アプリ + チーム2名の構成から判断しました。
   → 他の選択肢: BLoC / GetX / Provider / Redux
   → [ OK / 変更 ]

2. **Clean Architecture を採用しました**
   → ドメインロジック（決済・在庫管理）の複雑さから判断しました。
   → 他の選択肢: MVVM のみ / Repository パターンのみ
   → [ OK / 変更 ]

3. **ナビゲーションを GoRouter にしました**
   → Deep Link 対応要件があるため判断しました。
   → 他の選択肢: Navigator 2.0 直接 / auto_route / beamer
   → [ OK / 変更 ]
```

### 3. 質問は積極的に行う

推論でカバーできない項目は、遠慮なく質問する。質問のフォーマット:

```markdown
### 質問（Phase N を進めるために必要です）

❓ **Q1: オフライン対応はどこまで必要ですか？**
   背景: オフライン対応の範囲でデータ層の設計が大きく変わります。
   選択肢: 完全オフライン動作 / 閲覧のみオフライン / オンライン前提 / わからない

❓ **Q2: プッシュ通知は必要ですか？**
   背景: FCM / APNs の設定、バックグラウンド処理の設計に影響します。
   選択肢: 必要（リアルタイム）/ 必要（バッチ）/ 不要 / わからない
```

### 4. 「わからない」は正当な回答

ユーザーが「わからない」と回答した場合:

- エージェントが**安全側のデフォルト値**を提案する
- デフォルト値にも ⚡ 推論マークを付ける
- 後フェーズで情報が確定したら更新する

---

## Phase 1: 要件定義

**目的**: アプリの全体像を把握する。ここが曖昧だと後工程すべてがブレる。

### 1.1 アプリ概要

```yaml
# === アプリ概要 ===
app:
  name: ""                      # アプリ名
  description: ""               # 一言で何をするアプリか（1-2文）
  category: ""                  # SNS | EC | 業務 | ヘルスケア | 教育 | 金融 | メディア | ユーティリティ
  monetization: ""              # 無料 | 広告 | サブスク | 買い切り | アプリ内課金 | フリーミアム
```

### 1.2 ターゲットユーザー

```yaml
# === ターゲットユーザー ===
users:
  primary_persona: ""           # 主要ユーザー像（例: 20-30代のオンラインショッパー）
  estimated_dau: ""             # 想定 DAU（例: 1,000 / 10,000 / 100,000+）
  tech_literacy: ""             # 高い | 普通 | 低い（操作ガイドが必要）
  accessibility_needs: ""       # 標準 | 高齢者対応 | 視覚障害対応 | 包括的対応
  locales:                      # 対応言語・地域
    - language: ""              # 例: ja
      region: ""                # 例: JP
```

### 1.3 プラットフォーム・デバイス

```yaml
# === プラットフォーム ===
platform:
  targets:                      # 対象プラットフォーム
    - iOS | Android | Web | Desktop
  framework: ""                 # Flutter | React Native | SwiftUI | Kotlin Multiplatform | ネイティブ
  min_os_version:
    ios: ""                     # 例: 16.0
    android: ""                 # 例: API 26 (Android 8.0)
  device_types:                 # 対象デバイス
    - smartphone | tablet | foldable | wearable
  orientation: ""               # portrait | landscape | both
```

### 1.4 機能要件（ユーザーストーリー）

```yaml
# === 機能要件 ===
features:
  # ユーザーストーリー形式で列挙する
  # 「〜として、〜したい。なぜなら〜だから。」
  stories:
    - id: "US-001"
      as_a: ""                  # 例: ログインユーザー
      i_want_to: ""             # 例: 商品を検索して購入する
      so_that: ""               # 例: 欲しい商品をすぐに手に入れられる
      priority: ""              # Must | Should | Could | Won't（MoSCoW）
      acceptance_criteria:      # 受け入れ条件
        - ""

  # MVP スコープ（Phase 1 リリースに含む機能）
  mvp_scope:
    - ""                        # US-001, US-002, ...
```

### 1.5 非機能要件・制約

```yaml
# === 非機能要件 ===
non_functional:
  performance:
    app_launch_time: ""         # コールドスタート目標（例: < 2秒）
    screen_transition: ""       # 画面遷移目標（例: < 300ms）
    api_response: ""            # API レスポンス目標（例: < 1秒）
    frame_rate: ""              # 目標 FPS（例: 60fps）

  offline:
    required: Yes | No          # オフライン対応が必要か
    scope: ""                   # 全機能 | 閲覧のみ | 特定機能のみ | 不要
    sync_strategy: ""           # リアルタイム | バックグラウンド定期 | 手動 | 未定

  security:
    authentication: ""          # Email/PW | OAuth | 生体認証 | SMS OTP | 未定
    data_sensitivity: ""        # 高（金融・医療）| 中（個人情報）| 低（公開情報）
    compliance: ""              # 個人情報保護法 | GDPR | HIPAA | PCI DSS | なし
    certificate_pinning: ""     # 必要 | 不要 | 未定

constraints:
  budget: ""                    # 開発予算（概算）
  timeline: ""                  # リリース目標日 or 期間（例: 3ヶ月後）
  team:
    size: ""                    # 開発者数
    experience: ""              # Flutter経験あり | モバイル初 | Web経験のみ
  existing_backend: ""          # 既存 API あり | 新規構築 | BaaS（Firebase等）
```

### 1.6 ビジネスコンテキスト

```yaml
# === ビジネスコンテキスト ===
business:
  purpose: ""                   # なぜこのアプリが必要か（1-2文）
  stakeholders:
    - role: ""                  # 例: プロダクトオーナー
      expectation: ""           # 例: 月間 DL 数 10,000 達成
  success_criteria: ""          # 成功基準（例: ストア評価 4.0 以上）
  competitors:                  # 競合アプリ（参考）
    - name: ""
      differentiator: ""        # 自アプリとの差別化ポイント
  known_issues: ""              # 現状の課題（例: Web版が使いにくい）
```

---

## Phase 2: アーキテクチャ設計

**目的**: アプリの技術基盤を決める。
**使うもの**: `mobile-architect` エージェント

### 2.1 アーキテクチャパターン選択

Phase 1 の情報を基に判断する。

```yaml
# === アーキテクチャ判断材料 ===
architecture_decision:
  # 以下の質問に答える（該当するものを選択）
  domain_complexity: ""         # 高（複雑なビジネスロジック）| 中 | 低（CRUD中心）
  team_size: ""                 # 1-2名 | 3-5名 | 6名以上
  long_term_maintenance: ""     # 長期（3年+）| 中期（1-2年）| 短期（MVP のみ）
  testability_priority: ""      # 高 | 中 | 低

  # パターン（mobile-architect が提案、ユーザーが承認）
  # Clean Architecture | MVVM | MVC | Repository Pattern Only
  selected_pattern: ""
  reason: ""
```

### 2.2 状態管理

```yaml
# === 状態管理 ===
state_management:
  # 判断材料
  state_complexity: ""          # 多数の画面で共有状態あり | 画面ごとに独立 | 単純
  reactive_needed: ""           # リアルタイム更新が多い | 少ない | 不要

  # 方式（mobile-architect が提案、ユーザーが承認）
  # BLoC | Riverpod | Provider | GetX | Redux | setState のみ
  selected: ""
  reason: ""
```

### 2.3 レイヤー構成

```yaml
# === レイヤー構成 ===
layers:
  presentation:
    description: ""             # UI + ViewModel / Cubit / Controller
    navigation: ""              # GoRouter | Navigator 2.0 | auto_route
  domain:
    description: ""             # UseCases + Entities + Repository Interfaces
    has_complex_logic: Yes | No
  data:
    description: ""             # Repository Impl + DataSources + Models
    local_storage: ""           # Hive | Drift(SQLite) | SharedPreferences | Isar
    remote_api: ""              # REST | GraphQL | gRPC | Firebase
```

### 2.4 依存関係・外部サービス

```yaml
# === 外部サービス ===
external_services:
  backend:
    type: ""                    # 自社 API | Firebase | Supabase | AWS Amplify
    auth_provider: ""           # Firebase Auth | Auth0 | Cognito | 自社
  analytics: ""                 # Firebase Analytics | Mixpanel | Amplitude | なし
  crash_reporting: ""           # Crashlytics | Sentry | なし
  push_notification: ""         # FCM | OneSignal | なし
  storage: ""                   # Cloud Storage | S3 | なし
  payments: ""                  # Stripe | RevenueCat | アプリ内課金直接 | なし
  maps: ""                      # Google Maps | Mapbox | Apple Maps | なし
  other:
    - name: ""
      purpose: ""
```

---

## Phase 3: UI/UX 設計

**目的**: 画面構成とデザインシステムを決める。
**使うもの**: `ui-ux-reviewer` エージェント

### 3.1 画面一覧

```yaml
# === 画面一覧 ===
screens:
  - id: "SCR-001"
    name: ""                    # 例: ホーム画面
    purpose: ""                 # 例: 商品一覧を表示し、検索・絞り込みを提供
    user_stories: []            # 関連する US-ID（例: [US-001, US-003]）
    inputs: []                  # ユーザー入力（例: 検索キーワード、フィルター条件）
    outputs: []                 # 表示内容（例: 商品カード一覧、カテゴリタブ）
    navigation:
      from: []                  # どの画面から遷移してくるか
      to: []                    # どの画面へ遷移するか
```

### 3.2 デザインシステム

```yaml
# === デザインシステム ===
design_system:
  guideline: ""                 # Material Design 3 | Cupertino (HIG) | カスタム | Adaptive（両対応）
  theme:
    primary_color: ""           # 例: #1A73E8
    dark_mode: Yes | No
    custom_fonts: ""            # 例: Noto Sans JP | システムフォント

  components:                   # 特別なカスタムコンポーネントがあれば記載
    - name: ""
      description: ""

  design_file: ""               # Figma URL | Adobe XD URL | なし | 後から作成
```

### 3.3 レスポンシブ・アダプティブ対応

```yaml
# === レスポンシブ設計 ===
responsive:
  breakpoints:                  # 対応する画面幅
    phone: ""                   # 例: < 600dp
    tablet: ""                  # 例: 600-1024dp
    desktop: ""                 # 例: > 1024dp（Web/Desktop対応時）

  adaptive_layout: Yes | No    # タブレットで2ペイン表示等が必要か
  orientation_support: ""       # portrait のみ | landscape のみ | both
  safe_area: ""                 # ノッチ・パンチホール対応の考慮
```

### 3.4 アクセシビリティ要件

```yaml
# === アクセシビリティ ===
accessibility:
  target_level: ""              # WCAG 2.1 AA | WCAG 2.1 AAA | 基本対応 | 未定
  screen_reader: Yes | No      # VoiceOver / TalkBack 対応
  font_scaling: Yes | No       # Dynamic Type / フォントサイズ変更対応
  color_contrast: ""            # 4.5:1 以上 | 3:1 以上 | 未検討
  motion_reduction: Yes | No   # アニメーション軽減オプション
```

---

## Phase 4: データ・API 設計

**目的**: データの流れ、オフライン戦略、API 仕様を決める。
**使うもの**: `mobile-architect` エージェント、`platform-bridge` エージェント

### 4.1 データモデル

```yaml
# === データモデル ===
data_model:
  entities:                     # 主要なエンティティを列挙
    - name: ""                  # 例: User
      fields:
        - name: ""              # 例: id
          type: ""              # String | int | DateTime | bool | List<T>
          nullable: Yes | No
          description: ""
      relationships:            # 他エンティティとの関係
        - target: ""            # 例: Order
          type: ""              # 1:1 | 1:N | N:N
```

### 4.2 API 仕様

```yaml
# === API 仕様 ===
api:
  style: ""                     # REST | GraphQL | gRPC | Firebase Realtime
  base_url: ""                  # 例: https://api.example.com/v1
  authentication: ""            # Bearer Token | API Key | OAuth2 | Firebase ID Token

  # 主要エンドポイント（わかる範囲で）
  endpoints:
    - method: ""                # GET | POST | PUT | DELETE
      path: ""                  # 例: /users/{id}
      description: ""           # 例: ユーザー情報取得
      request_body: ""          # リクエストの概要（POST/PUT の場合）
      response: ""              # レスポンスの概要

  # API ドキュメント
  api_docs: ""                  # OpenAPI/Swagger URL | Postman Collection | なし | 後から作成

  # エラーハンドリング方針
  error_format: ""              # 例: { "code": "ERR_001", "message": "...", "details": {} }
```

### 4.3 オフライン戦略

```yaml
# === オフライン戦略 ===
offline:
  required: Yes | No

  # オフライン時の挙動を画面ごとに定義
  screen_behavior:
    - screen: ""                # 例: 商品一覧
      offline_action: ""        # キャッシュ表示 | エラー表示 | 機能制限 | 完全動作
    - screen: ""
      offline_action: ""

  # データ同期戦略
  sync:
    strategy: ""                # Optimistic | Pessimistic | Conflict Resolution
    conflict_resolution: ""     # Last Write Wins | Server Wins | Manual Merge | 未定
    queue_persistence: ""       # メモリ | ローカルDB | 不要

  # キャッシュ戦略
  cache:
    strategy: ""                # Cache First | Network First | Stale While Revalidate
    ttl: ""                     # キャッシュ有効期間（例: 1時間、1日）
    max_size: ""                # キャッシュ最大サイズ（例: 100MB）
```

### 4.4 プッシュ通知

```yaml
# === プッシュ通知 ===
push_notification:
  required: Yes | No

  types:                        # 通知の種類
    - name: ""                  # 例: 新着メッセージ
      trigger: ""               # サーバーイベント | スケジュール | ジオフェンス
      priority: ""              # 高（即時）| 通常 | 低（バッチ）
      action: ""                # 画面遷移先 or アクション

  permission_strategy: ""       # 初回起動時 | 特定機能利用時 | 設定画面から | 未定
```

---

## Phase 5: 実装

**目的**: コードを書く。
**使うもの**: `app-scaffold` スキル、`state-management` スキル、`deeplink-setup` スキル

### 5.1 実装指示シート

```yaml
# === 実装指示 ===
implementation:
  framework: ""                 # Flutter | React Native | SwiftUI | Kotlin
  language: ""                  # Dart | TypeScript | Swift | Kotlin
  sdk_version: ""               # 例: Flutter 3.24+, Dart 3.5+

  # パッケージ／ライブラリの方針
  packages:
    state_management: ""        # 例: flutter_riverpod 2.x
    networking: ""              # 例: dio 5.x | http | retrofit
    local_db: ""                # 例: drift 2.x | hive_ce | isar
    di: ""                      # 例: get_it + injectable | riverpod のみ
    navigation: ""              # 例: go_router 14.x
    testing: ""                 # 例: mocktail, golden_toolkit

  # 画面ごとの実装順序（推奨）
  implementation_order:
    - phase: "Sprint 1"
      screens: []               # 例: [SCR-001, SCR-002]
      features: []              # 例: [US-001, US-002]
    - phase: "Sprint 2"
      screens: []
      features: []
```

### 5.2 ディープリンク設定

```yaml
# === ディープリンク ===
deep_links:
  required: Yes | No

  scheme: ""                    # 例: myapp://
  universal_links:              # iOS Universal Links
    domain: ""                  # 例: example.com
    paths: []                   # 例: ["/products/*", "/users/*"]
  app_links:                    # Android App Links
    domain: ""
    paths: []

  routes:                       # ディープリンクと画面のマッピング
    - link: ""                  # 例: /products/:id
      screen: ""                # 例: SCR-003（商品詳細）
```

---

## Phase 6: テスト

**目的**: アプリの正しさを検証する。
**使うもの**: `mobile-tdd-guide` エージェント、`/mobile-tdd` コマンド

### 6.1 テスト要件

```yaml
# === テスト要件 ===
testing:
  coverage_target: ""           # 目標カバレッジ（例: 80%）

  # テストピラミッド
  unit_tests:
    scope: ""                   # 例: UseCases, Repository, Entities のロジック検証
    critical_paths:             # 必ずテストすべきロジック
      - ""                      # 例: 決済金額計算
      - ""                      # 例: バリデーションルール

  widget_tests:
    scope: ""                   # 例: 各画面の UI 描画とインタラクション
    golden_tests: Yes | No      # ゴールデンテスト（スナップショット）を使うか
    critical_screens:           # 必ず Widget Test すべき画面
      - ""                      # 例: SCR-001（ホーム）
      - ""                      # 例: SCR-005（決済）

  integration_tests:
    scope: ""                   # 例: API 連携、DB 操作の結合テスト
    external_mocks:             # モック対象
      - ""                      # 例: Firebase Auth
      - ""                      # 例: 決済 API

  e2e_tests:
    scope: ""                   # 例: ユーザージャーニー全体
    critical_journeys:          # 必ず E2E テストすべきフロー
      - ""                      # 例: 会員登録 → 商品検索 → 購入 → 注文確認
    device_matrix:              # テスト対象デバイス
      - device: ""              # 例: iPhone 15
        os_version: ""          # 例: iOS 17
      - device: ""              # 例: Pixel 8
        os_version: ""          # 例: Android 14

  # テストデータの要件
  test_data:
    normal_cases: ""            # 正常ケースの説明
    edge_cases:
      - ""                      # 例: 超長文テキスト入力
      - ""                      # 例: ネットワーク切断中の操作
      - ""                      # 例: 端末の日時が過去に設定
    locale_tests:               # 多言語テスト
      - ""                      # 例: ja_JP, en_US
```

---

## Phase 7: リリース・運用

**目的**: ストアに公開し、安定運用する。
**使うもの**: `release-manager` エージェント、`/store-check` コマンド、`ci-mobile` スキル

### 7.1 ストア提出準備

```yaml
# === ストア提出 ===
store_submission:
  app_store:
    required: Yes | No
    apple_developer_account: ""   # あり | なし | 未取得
    app_id: ""                    # 例: com.example.myapp
    age_rating: ""                # 4+ | 9+ | 12+ | 17+
    content_descriptions:         # コンテンツ説明（審査用）
      - ""

  google_play:
    required: Yes | No
    developer_account: ""         # あり | なし | 未取得
    package_name: ""              # 例: com.example.myapp
    content_rating: ""            # Everyone | Teen | Mature
    target_audience: ""           # 子供向け | 一般 | 全年齢

  # メタデータ（共通）
  metadata:
    title: ""                     # ストア表示名
    subtitle: ""                  # サブタイトル（iOS）/ 短い説明（Android）
    description: ""               # ストア説明文
    keywords: []                  # 検索キーワード
    screenshots_ready: Yes | No   # スクリーンショットが準備済みか
    privacy_policy_url: ""        # プライバシーポリシー URL
```

### 7.2 CI/CD

```yaml
# === CI/CD ===
ci_cd:
  platform: ""                  # GitHub Actions | Codemagic | Bitrise | なし

  pipelines:
    - name: "PR Check"
      triggers: ["pull_request"]
      steps: []                 # 例: [lint, test, build]
    - name: "Release"
      triggers: ["tag"]
      steps: []                 # 例: [test, build, sign, deploy]

  code_signing:
    ios:
      method: ""                # manual | match (fastlane) | Xcode Cloud
      certificates_stored: ""   # GitHub Secrets | Keychain | 未設定
    android:
      keystore_stored: ""       # GitHub Secrets | ローカル | 未設定

  distribution:
    internal_testing: ""        # TestFlight | Firebase App Distribution | なし
    beta_testing: ""            # TestFlight Public | Google Play Open Testing | なし
```

### 7.3 監視・クラッシュ対応

```yaml
# === 監視設計 ===
monitoring:
  crash_reporting: ""           # Crashlytics | Sentry | なし
  analytics: ""                 # Firebase Analytics | Mixpanel | なし
  performance_monitoring: ""    # Firebase Performance | なし

  # アラート設定
  alerts:
    - metric: ""                # 例: クラッシュフリー率
      warning: ""               # 例: < 99.5%
      critical: ""              # 例: < 99.0%
      action: ""                # 例: Slack #mobile-alert に通知
    - metric: ""                # 例: ANR 率（Android）
      warning: ""
      critical: ""
      action: ""

  # アプリアップデート戦略
  update_strategy:
    force_update: ""            # 必要（重大バグ時）| 不要
    in_app_update: ""           # 柔軟アップデート | 即時アップデート | 未実装
    remote_config: ""           # Firebase Remote Config | なし
```

### 7.4 障害対応

```yaml
# === 障害対応 ===
incident_response:
  # 想定障害シナリオ
  scenarios:
    - failure: ""               # 例: API サーバーダウン
      impact: ""                # 例: 全機能停止（オフラインキャッシュのみ動作）
      recovery: ""              # 例: サーバー復旧後に自動リトライ
    - failure: ""               # 例: ストアからのリジェクト
      impact: ""                # 例: 新バージョンが配信されない
      recovery: ""              # 例: リジェクト理由を確認し、修正して再提出

  # ホットフィックス戦略
  hotfix:
    process: ""                 # 例: main から hotfix ブランチ → 修正 → 緊急リリース
    max_response_time: ""       # 例: 4時間以内にストアに再提出

  # 連絡体制
  escalation:
    - level: 1
      who: ""                   # 例: モバイル開発チーム
      when: ""                  # 例: クラッシュ率 < 99% 検知時
    - level: 2
      who: ""
      when: ""                  # 例: 1時間未解決 or ストアリジェクト
```

---

## 工程とコンポーネントの対応表

| Phase | ユーザーが準備する情報 | 使う Agent / Skill / Command | 成果物 |
|-------|---------------------|------------------------------|--------|
| **1. 要件定義** | アプリ概要、ユーザー、プラットフォーム、機能、制約 | — (ヒアリング) | 要件定義書 |
| **2. アーキテクチャ** | 複雑度、チーム規模、状態管理、外部サービス | `mobile-architect` | アーキテクチャ図、ADR |
| **3. UI/UX** | 画面一覧、デザインシステム、アクセシビリティ | `ui-ux-reviewer` | 画面遷移図、デザインガイド |
| **4. データ・API** | エンティティ、API 仕様、オフライン要件、通知 | `mobile-architect`, `platform-bridge` | データモデル、API 仕様書 |
| **5. 実装** | フレームワーク、パッケージ、実装順序 | `app-scaffold`, `state-management`, `deeplink-setup` | アプリコード |
| **6. テスト** | テスト方針、重要フロー、デバイスマトリクス | `mobile-tdd-guide`, `/mobile-tdd`, `/device-matrix` | テストコード、エビデンス |
| **7. リリース・運用** | ストア情報、CI/CD、監視、障害対応 | `release-manager`, `/store-check`, `ci-mobile` | ストア提出物、CI 設定、ランブック |

---

## 使い方

### 最小スタート（まず Phase 1 だけ埋める）

1. このファイルの Phase 1 セクションを YAML テンプレートとしてコピー
2. わかる範囲で埋める（空欄 OK）
3. Claude Code に渡す → `mobile-architect` が不足情報を質問してくれる

### フル定義（設計をしっかりやる場合）

1. Phase 1〜4 をすべて埋める
2. Claude Code に渡す → 各エージェントが設計レビュー
3. Phase 5〜7 は設計結果を基に自動生成 + レビュー

### 既存アプリの改善

1. Phase 2（アーキテクチャ）と Phase 6（テスト）から始める
2. `/mobile-review` で現状を診断
3. 問題箇所を特定してから Phase 3〜4 に戻って再設計
