---
name: store-submission
description: App Store and Google Play submission checklist with screenshot preparation and metadata templates.
---

# ストア提出スキル

App Store (iOS) および Google Play (Android) へのアプリ提出を支援するスキル。チェックリスト、スクリーンショット仕様、メタデータテンプレート、自動化コマンドを提供する。

---

## 1. 提出前チェックリスト

### iOS (App Store Connect)

| # | 項目 | 確認内容 |
|---|------|---------|
| 1 | Bundle ID | `com.company.appname` 形式で一意か |
| 2 | Version / Build | CFBundleShortVersionString と CFBundleVersion が正しいか |
| 3 | App Icons | 1024x1024 px (App Store 用) が含まれているか |
| 4 | Launch Screen | Storyboard or SwiftUI の LaunchScreen が設定されているか |
| 5 | Info.plist | 必須キー（NSCameraUsageDescription 等）が設定されているか |
| 6 | Signing | Distribution Certificate + Provisioning Profile が有効か |
| 7 | ATT | App Tracking Transparency の設定（後述） |
| 8 | Privacy Policy | URL が有効でアクセス可能か |
| 9 | Export Compliance | 暗号化使用の申告が正しいか |
| 10 | In-App Purchase | 該当する場合、IAP が「Ready to Submit」か |

### Android (Google Play Console)

| # | 項目 | 確認内容 |
|---|------|---------|
| 1 | Application ID | `com.company.appname` 形式で一意か |
| 2 | Version Code / Name | `versionCode` がインクリメントされているか |
| 3 | App Icons | Adaptive Icon (foreground + background) が設定されているか |
| 4 | Signing | Upload Key で署名されているか（App Signing by Google Play） |
| 5 | Target API Level | 最新要件（API 34+）を満たしているか |
| 6 | Permissions | AndroidManifest.xml の `<uses-permission>` が最小限か |
| 7 | ProGuard / R8 | 難読化ルールが正しく設定されているか |
| 8 | 64-bit | arm64-v8a が含まれているか |
| 9 | Privacy Policy | URL が有効でアクセス可能か |
| 10 | Data Safety | Data Safety フォーム（後述）が記入済みか |

---

## 2. スクリーンショット仕様

### iOS スクリーンショット

| デバイス | サイズ (px) | 必須枚数 |
|---------|------------|---------|
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 | 最低 3 枚、最大 10 枚 |
| iPhone 6.5" (11 Pro Max) | 1284 x 2778 | 最低 3 枚、最大 10 枚 |
| iPhone 5.5" (8 Plus) | 1242 x 2208 | 最低 3 枚、最大 10 枚 |
| iPad Pro 12.9" (6th gen) | 2048 x 2732 | iPad 対応時は必須 |

### Android スクリーンショット

| 種別 | サイズ (px) | 必須枚数 |
|------|------------|---------|
| Phone | 最小 320px、最大 3840px（長辺） | 最低 2 枚、最大 8 枚 |
| 7" Tablet | 推奨 1200 x 1920 | タブレット対応時 |
| 10" Tablet | 推奨 1800 x 2560 | タブレット対応時 |

### スクリーンショット作成のガイドライン

- ステータスバーは**含めない**（フレーム付きモックアップ推奨）
- テキストオーバーレイは主要機能を簡潔に説明する
- 最初の 2 枚が最も重要（検索結果で表示される）
- ダークモード対応の場合、ライト / ダーク両方を用意する

---

## 3. メタデータテンプレート

### アプリ名（30 文字以内）

```
[アプリ名] - [主要機能キーワード]
例: TaskFlow - タスク管理 & ToDo
```

### 説明文テンプレート（4000 文字以内）

```
[1行目: キャッチコピー（最重要 — 検索結果に表示される）]

[主要機能 3〜5 つを箇条書き]
- 機能1の説明
- 機能2の説明
- 機能3の説明

[差別化ポイント]

[利用シーン]

[サポート情報]
お問い合わせ: support@example.com
利用規約: https://example.com/terms
プライバシーポリシー: https://example.com/privacy
```

### キーワード（iOS のみ、100 文字以内）

```
keyword1,keyword2,keyword3,keyword4
```

- カンマ区切り、スペースなし
- アプリ名と重複するキーワードは含めない
- 競合アプリ名は使用禁止

---

## 4. プライバシーポリシー URL チェック

提出前に以下を確認する。

```bash
# URL アクセス確認
curl -sI https://example.com/privacy | head -5

# 必須記載項目
# - 収集するデータの種類
# - データの利用目的
# - 第三者への共有の有無
# - データの保存期間
# - ユーザーの権利（削除要求等）
# - 連絡先
```

---

## 5. App Tracking Transparency (iOS)

### Info.plist 設定

```xml
<key>NSUserTrackingUsageDescription</key>
<string>パーソナライズされた広告を表示するために、トラッキングの許可をお願いしています。</string>
```

### 実装確認

- ATT ダイアログは**アプリ起動直後に表示しない**（UX 低下）
- 機能説明の後や、広告表示前に表示するのが推奨
- `ATTrackingManager.requestTrackingAuthorization` の戻り値を正しくハンドリングする
- トラッキング拒否時もアプリが正常に動作することを確認する

---

## 6. Data Safety (Android)

Google Play Console の Data Safety セクションで以下を記入する。

| 質問 | 確認内容 |
|------|---------|
| データ収集 | アプリが収集するデータの種類（位置情報、個人情報等） |
| データ共有 | 第三者と共有するデータの有無 |
| セキュリティ | データの暗号化、削除リクエストへの対応 |
| データ種別 | 位置情報、個人情報、財務情報、健康情報、等 |

Firebase Analytics / Crashlytics を使用している場合、それらが収集するデータも Data Safety に含める。

---

## 7. レビュー申請時の注意事項

### 一般的なリジェクト理由と対策

| リジェクト理由 | 対策 |
|--------------|------|
| バグ・クラッシュ | リリースビルドで全画面テスト |
| 不完全な機能 | プレースホルダーやダミーデータを残さない |
| ログイン必須でテストアカウント未提供 | Review Notes にテストアカウント情報を記載 |
| プライバシーポリシー不備 | GDPR / CCPA 対応の記載を含める |
| パーミッション過剰 | 使用しないパーミッションを削除 |
| Guideline 4.3 (Spam) | 他アプリとの差別化を明確にする |

### Review Notes テンプレート

```
Test Account:
- Email: test@example.com
- Password: TestPass123!

Notes:
- [Feature X] requires [specific condition] to test.
- Demo mode is available without login.
```

---

## 8. Fastlane 自動化コマンド

### iOS (Fastlane deliver)

```bash
# メタデータとスクリーンショットのアップロード
fastlane deliver \
  --submit_for_review \
  --automatic_release \
  --skip_binary_upload \
  --force

# スクリーンショットのみアップロード
fastlane deliver --skip_binary_upload --skip_metadata
```

### Android (Fastlane supply)

```bash
# APK/AAB のアップロード（内部テスト）
fastlane supply \
  --track internal \
  --aab build/app/outputs/bundle/release/app-release.aab

# メタデータのアップロード
fastlane supply \
  --skip_upload_apk \
  --skip_upload_aab \
  --skip_upload_images
```

### Fastlane ディレクトリ構成

```
fastlane/
├── Appfile
├── Fastfile
├── metadata/
│   ├── ja/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   ├── privacy_url.txt
│   │   └── release_notes.txt
│   └── en-US/
│       └── ...
└── screenshots/
    ├── ja/
    │   ├── iPhone67_01.png
    │   ├── iPhone67_02.png
    │   └── ...
    └── en-US/
        └── ...
```
