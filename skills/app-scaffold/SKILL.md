---
name: app-scaffold
description: Generate mobile project templates with Clean Architecture, pre-configured state management, and standard directory structure.
---

# アプリスキャフォールドスキル

Flutter プロジェクトのテンプレート生成を支援するスキル。Clean Architecture ディレクトリ構成、状態管理の初期設定、推奨パッケージリスト、ネイティブ (Swift / Kotlin) プロジェクトの概要を提供する。

---

## 1. Clean Architecture ディレクトリ構成

### Flutter プロジェクト構成

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # カラー定数
│   │   ├── app_strings.dart         # 文字列定数
│   │   └── app_dimensions.dart      # サイズ定数
│   ├── error/
│   │   ├── exceptions.dart          # 例外クラス
│   │   └── failures.dart            # Failure クラス（Result 型用）
│   ├── network/
│   │   ├── api_client.dart          # HTTP クライアント
│   │   └── network_info.dart        # 接続状態チェック
│   ├── theme/
│   │   ├── app_theme.dart           # ThemeData 定義
│   │   └── text_styles.dart         # テキストスタイル
│   ├── utils/
│   │   ├── date_formatter.dart      # 日付フォーマット
│   │   ├── validators.dart          # バリデーション
│   │   └── logger.dart              # ログ出力
│   └── di/
│       └── injection_container.dart # 依存性注入設定
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── social_login_button.dart
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── app.dart                          # MaterialApp 定義
└── main.dart                         # エントリポイント
```

### テストディレクトリ構成

```
test/
├── core/
│   └── utils/
│       └── validators_test.dart
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── auth_remote_datasource_test.dart
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── login_usecase_test.dart
│       └── presentation/
│           ├── bloc/
│           │   └── auth_bloc_test.dart
│           └── pages/
│               └── login_page_test.dart
├── goldens/                          # Golden テストファイル
│   └── login_page.png
└── helpers/
    ├── test_helpers.dart
    └── mock_classes.dart

integration_test/
├── app_test.dart
└── helpers/
    └── test_helpers.dart
```

---

## 2. 初期設定ファイル

### analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'

linter:
  rules:
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_unnecessary_containers
    - avoid_web_libraries_in_flutter
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - no_logic_in_create_state
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - prefer_void_to_null
    - sized_box_for_whitespace
    - sort_child_properties_last
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - use_build_context_synchronously
    - use_key_in_widget_constructors
```

### pubspec.yaml テンプレート

```yaml
name: app_name
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management (BLoC の場合)
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0

  # DI
  get_it: ^7.7.0
  injectable: ^2.4.0

  # Network
  dio: ^5.4.0
  retrofit: ^4.1.0

  # Storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.2.0

  # Navigation
  go_router: ^14.0.0

  # Utilities
  intl: ^0.19.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  injectable_generator: ^2.6.0
  retrofit_generator: ^8.1.0

  # Testing
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  golden_toolkit: ^0.15.0

flutter:
  uses-material-design: true
```

---

## 3. 推奨パッケージリスト

### 状態管理

| パッケージ | 用途 | 推奨度 |
|-----------|------|--------|
| `flutter_bloc` | BLoC パターン | 大規模向け |
| `flutter_riverpod` | Riverpod パターン | 中〜大規模向け |
| `provider` | Provider パターン | 小規模向け |

### DI (Dependency Injection)

| パッケージ | 用途 |
|-----------|------|
| `get_it` | サービスロケータ |
| `injectable` | get_it のコード生成 |

### ネットワーク

| パッケージ | 用途 |
|-----------|------|
| `dio` | HTTP クライアント |
| `retrofit` | 型安全な REST API クライアント |
| `connectivity_plus` | ネットワーク接続状態 |

### ストレージ

| パッケージ | 用途 |
|-----------|------|
| `shared_preferences` | Key-Value ストレージ |
| `flutter_secure_storage` | セキュアストレージ（トークン等） |
| `hive` | 軽量 NoSQL データベース |
| `drift` | SQLite ORM |

### UI / UX

| パッケージ | 用途 |
|-----------|------|
| `cached_network_image` | 画像キャッシュ |
| `shimmer` | ローディングプレースホルダー |
| `flutter_svg` | SVG 表示 |
| `lottie` | Lottie アニメーション |

### コード生成

| パッケージ | 用途 |
|-----------|------|
| `freezed` | イミュータブルクラス生成 |
| `json_serializable` | JSON シリアライズ |
| `build_runner` | コード生成実行 |

### テスト

| パッケージ | 用途 |
|-----------|------|
| `mocktail` | モック生成（コード生成不要） |
| `bloc_test` | BLoC テスト |
| `golden_toolkit` | Golden テスト |

---

## 4. 基盤クラスのテンプレート

### UseCase 基底クラス

```dart
// core/usecases/usecase.dart
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

### Failure 基底クラス

```dart
// core/error/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
```

### API Client 設定

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';

Dio createDio({required String baseUrl, String? token}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  ));

  dio.interceptors.addAll([
    LogInterceptor(requestBody: true, responseBody: true),
    // RetryInterceptor, AuthInterceptor, etc.
  ]);

  return dio;
}
```

---

## 5. Swift (iOS) プロジェクトテンプレート概要

```
AppName/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Core/
│   ├── DI/
│   ├── Network/
│   ├── Storage/
│   └── Extensions/
├── Features/
│   └── Auth/
│       ├── Data/
│       ├── Domain/
│       └── Presentation/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
└── Supporting/
    └── LaunchScreen.storyboard
```

- アーキテクチャ: MVVM + Clean Architecture
- DI: Swinject or Swift Concurrency
- ネットワーク: URLSession + async/await or Alamofire
- 状態管理: Combine + @Published or SwiftUI @Observable

---

## 6. Kotlin (Android) プロジェクトテンプレート概要

```
app/src/main/java/com/company/appname/
├── di/
│   ├── AppModule.kt
│   └── NetworkModule.kt
├── core/
│   ├── network/
│   ├── storage/
│   └── utils/
├── features/
│   └── auth/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── MyApplication.kt
```

- アーキテクチャ: MVVM + Clean Architecture
- DI: Hilt (Dagger)
- ネットワーク: Retrofit + OkHttp
- 状態管理: ViewModel + StateFlow
- ナビゲーション: Jetpack Navigation or Navigation Compose
