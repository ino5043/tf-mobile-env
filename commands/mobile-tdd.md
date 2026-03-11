---
description: Start mobile test-driven development workflow with Widget Test, Unit Test, and Golden Test support.
---

# /mobile-tdd コマンド

Flutter モバイルアプリの TDD (Test-Driven Development) ワークフローを開始するコマンド。Widget Test、Unit Test、Golden Test を活用した開発フローを支援する。

---

## 実行手順

### 1. mobile-tdd-guide エージェント起動

`mobile-tdd-guide` エージェントを起動し、以下の TDD ワークフローを実行する。

### 2. Flutter TDD ワークフロー

#### Step 1: テストファイル作成

実装ファイルに対応するテストファイルを作成する。

```
lib/features/auth/domain/usecases/login_usecase.dart
  → test/features/auth/domain/usecases/login_usecase_test.dart

lib/features/auth/presentation/bloc/auth_bloc.dart
  → test/features/auth/presentation/bloc/auth_bloc_test.dart

lib/features/auth/presentation/pages/login_page.dart
  → test/features/auth/presentation/pages/login_page_test.dart
```

#### Step 2: テスト作成 (RED)

テストを先に書く。この時点ではテストは **失敗する** ことを確認する。

**Unit Test 例:**

```dart
// test/features/auth/domain/usecases/login_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  group('LoginUseCase', () {
    test('should return User when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(
        LoginParams(email: 'test@example.com', password: 'password123'),
      );

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepository.login(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      when(() => mockRepository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await useCase(
        LoginParams(email: 'test@example.com', password: 'wrong'),
      );

      // Assert
      expect(result, Left(ServerFailure()));
    });
  });
}
```

**Widget Test 例:**

```dart
// test/features/auth/presentation/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('should display email and password fields', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('メールアドレス'), findsOneWidget);
      expect(find.text('パスワード'), findsOneWidget);
    });

    testWidgets('should show loading indicator when AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when AuthError', (tester) async {
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthError(message: 'ログインに失敗しました'));

      await tester.pumpWidget(createWidget());

      expect(find.text('ログインに失敗しました'), findsOneWidget);
    });
  });
}
```

#### Step 3: 実装 (GREEN)

テストが通る最小限の実装を行う。

```bash
# テスト実行で GREEN を確認
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
flutter test test/features/auth/presentation/pages/login_page_test.dart
```

#### Step 4: Golden Test 追加

Widget のスクリーンショットを保存し、UI の回帰テストを行う。

```dart
// test/features/auth/presentation/pages/login_page_golden_test.dart
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('LoginPage - initial state', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
        Device.tabletLandscape,
      ])
      ..addScenario(
        widget: createWidget(state: const AuthInitial()),
        name: 'initial',
      )
      ..addScenario(
        widget: createWidget(state: const AuthLoading()),
        name: 'loading',
      )
      ..addScenario(
        widget: createWidget(state: const AuthError(message: 'エラー')),
        name: 'error',
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'login_page');
  });
}
```

```bash
# Golden ファイルの初回生成
flutter test --update-goldens test/features/auth/presentation/pages/login_page_golden_test.dart

# Golden テスト実行（スクリーンショット比較）
flutter test test/features/auth/presentation/pages/login_page_golden_test.dart
```

#### Step 5: カバレッジ確認 (80%+)

```bash
# カバレッジレポート生成
flutter test --coverage

# HTML レポート生成（lcov が必要）
genhtml coverage/lcov.info -o test-results/coverage-html

# カバレッジ率確認
lcov --summary coverage/lcov.info
```

### 3. テスト実行コマンド一覧

| コマンド | 用途 |
|---------|------|
| `flutter test` | 全テスト実行 |
| `flutter test test/path/to/test.dart` | 特定テスト実行 |
| `flutter test --coverage` | カバレッジ付きテスト実行 |
| `flutter test --update-goldens` | Golden ファイル更新 |
| `flutter test --reporter=json > results.json` | JSON レポート出力 |
| `flutter test --tags=unit` | タグでフィルタ |

### 4. TDD サイクルの確認

各サイクルで以下を確認する。

```
RED   → テストを書いて実行 → 失敗することを確認
GREEN → 最小限の実装 → テストが通ることを確認
REFACTOR → コードを改善 → テストが引き続き通ることを確認
GOLDEN → UI のスナップショット → 視覚的回帰がないことを確認
COVERAGE → 80% 以上を維持 → カバレッジが下がっていないことを確認
```
