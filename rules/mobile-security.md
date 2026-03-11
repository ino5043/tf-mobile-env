# Mobile Security Rules

モバイルアプリのセキュリティに関する必須ルール。OWASP Mobile Top 10 に準拠し、ユーザーデータと通信を保護する。

---

## 1. OWASP Mobile Top 10 対応表

| # | リスク | 対策 | 本ドキュメントのセクション |
|---|--------|------|------------------------|
| M1 | Improper Platform Usage | OS API の正しい使用 | 2, 3 |
| M2 | Insecure Data Storage | Secure Storage 使用 | 3 |
| M3 | Insecure Communication | SSL/TLS + Certificate Pinning | 2 |
| M4 | Insecure Authentication | バイオメトリクス + トークン管理 | 6 |
| M5 | Insufficient Cryptography | OS 標準の暗号 API 使用 | 3 |
| M6 | Insecure Authorization | サーバー側での権限検証 | - |
| M7 | Client Code Quality | 難読化 + コードレビュー | 5 |
| M8 | Code Tampering | Root/Jailbreak 検出 | 4 |
| M9 | Reverse Engineering | 難読化 | 5 |
| M10 | Extraneous Functionality | デバッグコード除去 | 5 |

---

## 2. 証明書ピンニング（Certificate Pinning）

MITM（中間者攻撃）を防止するため、通信先サーバーの証明書または公開鍵を事前に埋め込む。

### Dart (Flutter)

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio createPinnedClient() {
  final dio = Dio();

  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // SHA-256 フィンガープリントを検証
      const expectedFingerprint =
        'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';

      final certFingerprint = _computeFingerprint(cert);
      return certFingerprint == expectedFingerprint;
    };

    return client;
  };

  return dio;
}

// または http_certificate_pinning パッケージを使用
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

Future<void> makeSecureRequest() async {
  final response = await SecureHttpClient(
    fingerprints: [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // バックアップ
    ],
  ).get(Uri.parse('https://api.example.com/data'));
}
```

### Swift (iOS)

```swift
class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data]

    init(certificates: [String]) {
        self.pinnedCertificates = certificates.compactMap { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "cer"),
                  let data = try? Data(contentsOf: url) else { return nil }
            return data
        }
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust,
              let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let serverCertData = SecCertificateCopyData(serverCert) as Data

        if pinnedCertificates.contains(serverCertData) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

### Kotlin (Android)

```kotlin
// OkHttp Certificate Pinning
val client = OkHttpClient.Builder()
    .certificatePinner(
        CertificatePinner.Builder()
            .add(
                "api.example.com",
                "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
            )
            .add(
                "api.example.com",
                "sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=" // バックアップ
            )
            .build()
    )
    .build()

// network_security_config.xml (Android)
// res/xml/network_security_config.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2027-01-01">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
*/
```

---

## 3. シークレット管理

### Flutter: flutter_secure_storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  // iOS: Keychain, Android: EncryptedSharedPreferences (Keystore-backed)
  final FlutterSecureStorage _storage;

  SecureTokenStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

// ❌ BAD: SharedPreferences にトークンを保存
final prefs = await SharedPreferences.getInstance();
prefs.setString('access_token', token); // 暗号化されない！

// ✅ GOOD: Secure Storage を使用
final storage = SecureTokenStorage();
await storage.saveAccessToken(token);
```

### Swift: Keychain

```swift
import Security

struct KeychainHelper {
    static func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        SecItemDelete(query as CFDictionary) // 既存を削除
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    static func load(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
}
```

### Kotlin: Android Keystore

```kotlin
class SecureStorage(context: Context) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val encryptedPrefs = EncryptedSharedPreferences.create(
        context,
        "secure_prefs",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun saveToken(key: String, token: String) {
        encryptedPrefs.edit().putString(key, token).apply()
    }

    fun getToken(key: String): String? {
        return encryptedPrefs.getString(key, null)
    }

    fun clearAll() {
        encryptedPrefs.edit().clear().apply()
    }
}
```

---

## 4. Root / Jailbreak 検出

```dart
// Flutter: flutter_jailbreak_detection
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class DeviceSecurityCheck {
  Future<bool> isDeviceCompromised() async {
    final isJailbroken = await FlutterJailbreakDetection.jailbroken;
    final isDeveloperMode = await FlutterJailbreakDetection.developerMode;
    return isJailbroken || isDeveloperMode;
  }

  Future<void> enforceSecurityPolicy() async {
    if (await isDeviceCompromised()) {
      // ポリシーに応じた対応
      // 1. 警告のみ表示
      // 2. 機密機能を無効化
      // 3. アプリを終了
      throw SecurityException(
        'This app cannot run on rooted/jailbroken devices.',
      );
    }
  }
}
```

---

## 5. 難読化

### Android: R8 / ProGuard

```groovy
// build.gradle (app)
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                         'proguard-rules.pro'
        }
    }
}
```

```
# proguard-rules.pro
# Retrofit / Gson 用
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.example.app.data.dto.** { *; }

# Enum を保持
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

### Flutter: dart obfuscation

```bash
# リリースビルド時に難読化を有効化
flutter build apk --obfuscate --split-debug-info=build/debug-info/
flutter build ipa --obfuscate --split-debug-info=build/debug-info/
```

---

## 6. バイオメトリクス認証

```dart
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN/パターンもフォールバックとして許可
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // エラーハンドリング
      throw BiometricAuthException(e.code, e.message ?? 'Unknown error');
    }
  }
}

// 使用例
class LoginScreen extends StatelessWidget {
  final BiometricAuth _biometricAuth = BiometricAuth();

  Future<void> _onBiometricLogin() async {
    if (!await _biometricAuth.isAvailable()) {
      // バイオメトリクス非対応 → パスワード入力へ
      return;
    }

    final authenticated = await _biometricAuth.authenticate(
      reason: 'ログインするために認証してください',
    );

    if (authenticated) {
      // ログイン成功処理
    }
  }
}
```

---

## 7. クリップボード保護

```dart
// 機密データをクリップボードから自動削除
class ClipboardProtection {
  static Future<void> copyWithExpiry(
    String sensitiveData, {
    Duration expiry = const Duration(seconds: 30),
  }) async {
    await Clipboard.setData(ClipboardData(text: sensitiveData));

    // 指定時間後にクリップボードをクリア
    Future.delayed(expiry, () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == sensitiveData) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }
}
```

---

## 8. スクリーンキャプチャ防止

```dart
// Flutter: 画面キャプチャを防止（Android のみネイティブ対応）
// Android: MainActivity.kt
/*
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
*/

// iOS: スクリーンショット検出（防止は API 制限あり）
// AppDelegate.swift
/*
NotificationCenter.default.addObserver(
    self,
    selector: #selector(didTakeScreenshot),
    name: UIApplication.userDidTakeScreenshotNotification,
    object: nil
)

@objc func didTakeScreenshot() {
    // ログ記録、警告表示等
}
*/
```

---

## 9. SSL/TLS 設定

```dart
// ❌ BAD: SSL 検証を無効化（デバッグ時でも本番コードに残さない）
HttpClient()..badCertificateCallback = (cert, host, port) => true;

// ✅ GOOD: 適切な TLS 設定
class SecureHttpClient {
  static HttpClient create() {
    final client = HttpClient();

    // TLS 1.2 以上を強制
    client.connectionTimeout = const Duration(seconds: 30);

    // 本番では証明書検証を有効にする（デフォルト動作）
    // badCertificateCallback は設定しない

    return client;
  }
}
```

### Android: ネットワークセキュリティ設定

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <!-- 本番: HTTPS のみ許可 -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>

    <!-- デバッグ環境のみ: ローカルサーバー許可 -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

### iOS: ATS (App Transport Security)

```xml
<!-- Info.plist: デフォルトで HTTPS 強制（変更不要） -->
<!-- 例外が必要な場合のみ設定 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>legacy-api.example.com</key>
        <dict>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <!-- App Review で理由を説明する必要あり -->
        </dict>
    </dict>
</dict>
```

---

## チェックリスト

### セキュリティ実装時
- [ ] トークン・パスワードは Secure Storage（Keychain / Keystore）に保存しているか
- [ ] SharedPreferences に機密データを保存していないか
- [ ] 証明書ピンニングを実装しているか（バックアップ証明書も含む）
- [ ] SSL/TLS 検証を無効化するコードが残っていないか
- [ ] バイオメトリクス認証のフォールバック（PIN 等）を用意しているか
- [ ] リリースビルドで難読化が有効になっているか

### コードレビュー時
- [ ] ハードコードされたシークレット（API キー、パスワード）がないか
- [ ] デバッグ用のログに機密情報が出力されていないか
- [ ] Root / Jailbreak 環境での動作ポリシーが定義されているか
- [ ] クリップボードに機密データを長時間放置していないか
- [ ] HTTP 平文通信を許可する設定が残っていないか

### リリース前
- [ ] ProGuard / R8 ルールが適切に設定されているか
- [ ] Flutter `--obfuscate` フラグを有効にしているか
- [ ] ATS (iOS) / Network Security Config (Android) が適切に設定されているか
- [ ] サーバー証明書の有効期限を確認し、更新計画があるか
- [ ] OWASP Mobile Top 10 の各項目を確認したか
