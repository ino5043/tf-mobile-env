---
name: state-management
description: Guide for selecting and implementing state management patterns (BLoC, Riverpod, GetX, Redux) based on project requirements.
---

# 状態管理スキル

Flutter アプリケーションにおける状態管理パターンの選定と実装を支援するスキル。プロジェクト要件に応じた最適なパターンの選択基準、比較表、実装ガイドを提供する。

---

## 1. 状態管理パターンの選定フローチャート

```
プロジェクト規模は？
├── 小規模（画面数 5 以下、1-2 名）
│   ├── 学習コスト最小化が優先 → Provider
│   └── 型安全性・テスタビリティ重視 → Riverpod
├── 中規模（画面数 10-30、3-5 名）
│   ├── 厳格な設計規約が必要 → BLoC
│   ├── 柔軟性・開発速度重視 → Riverpod
│   └── 既存 Redux 経験チーム → flutter_redux
└── 大規模（画面数 30+、5 名以上）
    ├── エンタープライズ・厳格な状態遷移 → BLoC
    └── 柔軟 + 型安全 → Riverpod
```

---

## 2. 比較表

| 観点 | BLoC | Riverpod | Provider | GetX | Redux |
|------|------|----------|----------|------|-------|
| 学習コスト | 高い | 中程度 | 低い | 低い | 高い |
| テスタビリティ | 優秀 | 優秀 | 普通 | 低い | 優秀 |
| スケーラビリティ | 優秀 | 優秀 | 限定的 | 限定的 | 優秀 |
| ボイラープレート | 多い | 少ない | 少ない | 最少 | 多い |
| 型安全性 | 高い | 高い | 中程度 | 低い | 高い |
| DevTools 対応 | 良好 | 良好 | 良好 | 限定的 | 限定的 |
| コミュニティ | 大規模 | 成長中 | 大規模 | 大規模 | 中規模 |
| Flutter 公式推奨 | 推奨 | 推奨 | 推奨 | 非公式 | 非推奨 |

### 推奨の組み合わせ

| プロジェクト特性 | 推奨パターン | 理由 |
|----------------|------------|------|
| MVP / プロトタイプ | Riverpod or Provider | 開発速度優先 |
| 中規模プロダクション | BLoC or Riverpod | テスタビリティとスケーラビリティ |
| 大規模チーム開発 | BLoC | 厳格な規約で一貫性を確保 |
| 既存 Redux 経験チーム | flutter_redux | 学習コスト最小化 |
| 個人開発 / 学習目的 | Riverpod | モダンで柔軟 |

---

## 3. BLoC パターン実装ガイド

### 3.1 パッケージ

```yaml
dependencies:
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0
```

### 3.2 Event 定義

```dart
// events/auth_event.dart
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}
```

### 3.3 State 定義

```dart
// states/auth_state.dart
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  final User user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
```

### 3.4 Bloc 定義

```dart
// blocs/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
```

### 3.5 UI での使用

```dart
// BlocProvider で DI
BlocProvider(
  create: (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
  child: const LoginScreen(),
);

// BlocBuilder で状態に応じた UI
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthInitial() => const SplashScreen(),
      AuthLoading() => const CircularProgressIndicator(),
      AuthAuthenticated(:final user) => HomeScreen(user: user),
      AuthUnauthenticated() => const LoginScreen(),
      AuthError(:final message) => ErrorWidget(message: message),
    };
  },
);
```

---

## 4. Riverpod パターン実装ガイド

### 4.1 パッケージ

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
```

### 4.2 Provider 定義

```dart
// providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // 初期状態: 現在のユーザーを取得
    final repository = ref.watch(authRepositoryProvider);
    return repository.currentUser;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.login(email: email, password: password);
    });
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(null);
  }
}

// Repository Provider
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
}
```

### 4.3 UI での使用

```dart
// ProviderScope でラップ
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ConsumerWidget で状態を監視
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomeScreen(user: user);
        }
        return const LoginForm();
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(message: error.toString()),
    );
  }
}
```

---

## 5. テスト戦略

### BLoC テスト

```dart
// bloc_test パッケージを使用
blocTest<AuthBloc, AuthState>(
  'login success emits [AuthLoading, AuthAuthenticated]',
  build: () {
    when(() => mockAuthRepo.login(email: any, password: any))
        .thenAnswer((_) async => testUser);
    return AuthBloc(authRepository: mockAuthRepo);
  },
  act: (bloc) => bloc.add(
    const AuthLoginRequested(email: 'test@example.com', password: 'pass'),
  ),
  expect: () => [
    const AuthLoading(),
    AuthAuthenticated(user: testUser),
  ],
);
```

### Riverpod テスト

```dart
// ProviderContainer でテスト
test('login updates state to authenticated', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepo),
    ],
  );
  addTearDown(container.dispose);

  when(() => mockAuthRepo.login(email: any, password: any))
      .thenAnswer((_) async => testUser);

  final notifier = container.read(authNotifierProvider.notifier);
  await notifier.login(email: 'test@example.com', password: 'pass');

  final state = container.read(authNotifierProvider);
  expect(state.value, equals(testUser));
});
```
