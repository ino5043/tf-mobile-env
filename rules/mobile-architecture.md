# Mobile Architecture Rules

モバイルアプリケーションのアーキテクチャ設計に関する必須ルール。Flutter / iOS / Android プロジェクトに適用する。

---

## 1. Clean Architecture の3レイヤー

モバイルアプリは以下の3レイヤーで構成する。依存は **内側にのみ** 向く。

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│   UI, Widget, ViewController, Composable        │
│   BLoC / ViewModel / Provider                   │
└────────────────────────┬────────────────────────┘
                         │ 依存
┌────────────────────────▼────────────────────────┐
│                Domain Layer                      │
│   UseCase, Entity, Repository Interface         │
│   ビジネスロジックのみ、フレームワーク非依存     │
└────────────────────────┬────────────────────────┘
                         │ 依存
┌────────────────────────▼────────────────────────┐
│                 Data Layer                       │
│   Repository Impl, DataSource, DTO, Mapper      │
│   API Client, Local DB, Cache                   │
└─────────────────────────────────────────────────┘
```

### レイヤー別責務

| レイヤー | 責務 | 含まれるもの | 依存先 |
|---------|------|-------------|--------|
| **Presentation** | UI 表示と入力処理 | Widget, Screen, BLoC/ViewModel | Domain のみ |
| **Domain** | ビジネスロジック | UseCase, Entity, Repository Interface | なし（最内層） |
| **Data** | データ取得・永続化 | Repository Impl, API Client, DAO | Domain のみ |

### 依存ルール（CRITICAL）

```
Presentation → Domain ✅
Data → Domain ✅
Domain → Presentation ❌ 絶対禁止
Domain → Data ❌ 絶対禁止
Presentation → Data ❌ 禁止（Domain 経由で利用）
```

---

## 2. UseCase パターン

1 UseCase = 1 ビジネスロジック。UseCase は Domain Layer に配置する。

### Dart (Flutter)

```dart
// ❌ BAD: UseCase に複数の責務
class OrderUseCase {
  Future<Order> getOrder(String id) async { /* ... */ }
  Future<void> createOrder(Order order) async { /* ... */ }
  Future<void> cancelOrder(String id) async { /* ... */ }
}

// ✅ GOOD: 1 UseCase = 1 責務
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

class GetOrderUseCase implements UseCase<Order, String> {
  final OrderRepository _repository;

  GetOrderUseCase(this._repository);

  @override
  Future<Order> call(String orderId) async {
    final order = await _repository.findById(orderId);
    if (order == null) {
      throw OrderNotFoundException(orderId);
    }
    return order;
  }
}

class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {
  final OrderRepository _repository;
  final PaymentService _paymentService;

  CreateOrderUseCase(this._repository, this._paymentService);

  @override
  Future<Order> call(CreateOrderParams params) async {
    final order = Order.create(
      items: params.items,
      customerId: params.customerId,
    );
    await _paymentService.authorize(order.total);
    await _repository.save(order);
    return order;
  }
}
```

### Swift (iOS)

```swift
protocol UseCase {
    associatedtype Params
    associatedtype Result
    func execute(_ params: Params) async throws -> Result
}

struct GetOrderUseCase: UseCase {
    let repository: OrderRepository

    func execute(_ orderId: String) async throws -> Order {
        guard let order = try await repository.findById(orderId) else {
            throw OrderError.notFound(orderId)
        }
        return order
    }
}
```

### Kotlin (Android)

```kotlin
abstract class UseCase<in P, out R> {
    abstract suspend operator fun invoke(params: P): R
}

class GetOrderUseCase @Inject constructor(
    private val repository: OrderRepository
) : UseCase<String, Order>() {
    override suspend fun invoke(params: String): Order {
        return repository.findById(params)
            ?: throw OrderNotFoundException(params)
    }
}
```

---

## 3. Repository パターン

Remote + Local のデータソースを抽象化する。Domain Layer にインターフェース、Data Layer に実装を配置する。

### Dart (Flutter)

```dart
// Domain Layer: インターフェース
abstract class OrderRepository {
  Future<Order?> findById(String id);
  Future<List<Order>> findByCustomerId(String customerId);
  Future<void> save(Order order);
  Future<void> delete(String id);
}

// Data Layer: 実装
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final OrderLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  OrderRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Order?> findById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final dto = await _remoteDataSource.getOrder(id);
        final order = dto.toDomain();
        await _localDataSource.cacheOrder(dto);
        return order;
      } on ServerException {
        return _getFromCache(id);
      }
    }
    return _getFromCache(id);
  }

  Future<Order?> _getFromCache(String id) async {
    final cached = await _localDataSource.getCachedOrder(id);
    return cached?.toDomain();
  }

  @override
  Future<void> save(Order order) async {
    final dto = OrderDto.fromDomain(order);
    await _remoteDataSource.saveOrder(dto);
    await _localDataSource.cacheOrder(dto);
  }

  // ... 他のメソッド
}
```

---

## 4. Flutter: BLoC パターン

Event → BLoC → State の単方向データフロー。

```dart
// Events
sealed class OrderEvent {}
class LoadOrder extends OrderEvent {
  final String orderId;
  LoadOrder(this.orderId);
}
class SubmitOrder extends OrderEvent {
  final CreateOrderParams params;
  SubmitOrder(this.params);
}

// States
sealed class OrderState {}
class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrderLoaded extends OrderState {
  final Order order;
  OrderLoaded(this.order);
}
class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrderUseCase _getOrder;
  final CreateOrderUseCase _createOrder;

  OrderBloc(this._getOrder, this._createOrder) : super(OrderInitial()) {
    on<LoadOrder>(_onLoadOrder);
    on<SubmitOrder>(_onSubmitOrder);
  }

  Future<void> _onLoadOrder(LoadOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _getOrder(event.orderId);
      emit(OrderLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onSubmitOrder(SubmitOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _createOrder(event.params);
      emit(OrderLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
```

## 5. Flutter: Riverpod パターン

Provider + AsyncNotifier による状態管理。

```dart
// Provider 定義
@riverpod
class OrderNotifier extends _$OrderNotifier {
  @override
  FutureOr<Order?> build(String orderId) async {
    final repository = ref.watch(orderRepositoryProvider);
    return repository.findById(orderId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(orderRepositoryProvider);
      return repository.findById(arg);
    });
  }
}

// Repository Provider
@riverpod
OrderRepository orderRepository(OrderRepositoryRef ref) {
  return OrderRepositoryImpl(
    ref.watch(orderRemoteDataSourceProvider),
    ref.watch(orderLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
}

// Widget での使用
class OrderScreen extends ConsumerWidget {
  final String orderId;
  const OrderScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderNotifierProvider(orderId));

    return orderAsync.when(
      data: (order) => OrderDetailView(order: order!),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(message: error.toString()),
    );
  }
}
```

---

## 6. iOS: MVVM + Combine

```swift
// ViewModel
@MainActor
class OrderViewModel: ObservableObject {
    @Published private(set) var order: Order?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let getOrderUseCase: GetOrderUseCase
    private var cancellables = Set<AnyCancellable>()

    init(getOrderUseCase: GetOrderUseCase) {
        self.getOrderUseCase = getOrderUseCase
    }

    func loadOrder(id: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let order = try await getOrderUseCase.execute(id)
                self.order = order
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// View (SwiftUI)
struct OrderView: View {
    @StateObject private var viewModel: OrderViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let order = viewModel.order {
                OrderDetailView(order: order)
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            }
        }
        .onAppear { viewModel.loadOrder(id: orderId) }
    }
}
```

---

## 7. Android: MVVM + ViewModel + Hilt

```kotlin
// ViewModel
@HiltViewModel
class OrderViewModel @Inject constructor(
    private val getOrderUseCase: GetOrderUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<OrderUiState>(OrderUiState.Initial)
    val uiState: StateFlow<OrderUiState> = _uiState.asStateFlow()

    fun loadOrder(orderId: String) {
        viewModelScope.launch {
            _uiState.value = OrderUiState.Loading
            try {
                val order = getOrderUseCase(orderId)
                _uiState.value = OrderUiState.Success(order)
            } catch (e: Exception) {
                _uiState.value = OrderUiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

sealed class OrderUiState {
    data object Initial : OrderUiState()
    data object Loading : OrderUiState()
    data class Success(val order: Order) : OrderUiState()
    data class Error(val message: String) : OrderUiState()
}

// Composable
@Composable
fun OrderScreen(viewModel: OrderViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is OrderUiState.Loading -> CircularProgressIndicator()
        is OrderUiState.Success -> OrderDetail(order = state.order)
        is OrderUiState.Error -> ErrorView(message = state.message)
        is OrderUiState.Initial -> Unit
    }
}
```

---

## 8. ディレクトリ構成テンプレート

### Flutter

```
lib/
├── core/                     # 共通ユーティリティ
│   ├── error/                # エラー定義
│   ├── network/              # ネットワーク関連
│   └── usecases/             # UseCase 基底クラス
├── features/                 # 機能別モジュール
│   └── order/
│       ├── domain/
│       │   ├── entities/     # Order, OrderItem
│       │   ├── repositories/ # OrderRepository (abstract)
│       │   └── usecases/     # GetOrderUseCase, CreateOrderUseCase
│       ├── data/
│       │   ├── datasources/  # Remote, Local
│       │   ├── models/       # DTO, Mapper
│       │   └── repositories/ # OrderRepositoryImpl
│       └── presentation/
│           ├── bloc/         # OrderBloc, OrderEvent, OrderState
│           ├── pages/        # OrderPage
│           └── widgets/      # OrderCard, OrderList
├── di/                       # 依存性注入設定
└── main.dart
```

### iOS (Swift)

```
Sources/
├── Core/
│   ├── Network/
│   └── Storage/
├── Features/
│   └── Order/
│       ├── Domain/
│       │   ├── Entities/
│       │   ├── Repositories/   # Protocol
│       │   └── UseCases/
│       ├── Data/
│       │   ├── DataSources/
│       │   ├── DTOs/
│       │   └── Repositories/   # Impl
│       └── Presentation/
│           ├── ViewModels/
│           └── Views/
└── DI/
```

### Android (Kotlin)

```
app/src/main/java/com/example/
├── core/
│   ├── di/                    # Hilt Module
│   └── network/
├── features/
│   └── order/
│       ├── domain/
│       │   ├── model/
│       │   ├── repository/    # Interface
│       │   └── usecase/
│       ├── data/
│       │   ├── remote/
│       │   ├── local/
│       │   ├── dto/
│       │   └── repository/    # Impl
│       └── presentation/
│           ├── viewmodel/
│           └── ui/
└── App.kt
```

---

## チェックリスト

### アーキテクチャ設計時
- [ ] 3レイヤー（Presentation, Domain, Data）に分離しているか
- [ ] 依存の方向は内側にのみ向いているか（Domain が最内層）
- [ ] Domain Layer にフレームワーク固有のコードが含まれていないか
- [ ] UseCase は1つの責務のみを持っているか
- [ ] Repository インターフェースは Domain Layer に配置されているか
- [ ] Repository 実装は Data Layer に配置されているか

### コードレビュー時
- [ ] Presentation Layer から直接 DataSource にアクセスしていないか
- [ ] Domain Layer に import 'package:flutter/...' 等がないか
- [ ] UseCase が複数のビジネスロジックを混在させていないか
- [ ] DTO と Entity が適切に分離されているか（Mapper が存在するか）
- [ ] ディレクトリ構成がテンプレートに従っているか
- [ ] 状態管理パターン（BLoC / Riverpod / MVVM）が統一されているか
