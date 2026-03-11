---
name: deeplink-setup
description: Configure Universal Links (iOS), App Links (Android), and Flutter deep linking with step-by-step guides.
---

# ディープリンク設定スキル

Universal Links (iOS)、App Links (Android)、Flutter のディープリンク処理をステップバイステップで設定するスキル。設定ファイルの作成からテスト・デバッグまでを網羅する。

---

## 1. Universal Links (iOS)

### 1.1 apple-app-site-association (AASA) ファイル

Web サーバーのルート (`/.well-known/`) に配置する JSON ファイル。**署名不要**（iOS 14+ は自動検証）。

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAM_ID.com.company.appname"],
        "paths": [
          "/products/*",
          "/users/*/profile",
          "/share/*",
          "NOT /api/*",
          "NOT /admin/*"
        ],
        "components": [
          {
            "/": "/products/*",
            "comment": "商品詳細ページ"
          },
          {
            "/": "/invite/*",
            "?": { "code": "?*" },
            "comment": "招待リンク（code パラメータ必須）"
          }
        ]
      }
    ]
  }
}
```

### 配置要件

| 項目 | 要件 |
|------|------|
| URL | `https://example.com/.well-known/apple-app-site-association` |
| Content-Type | `application/json` |
| HTTPS | **必須**（自己署名証明書は不可） |
| リダイレクト | 不可（直接レスポンスを返すこと） |
| ファイルサイズ | 128 KB 以下 |

### 1.2 Associated Domains 設定

#### Xcode 設定

1. Target > Signing & Capabilities > `+ Capability` > Associated Domains
2. 以下を追加:

```
applinks:example.com
applinks:www.example.com
```

#### Flutter (ios/Runner/Runner.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:example.com</string>
        <string>applinks:www.example.com</string>
    </array>
</dict>
</plist>
```

### 1.3 iOS アプリ側の処理

```swift
// SceneDelegate.swift (UIKit)
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else { return }
    handleDeepLink(url: url)
}

// SwiftUI
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url: url)
                }
        }
    }
}
```

---

## 2. App Links (Android)

### 2.1 assetlinks.json ファイル

Web サーバーの `/.well-known/` に配置する JSON ファイル。

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.company.appname",
      "sha256_cert_fingerprints": [
        "AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90"
      ]
    }
  }
]
```

### SHA-256 フィンガープリントの取得

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android

# Release keystore
keytool -list -v -keystore release-key.jks -alias my-key-alias

# Google Play App Signing を使用している場合
# Play Console > Setup > App signing > App signing key certificate の SHA-256 を使用
```

### 2.2 intent-filter 設定

#### AndroidManifest.xml

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask">

    <!-- App Links (自動検証) -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="https"
            android:host="example.com"
            android:pathPrefix="/products" />
    </intent-filter>

    <!-- カスタム URI スキーム（フォールバック） -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="myapp"
            android:host="open" />
    </intent-filter>
</activity>
```

### 2.3 Android アプリ側の処理

```kotlin
// MainActivity.kt
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    handleIntent(intent)
}

override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    handleIntent(intent)
}

private fun handleIntent(intent: Intent) {
    val action = intent.action
    val data = intent.data
    if (action == Intent.ACTION_VIEW && data != null) {
        val path = data.path ?: return
        when {
            path.startsWith("/products/") -> navigateToProduct(data.lastPathSegment)
            path.startsWith("/users/") -> navigateToUser(data.pathSegments[1])
        }
    }
}
```

---

## 3. Flutter ディープリンク処理

### 3.1 go_router でのディープリンク

```dart
// router.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),
    GoRoute(
      path: '/users/:userId/profile',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/invite',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return InviteScreen(code: code);
      },
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
```

### 3.2 FlutterDeepLinkingEnabled 設定

```xml
<!-- ios/Runner/Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="true" />
```

---

## 4. テスト方法

### iOS テスト

```bash
# シミュレータでテスト
xcrun simctl openurl booted "https://example.com/products/123"

# 実機でテスト（Safari からリンクをタップ）
# Notes アプリに URL を貼り付けてタップする方法も有効
```

### Android テスト

```bash
# エミュレータ / 実機でテスト
adb shell am start -a android.intent.action.VIEW \
  -d "https://example.com/products/123" \
  com.company.appname

# App Links の検証状態を確認
adb shell pm get-app-links com.company.appname
```

### Flutter テスト

```bash
# flutter test でユニットテスト
flutter test test/routing/deeplink_test.dart

# Integration Test
flutter test integration_test/deeplink_integration_test.dart
```

---

## 5. デバッグ手順

### 問題が発生した場合の確認フロー

```
1. AASA / assetlinks.json がアクセス可能か確認
   └→ curl -sI https://example.com/.well-known/apple-app-site-association
   └→ curl -sI https://example.com/.well-known/assetlinks.json

2. Content-Type が application/json か確認

3. Apple CDN のキャッシュを確認（iOS）
   └→ https://app-site-association.cdn-apple.com/a/v1/example.com

4. Digital Asset Links API で検証（Android）
   └→ https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://example.com&relation=delegate_permission/common.handle_all_urls

5. アプリの Associated Domains / intent-filter 設定を再確認

6. アプリを再インストールして検証（キャッシュクリア）
```

### よくあるトラブルと対処法

| 症状 | 原因 | 対処法 |
|------|------|--------|
| リンクがブラウザで開く | AASA / assetlinks.json が見つからない | ファイルの配置とアクセスを確認 |
| 検証が通らない (iOS) | CDN キャッシュが古い | 24 時間待つか、アプリ再インストール |
| 検証が通らない (Android) | SHA-256 フィンガープリント不一致 | `keytool` で正しいフィンガープリントを取得 |
| 特定のパスだけ動かない | paths / pathPrefix の設定ミス | ワイルドカードの記法を確認 |
| 開発環境で動かない | localhost は Universal Links 非対応 | ngrok 等で HTTPS URL を作成 |
