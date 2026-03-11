---
name: ci-mobile
description: Configure mobile CI/CD pipelines with Fastlane and GitHub Actions or Codemagic for automated builds and deployments.
---

# モバイル CI/CD スキル

GitHub Actions、Codemagic、Fastlane を組み合わせたモバイル CI/CD パイプラインの構築を支援するスキル。ビルド、テスト、コード署名、デプロイの自動化テンプレートを提供する。

---

## 1. GitHub Actions for Flutter

### 1.1 基本ワークフロー（テスト + ビルド）

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage --reporter=json > test-results/test-report.json

      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')
          echo "Coverage: ${COVERAGE}%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%"
            exit 1
          fi

      - name: Upload test results
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            test-results/
            coverage/
          retention-days: 400
        if: always()

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: ${{ env.JAVA_VERSION }}

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Build APK
        run: flutter build apk --release

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 30

      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: android-aab
          path: build/app/outputs/bundle/release/app-release.aab
          retention-days: 30

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign

      - name: Upload iOS build
        uses: actions/upload-artifact@v4
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app
          retention-days: 30
```

---

## 2. Codemagic 設定テンプレート

```yaml
# codemagic.yaml
workflows:
  flutter-android:
    name: Android Build
    max_build_duration: 30
    instance_type: mac_mini_m2
    environment:
      flutter: 3.24.0
      java: 17
      groups:
        - google_play_credentials
      vars:
        PACKAGE_NAME: "com.company.appname"
    scripts:
      - name: Install dependencies
        script: flutter pub get
      - name: Run tests
        script: flutter test
      - name: Build AAB
        script: flutter build appbundle --release
    artifacts:
      - build/**/outputs/**/*.aab
      - build/**/outputs/**/mapping.txt
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal

  flutter-ios:
    name: iOS Build
    max_build_duration: 60
    instance_type: mac_mini_m2
    environment:
      flutter: 3.24.0
      xcode: latest
      cocoapods: default
      groups:
        - app_store_credentials
    integrations:
      app_store_connect: Codemagic
    scripts:
      - name: Install dependencies
        script: flutter pub get
      - name: Install pods
        script: cd ios && pod install
      - name: Set up code signing
        script: |
          xcode-project use-profiles
      - name: Build IPA
        script: flutter build ipa --release --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
```

---

## 3. Fastlane 設定

### 3.1 iOS Fastfile

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "Runner",
      devices: ["iPhone 15 Pro"],
      output_directory: "test-results",
      output_types: "junit,html"
    )
  end

  desc "Build and deploy to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']

    match(type: "appstore", readonly: is_ci)

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "build",
      output_name: "Runner.ipa"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Deploy to App Store"
  lane :release do
    setup_ci if ENV['CI']

    match(type: "appstore", readonly: is_ci)

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      force: true
    )
  end
end
```

### 3.2 Android Fastfile

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Run tests"
  lane :test do
    gradle(task: "test")
  end

  desc "Build and deploy to internal track"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )

    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Promote internal to production"
  lane :release do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production",
      skip_upload_aab: true,
      skip_upload_metadata: false
    )
  end
end
```

---

## 4. コード署名の CI 設定

### 4.1 iOS: Fastlane Match

```ruby
# Matchfile
git_url("https://github.com/company/certificates.git")
storage_mode("git")
type("appstore")
app_identifier("com.company.appname")
team_id("TEAM_ID")
```

### GitHub Actions Secrets 設定

| Secret 名 | 内容 |
|-----------|------|
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 エンコードした Git 認証情報 |
| `MATCH_PASSWORD` | Match 暗号化パスワード |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API Key JSON |

### 4.2 Android: Keystore 管理

```bash
# Keystore を Base64 エンコードして Secrets に保存
base64 -i release-key.jks -o release-key.base64
```

| Secret 名 | 内容 |
|-----------|------|
| `ANDROID_KEYSTORE_BASE64` | Base64 エンコードした Keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore パスワード |
| `ANDROID_KEY_ALIAS` | Key エイリアス |
| `ANDROID_KEY_PASSWORD` | Key パスワード |

```yaml
# GitHub Actions で Keystore を復元
- name: Decode Keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/release-key.jks
```

---

## 5. テスト自動化

### Flutter テスト実行

```bash
# ユニットテスト + Widget テスト
flutter test --coverage --reporter=json > test-results/test-report.json

# Integration テスト
flutter test integration_test/ --reporter=json

# Golden テスト更新
flutter test --update-goldens
```

### テストカバレッジしきい値

```yaml
# CI でカバレッジチェック
- name: Check test coverage
  run: |
    flutter test --coverage
    LINES=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')
    if (( $(echo "$LINES < 80" | bc -l) )); then
      echo "Test coverage ${LINES}% is below 80% threshold"
      exit 1
    fi
    echo "Test coverage: ${LINES}%"
```

---

## 6. Artifact 保存

### ビルド成果物

| 成果物 | パス | 保存期間 |
|--------|------|---------|
| APK (debug) | `build/app/outputs/flutter-apk/app-debug.apk` | 7 日 |
| APK (release) | `build/app/outputs/flutter-apk/app-release.apk` | 30 日 |
| AAB (release) | `build/app/outputs/bundle/release/app-release.aab` | 30 日 |
| IPA (release) | `build/ios/ipa/*.ipa` | 30 日 |
| テスト結果 | `test-results/` | 400 日 |
| カバレッジ | `coverage/` | 400 日 |

---

## 7. GitHub Actions デプロイワークフロー

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: android

      - name: Decode Keystore
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/release-key.jks

      - name: Build AAB
        run: flutter build appbundle --release
        env:
          KEYSTORE_PATH: release-key.jks
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}

      - name: Deploy to Play Store (internal)
        run: cd android && bundle exec fastlane internal
        env:
          SUPPLY_JSON_KEY_DATA: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}

  deploy-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: ios

      - name: Deploy to TestFlight
        run: cd ios && bundle exec fastlane beta
        env:
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
```
