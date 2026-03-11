---
description: Generate device compatibility matrix and verify app behavior across target device configurations.
---

# /device-matrix コマンド

対応端末マトリクスを生成し、ターゲットデバイス構成でのアプリ動作を検証するコマンド。市場シェアに基づくテスト優先度の決定を支援する。

---

## 実行手順

### 1. iOS デバイスマトリクス生成

#### iPhone ラインナップ

| デバイス | 画面サイズ | 解像度 (px) | ポイント (pt) | スケール | テスト優先度 |
|---------|-----------|------------|--------------|---------|------------|
| iPhone SE (3rd) | 4.7" | 750 x 1334 | 375 x 667 | @2x | 高 |
| iPhone 15 | 6.1" | 1179 x 2556 | 393 x 852 | @3x | 最高 |
| iPhone 15 Plus | 6.7" | 1290 x 2796 | 430 x 932 | @3x | 中 |
| iPhone 15 Pro | 6.1" | 1179 x 2556 | 393 x 852 | @3x | 最高 |
| iPhone 15 Pro Max | 6.7" | 1290 x 2796 | 430 x 932 | @3x | 高 |
| iPhone 16 | 6.1" | 1179 x 2556 | 393 x 852 | @3x | 最高 |
| iPhone 16 Pro Max | 6.9" | 1320 x 2868 | 440 x 956 | @3x | 高 |

#### iPad ラインナップ（タブレット対応時）

| デバイス | 画面サイズ | 解像度 (px) | テスト優先度 |
|---------|-----------|------------|------------|
| iPad (10th) | 10.9" | 2360 x 1640 | 中 |
| iPad Air (M2) | 11" | 2360 x 1640 | 中 |
| iPad Pro 11" (M4) | 11" | 2420 x 1668 | 低 |
| iPad Pro 13" (M4) | 13" | 2752 x 2064 | 低 |

#### iOS バージョン

| バージョン | サポート推奨 | 市場シェア目安 |
|-----------|------------|--------------|
| iOS 18.x | 必須 | 約 60% |
| iOS 17.x | 推奨 | 約 25% |
| iOS 16.x | 任意 | 約 10% |
| iOS 15.x 以下 | 非推奨 | 約 5% |

**最小サポート推奨: iOS 16.0**（約 95% のユーザーをカバー）

### 2. Android デバイスマトリクス生成

#### 画面密度

| 密度 | DPI | スケール | 代表デバイス | テスト優先度 |
|------|-----|---------|------------|------------|
| mdpi | 160 | 1x | 一部タブレット | 低 |
| hdpi | 240 | 1.5x | 低価格帯端末 | 中 |
| xhdpi | 320 | 2x | 中価格帯端末 | 高 |
| xxhdpi | 480 | 3x | フラグシップ端末 | 最高 |
| xxxhdpi | 640 | 4x | 一部フラグシップ | 中 |

#### 画面サイズカテゴリ

| カテゴリ | 幅 (dp) | 代表デバイス | テスト優先度 |
|---------|---------|------------|------------|
| small | < 360 | 旧型端末 | 低 |
| normal | 360-411 | Pixel 7, Galaxy S23 | 最高 |
| large | 412-599 | Pixel 7 Pro, Galaxy S24 Ultra | 高 |
| xlarge | 600+ | タブレット | 中 |

#### Android OS バージョン

| バージョン | API Level | サポート推奨 | 市場シェア目安 |
|-----------|-----------|------------|--------------|
| Android 14 | API 34 | 必須 | 約 30% |
| Android 13 | API 33 | 必須 | 約 25% |
| Android 12 | API 31-32 | 推奨 | 約 15% |
| Android 11 | API 30 | 推奨 | 約 10% |
| Android 10 | API 29 | 任意 | 約 8% |
| Android 9 以下 | API 28- | 非推奨 | 約 12% |

**最小サポート推奨: Android 10 (API 29)**（約 88% のユーザーをカバー）

### 3. テスト優先度の決定

市場シェアとユーザー層に基づき、テスト優先度を 3 段階で分類する。

#### 優先度マトリクス

```
テスト優先度の決定:

Tier 1（必須テスト）:
├── iPhone 15 / 16 (6.1")
├── iPhone SE (4.7") — 最小画面サイズ
├── Android xxhdpi (360-411dp)
└── 最新 + 1世代前の OS

Tier 2（推奨テスト）:
├── iPhone Pro Max (6.7-6.9")
├── Android xhdpi / xxxhdpi
├── タブレット（iPad / Android）
└── 2世代前の OS

Tier 3（任意テスト）:
├── 特殊デバイス（折りたたみ等）
├── 低価格帯 Android
└── 3世代以上前の OS
```

### 4. Flutter 設定への反映

```yaml
# pubspec.yaml の最小 SDK バージョン
environment:
  sdk: '>=3.4.0 <4.0.0'

# android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 29    // Android 10
        targetSdkVersion 34 // Android 14
    }
}
```

```ruby
# ios/Podfile
platform :ios, '16.0'
```

### 5. レポート出力

```markdown
## Device Compatibility Matrix

### iOS Devices: N 機種
### Android Configurations: N パターン
### Minimum OS: iOS 16.0 / Android 10 (API 29)
### Coverage: iOS 95% / Android 88%

### Tier 1 (必須テスト): N 構成
### Tier 2 (推奨テスト): N 構成
### Tier 3 (任意テスト): N 構成
```
