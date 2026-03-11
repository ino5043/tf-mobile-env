---
description: Run store guidelines compliance check for App Store and Google Play submission readiness.
---

# /store-check コマンド

App Store と Google Play のストアガイドライン準拠チェックを実行するコマンド。提出前に必要な設定・メタデータの完成度を自動検証する。

---

## 実行手順

### 1. iOS チェック (Info.plist / Xcode 設定)

以下の項目を `ios/Runner/Info.plist` と Xcode プロジェクト設定から検証する。

| # | チェック項目 | 検証方法 |
|---|------------|---------|
| 1 | `CFBundleDisplayName` が設定されているか | Info.plist を読み取り |
| 2 | `CFBundleShortVersionString` がセマンティックバージョニングか | 正規表現 `^\d+\.\d+\.\d+$` |
| 3 | `CFBundleVersion` がインクリメントされているか | 前回ビルドと比較 |
| 4 | `NSCameraUsageDescription` 等のプライバシー説明文 | カメラ・位置情報等を使用する場合に必須 |
| 5 | `NSUserTrackingUsageDescription` (ATT) | 広告 SDK 使用時に必須 |
| 6 | `ITSAppUsesNonExemptEncryption` | 暗号化使用の申告 |
| 7 | `UILaunchStoryboardName` | Launch Screen が設定されているか |
| 8 | App Icons (1024x1024) | `Assets.xcassets/AppIcon.appiconset` の確認 |
| 9 | Minimum iOS Version | `MinimumOSVersion` が適切か（iOS 16.0+ 推奨） |
| 10 | Associated Domains | Universal Links 使用時に entitlements を確認 |

### 2. Android チェック (AndroidManifest.xml / build.gradle)

| # | チェック項目 | 検証方法 |
|---|------------|---------|
| 1 | `applicationId` が正しいか | `android/app/build.gradle` を確認 |
| 2 | `versionCode` がインクリメントされているか | 前回ビルドと比較 |
| 3 | `targetSdkVersion` が最新要件を満たすか | API 34+ (2024年要件) |
| 4 | `minSdkVersion` が適切か | API 23+ (Android 6.0) 推奨 |
| 5 | パーミッション一覧 | 不要なパーミッションが含まれていないか |
| 6 | `android:exported` | Activity / Service / Receiver に明示されているか |
| 7 | ProGuard / R8 ルール | `proguard-rules.pro` が設定されているか |
| 8 | App Icons | Adaptive Icon (foreground + background) が存在するか |
| 9 | `android:usesCleartextTraffic` | `false` に設定されているか |
| 10 | 64-bit サポート | `arm64-v8a` ABI が含まれているか |

### 3. メタデータ完成度チェック

Fastlane メタデータディレクトリ、または手動管理のメタデータを確認する。

```
fastlane/metadata/ja/
├── name.txt              ← 30文字以内
├── subtitle.txt          ← 30文字以内 (iOS)
├── description.txt       ← 4000文字以内
├── keywords.txt          ← 100文字以内 (iOS)
├── privacy_url.txt       ← URL が有効か
├── support_url.txt       ← URL が有効か
└── release_notes.txt     ← 4000文字以内
```

| チェック項目 | 基準 |
|------------|------|
| アプリ名 | 30 文字以内、不適切な用語なし |
| 説明文 | 1 行目にキャッチコピー、箇条書きで機能説明 |
| キーワード (iOS) | カンマ区切り、100 文字以内 |
| スクリーンショット | 必要デバイス分が揃っているか |
| プライバシーポリシー URL | HTTPS でアクセス可能か |

### 4. プライバシーポリシー URL 確認

```bash
# URL のアクセス確認
curl -sI https://example.com/privacy | head -5

# 期待するレスポンス
# HTTP/2 200
# content-type: text/html
```

プライバシーポリシーに以下の項目が含まれているかを確認する。

- 収集するデータの種類
- データの利用目的
- 第三者への共有
- データの保存期間
- ユーザーの権利（削除要求等）
- 連絡先情報

### 5. レポート出力

```markdown
## Store Readiness Report

### iOS
| 項目 | ステータス | 備考 |
|------|----------|------|
| Info.plist | PASS/FAIL | 詳細 |
| App Icons | PASS/FAIL | 詳細 |
| Privacy | PASS/FAIL | 詳細 |
| Metadata | PASS/FAIL | 詳細 |

### Android
| 項目 | ステータス | 備考 |
|------|----------|------|
| Manifest | PASS/FAIL | 詳細 |
| Target API | PASS/FAIL | 詳細 |
| Permissions | PASS/FAIL | 詳細 |
| Metadata | PASS/FAIL | 詳細 |

### Overall: READY / NOT READY
未対応項目: N 件
```
