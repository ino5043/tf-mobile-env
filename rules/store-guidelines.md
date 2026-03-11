# Store Guidelines Rules

App Store および Google Play のストアガイドライン準拠に関する必須ルール。リジェクトを回避し、スムーズな審査通過を実現する。

---

## 1. App Store Review Guidelines 主要ポイント

### 安全性（Safety）

| 項目 | 要件 | 対応 |
|------|------|------|
| ユーザーデータ保護 | 収集するデータを明示、最小限に | Privacy Manifest (PrivacyInfo.xcprivacy) |
| App Tracking Transparency | IDFA 使用時は ATT フレームワーク必須 | AppTrackingTransparency.requestTrackingAuthorization() |
| 暗号化使用申告 | HTTPS 以外の暗号化使用時に申告 | Export Compliance Information |
| 児童保護 | 13歳未満向けアプリは COPPA 準拠 | 年齢制限、ペアレンタルコントロール |

### パフォーマンス

| 項目 | 要件 | 対応 |
|------|------|------|
| クラッシュ率 | 審査中にクラッシュしないこと | Crashlytics 監視、テスト徹底 |
| 完成度 | Beta / テスト版は不可 | TestFlight は審査前の内部テスト |
| レスポンス時間 | 起動後すぐに操作可能 | スプラッシュ画面 + 非同期初期化 |
| ネットワーク依存 | オフラインでも基本機能が動作 | オフライン対応（offline-first.md 参照） |

### ビジネス

| 項目 | 要件 | リスク |
|------|------|--------|
| アプリ内課金（IAP） | デジタルコンテンツは IAP 必須 | 外部課金リンクは原則禁止 |
| サブスクリプション | 自動更新の説明、キャンセル方法の明示 | 不明確だとリジェクト |
| 無料トライアル | トライアル終了後の料金を明示 | 隠された課金はリジェクト |
| 広告 | 過度な広告、操作を妨げる広告は禁止 | フルスクリーン広告の頻度制限 |

### デザイン（HIG 準拠）

| 項目 | 要件 |
|------|------|
| ナビゲーション | iOS 標準パターン（TabBar, NavigationStack）の使用推奨 |
| 権限リクエスト | 使用目的の説明（NSUsageDescription）必須 |
| ノッチ / Dynamic Island | システム UI 領域を侵害しないこと |
| ダークモード | 推奨（必須ではない） |

### 法律

| 項目 | 要件 |
|------|------|
| プライバシーポリシー | App Store Connect に URL 登録必須 |
| 利用規約 | アカウント作成機能がある場合は必須 |
| GDPR / CCPA | 対象地域のユーザーがいる場合は準拠必須 |
| ライセンス表記 | OSS ライセンスの適切な表記 |

---

## 2. Google Play Developer Policy 主要ポイント

### コンテンツポリシー

| 項目 | 要件 | 対応 |
|------|------|------|
| コンテンツレーティング | IARC レーティング質問票の回答 | Play Console で設定 |
| ユーザー生成コンテンツ | モデレーション機能必須 | 報告・ブロック機能 |
| 知的財産権 | 第三者の著作物を無断使用しない | ライセンス確認 |
| ギャンブル | 各国の法律に準拠 | 地域制限の実装 |

### Target API Level 要件

| 期限 | 新規アプリ | 既存アプリ更新 |
|------|-----------|---------------|
| 2025年8月31日以降 | API 35 (Android 15) | API 35 (Android 15) |
| 現行推奨 | 最新 API Level | 最新 - 1 API Level 以上 |

```groovy
// build.gradle (app)
android {
    compileSdk = 35
    defaultConfig {
        minSdk = 24      // Android 7.0 以上
        targetSdk = 35   // 最新 API Level
    }
}
```

### Data Safety セクション

Google Play Console で以下を申告する。

```
Data Safety 申告項目:
├── 収集するデータ
│   ├── 個人情報（名前、メール、電話番号等）
│   ├── 位置情報（正確な位置、おおよその位置）
│   ├── 財務情報（支払い情報、購入履歴）
│   ├── デバイス識別子
│   └── アプリアクティビティ
├── データの用途
│   ├── アプリの機能
│   ├── 分析
│   ├── 広告
│   └── 不正防止
├── データの共有
│   ├── 第三者への共有の有無
│   └── 共有先の種類
└── セキュリティ対策
    ├── 暗号化の有無
    └── データ削除リクエスト対応
```

### ストア掲載情報の要件

| 項目 | 要件 | 仕様 |
|------|------|------|
| アプリ名 | 30文字以内 | キーワード詰め込み禁止 |
| 短い説明 | 80文字以内 | アプリの核心を簡潔に |
| 詳細な説明 | 4000文字以内 | 機能、特徴を詳細に |
| スクリーンショット | 最小2枚、最大8枚 | 実際のアプリ画面 |
| フィーチャーグラフィック | 1024 x 500 px | ストアの一覧表示用 |
| アイコン | 512 x 512 px | 角丸はシステムが処理 |

---

## 3. よくあるリジェクト理由と回避策（Top 10）

| # | リジェクト理由 | 回避策 |
|---|---------------|--------|
| 1 | **クラッシュ・バグ** | 全画面遷移の E2E テスト、Crashlytics 監視 |
| 2 | **不完全な機能** | プレースホルダーや「Coming Soon」を残さない |
| 3 | **権限の説明不足** | NSUsageDescription に具体的な使用目的を記載 |
| 4 | **プライバシーポリシー不備** | URL を設定し、内容を最新に保つ |
| 5 | **IAP 以外の課金誘導** | デジタルコンテンツは StoreKit / Google Play Billing |
| 6 | **メタデータの不正確さ** | スクリーンショットが実際のアプリと一致すること |
| 7 | **ログイン必須の不備** | テストアカウントを審査チームに提供 |
| 8 | **サードパーティ SDK のポリシー違反** | 使用する SDK のプライバシーポリシーを確認 |
| 9 | **最低機能要件の未達** | Web ラッパーのみのアプリは不可 |
| 10 | **年齢制限の不適切設定** | コンテンツに応じた適切なレーティング |

### 審査用テストアカウントの提供

```
App Store Connect / Google Play Console で以下を設定:

審査用情報:
- デモアカウント: reviewer@example.com / TestPass123!
- テストクレジットカード: (sandbox 環境のテストカード情報)
- 特記事項: 「位置情報を使用する機能は東京都内でのみ動作します」

注意: テストアカウントは有効期限を設けず、審査中に無効化しないこと
```

---

## 4. 権限リクエストの実装

### iOS: NSUsageDescription

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>商品のバーコードをスキャンするためにカメラを使用します</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>近くの店舗を検索するために位置情報を使用します</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>プロフィール画像を設定するために写真ライブラリにアクセスします</string>

<key>NSMicrophoneUsageDescription</key>
<string>音声メモを録音するためにマイクを使用します</string>
```

### 権限リクエストのベストプラクティス

```dart
// ❌ BAD: アプリ起動直後にすべての権限を要求
void initState() {
  super.initState();
  requestAllPermissions(); // ユーザーが拒否する可能性が高い
}

// ✅ GOOD: 必要なタイミングで、理由を説明してから要求
Future<void> _onScanBarcode() async {
  // 1. まず権限の状態を確認
  final status = await Permission.camera.status;

  if (status.isDenied) {
    // 2. 使用目的を説明するダイアログを表示
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カメラへのアクセス'),
        content: const Text(
          '商品のバーコードをスキャンするためにカメラを使用します。'
          'この機能はカメラへのアクセス許可が必要です。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('許可する'),
          ),
        ],
      ),
    );

    if (shouldRequest != true) return;

    // 3. システムの権限ダイアログを表示
    final result = await Permission.camera.request();
    if (!result.isGranted) return;
  }

  // 4. 権限がある状態で機能を実行
  await startBarcodeScanner();
}
```

---

## 5. プライバシーポリシーテンプレート

```dart
// アプリ内にプライバシーポリシーへのリンクを設置
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ... 他の設定項目
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('プライバシーポリシー'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(
            Uri.parse('https://example.com/privacy-policy'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('利用規約'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(
            Uri.parse('https://example.com/terms-of-service'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('ライセンス情報'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'MyApp',
            applicationVersion: '1.0.0',
          ),
        ),
      ],
    );
  }
}
```

### プライバシーポリシーに含める必須項目

```
プライバシーポリシー必須項目:
1. 収集する情報の種類
   - 個人情報（名前、メール、電話番号）
   - 使用状況データ（操作ログ、クラッシュレポート）
   - デバイス情報（OS バージョン、デバイスモデル）

2. 情報の利用目的
   - サービス提供
   - サービス改善
   - カスタマーサポート
   - マーケティング（opt-in の場合のみ）

3. 情報の共有先
   - 分析ツール（Firebase Analytics 等）
   - 広告プラットフォーム（使用する場合）
   - 法的要請への対応

4. データの保持期間

5. ユーザーの権利
   - データアクセス権
   - データ削除権
   - オプトアウト権

6. セキュリティ対策

7. 問い合わせ先
```

---

## 6. iOS Privacy Manifest (PrivacyInfo.xcprivacy)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeEmailAddress</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## 7. リリース前チェック

### App Store 提出前

```
App Store 提出チェック:
├── ビルド
│   ├── Archive ビルドが成功するか
│   ├── TestFlight で内部テスト済みか
│   └── 最低 iOS バージョンが適切か
├── メタデータ
│   ├── アプリ名（30文字以内）
│   ├── サブタイトル（30文字以内）
│   ├── キーワード（100文字以内）
│   ├── 説明文（4000文字以内）
│   ├── スクリーンショット（6.7", 6.5", 5.5" は必須）
│   └── プレビュー動画（任意、30秒以内）
├── 設定
│   ├── Privacy Policy URL
│   ├── Support URL
│   ├── コンテンツレーティング
│   ├── 年齢制限
│   └── 審査用テストアカウント
└── コンプライアンス
    ├── 暗号化使用の申告
    ├── Privacy Manifest (PrivacyInfo.xcprivacy)
    └── 必要なライセンス表記
```

### Google Play 提出前

```
Google Play 提出チェック:
├── ビルド
│   ├── App Bundle (.aab) 形式でビルド
│   ├── Target SDK が最新要件を満たすか
│   └── 64bit 対応 (arm64-v8a)
├── ストア掲載情報
│   ├── アプリ名（30文字以内）
│   ├── 短い説明（80文字以内）
│   ├── 詳細な説明（4000文字以内）
│   ├── スクリーンショット（最低2枚）
│   ├── フィーチャーグラフィック (1024x500)
│   └── アイコン (512x512)
├── Data Safety
│   ├── データ収集の申告
│   ├── データ共有の申告
│   └── セキュリティ対策の申告
├── コンテンツレーティング
│   └── IARC 質問票の回答
└── コンプライアンス
    ├── プライバシーポリシー URL
    ├── 広告の有無
    └── ターゲット年齢層
```

---

## チェックリスト

### 共通
- [ ] プライバシーポリシーが公開 URL で利用可能か
- [ ] 利用規約が用意されているか（アカウント機能がある場合は必須）
- [ ] コンテンツレーティングが適切に設定されているか
- [ ] OSS ライセンス表記がアプリ内に含まれているか
- [ ] テストアカウント情報が審査チームに提供されているか

### App Store 固有
- [ ] Privacy Manifest (PrivacyInfo.xcprivacy) が含まれているか
- [ ] NSUsageDescription に具体的な説明があるか
- [ ] IAP の実装が StoreKit を使用しているか
- [ ] スクリーンショットが必要な全サイズ分あるか
- [ ] 暗号化使用の申告が正確か

### Google Play 固有
- [ ] Target API Level が最新要件を満たしているか
- [ ] App Bundle (.aab) 形式でアップロードしているか
- [ ] Data Safety セクションが正確に記入されているか
- [ ] 64bit ネイティブライブラリが含まれているか
- [ ] フィーチャーグラフィック (1024x500) が用意されているか

### リリース後
- [ ] クラッシュレポート（Crashlytics）を監視しているか
- [ ] ユーザーレビューを定期的に確認しているか
- [ ] ストアガイドラインの更新を追跡しているか
- [ ] 証明書の有効期限を管理しているか（iOS: 1年、Android: 25年+）
