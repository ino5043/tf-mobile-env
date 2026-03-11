# Mobile Testing Rules

モバイルアプリのテスト戦略に関する必須ルール。品質を保証しつつ効率的なテストピラミッドを構築する。

---

## 1. テストピラミッド

```
                    ┌──────┐
                    │ E2E  │  5%   実機テスト、クリティカルフロー
                   ─┤      ├─
                  / │      │ \
                 ┌──┴──────┴──┐
                 │ Integration │  10%  複数モジュール結合、API 連携
                ─┤            ├─
               / │            │ \
              ┌──┴────────────┴──┐
              │  Widget / UI     │  25%  UI コンポーネント単体
             ─┤                  ├─
            / │                  │ \
           ┌──┴──────────────────┴──┐
           │       Unit Test        │  60%  ロジック、UseCase、Repository
           └────────────────────────┘
```

| テスト種別 | 割合 | 実行速度 | テスト対象 |
|-----------|------|---------|-----------|
| **Unit** | 60% | 高速 (ms) | UseCase, Entity, Repository, Utility |
| **Widget / UI** | 25% | 中速 (100ms) | Widget 単体、画面コンポーネント |
| **Integration** | 10% | 低速 (s) | 画面遷移、API 結合、DB 操作 |
| **E2E** | 5% | 最低速 (10s+) | ユーザーシナリオ全体 |

---

## 2. Flutter テスト

### Unit Test

```dart
// UseCase のテスト
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([OrderRepository])
void main() {
  late GetOrderUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = GetOrderUseCase(mockRepository);
  });

  group('GetOrderUseCase', () {
    final testOrder = Order(
      id: 'order-1',
      customerId: 'customer-1',
      status: OrderStatus.pending,
      items: [OrderItem(productId: 'p-1', quantity: 2, price: 1000)],
    );

    test('正常系: 注文が存在する場合、注文を返す', () async {
      // Arrange
      when(mockRepository.findById('order-1'))
          .thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase('order-1');

      // Assert
      expect(result, equals(testOrder));
      verify(mockRepository.findById('order-1')).called(1);
    });

    test('異常系: 注文が存在しない場合、例外をスローする', () async {
      // Arrange
      when(mockRepository.findById('order-999'))
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase('order-999'),
        throwsA(isA<OrderNotFoundException>()),
      );
    });
  });
}
```

### BLoC Test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

@GenerateMocks([GetOrderUseCase, CreateOrderUseCase])
void main() {
  late OrderBloc bloc;
  late MockGetOrderUseCase mockGetOrder;
  late MockCreateOrderUseCase mockCreateOrder;

  setUp(() {
    mockGetOrder = MockGetOrderUseCase();
    mockCreateOrder = MockCreateOrderUseCase();
    bloc = OrderBloc(mockGetOrder, mockCreateOrder);
  });

  tearDown(() => bloc.close());

  group('OrderBloc', () {
    final testOrder = Order(id: 'order-1', status: OrderStatus.pending);

    blocTest<OrderBloc, OrderState>(
      '正常系: LoadOrder イベントで OrderLoaded を emit する',
      build: () {
        when(mockGetOrder('order-1')).thenAnswer((_) async => testOrder);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOrder('order-1')),
      expect: () => [
        OrderLoading(),
        OrderLoaded(testOrder),
      ],
      verify: (_) {
        verify(mockGetOrder('order-1')).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      '異常系: LoadOrder でエラー時 OrderError を emit する',
      build: () {
        when(mockGetOrder('order-1'))
            .thenThrow(OrderNotFoundException('order-1'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadOrder('order-1')),
      expect: () => [
        OrderLoading(),
        isA<OrderError>(),
      ],
    );
  });
}
```

### Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderCard Widget', () {
    final testOrder = Order(
      id: 'order-1',
      title: 'テスト注文',
      status: OrderStatus.pending,
      totalAmount: 3000,
    );

    testWidgets('注文情報が正しく表示される', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCard(order: testOrder),
          ),
        ),
      );

      // Assert
      expect(find.text('テスト注文'), findsOneWidget);
      expect(find.text('保留中'), findsOneWidget);
      expect(find.text('¥3,000'), findsOneWidget);
    });

    testWidgets('タップで onTap コールバックが呼ばれる', (tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCard(
              order: testOrder,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(OrderCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('ローディング状態でスケルトンが表示される', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderCard.loading(),
          ),
        ),
      );

      expect(find.byType(ShimmerPlaceholder), findsWidgets);
    });
  });
}
```

### Golden Test（スナップショットテスト）

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderCard Golden Tests', () {
    testWidgets('通常状態のスナップショット', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: OrderCard(order: testOrder),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(OrderCard),
        matchesGoldenFile('goldens/order_card_normal.png'),
      );
    });

    testWidgets('エラー状態のスナップショット', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: OrderCard(
                  order: testOrder.copyWith(status: OrderStatus.error),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(OrderCard),
        matchesGoldenFile('goldens/order_card_error.png'),
      );
    });
  });
}
```

### Integration Test

```dart
// integration_test/order_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('注文フロー統合テスト', () {
    testWidgets('注文一覧から詳細画面に遷移できる', (tester) async {
      // Arrange
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Act: 注文一覧から最初の注文をタップ
      await tester.tap(find.byType(OrderCard).first);
      await tester.pumpAndSettle();

      // Assert: 詳細画面が表示される
      expect(find.byType(OrderDetailScreen), findsOneWidget);
      expect(find.text('注文詳細'), findsOneWidget);
    });

    testWidgets('注文作成フロー', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. 新規注文ボタンをタップ
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 2. 商品を追加
      await tester.tap(find.text('商品A'));
      await tester.pumpAndSettle();

      // 3. 数量を入力
      await tester.enterText(find.byKey(const Key('quantity_input')), '3');
      await tester.pumpAndSettle();

      // 4. 確認ボタンをタップ
      await tester.tap(find.text('注文を確定'));
      await tester.pumpAndSettle();

      // 5. 完了画面が表示される
      expect(find.text('注文が完了しました'), findsOneWidget);
    });
  });
}
```

---

## 3. iOS テスト

### XCTest (Unit Test)

```swift
import XCTest
@testable import MyApp

class GetOrderUseCaseTests: XCTestCase {
    var sut: GetOrderUseCase!
    var mockRepository: MockOrderRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockOrderRepository()
        sut = GetOrderUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testExecute_whenOrderExists_returnsOrder() async throws {
        // Arrange
        let expectedOrder = Order(id: "order-1", status: .pending)
        mockRepository.stubbedOrder = expectedOrder

        // Act
        let result = try await sut.execute("order-1")

        // Assert
        XCTAssertEqual(result.id, "order-1")
        XCTAssertEqual(result.status, .pending)
        XCTAssertEqual(mockRepository.findByIdCallCount, 1)
    }

    func testExecute_whenOrderNotFound_throwsError() async {
        // Arrange
        mockRepository.stubbedOrder = nil

        // Act & Assert
        do {
            _ = try await sut.execute("order-999")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is OrderError)
        }
    }
}
```

### XCUITest (UI Test)

```swift
import XCTest

class OrderFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testOrderListToDetail() {
        // 注文一覧が表示される
        let orderList = app.tables["order_list"]
        XCTAssertTrue(orderList.waitForExistence(timeout: 5))

        // 最初の注文をタップ
        let firstOrder = orderList.cells.firstMatch
        firstOrder.tap()

        // 詳細画面が表示される
        let detailTitle = app.navigationBars["注文詳細"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 3))
    }
}
```

---

## 4. Android テスト

### JUnit + Kotlin (Unit Test)

```kotlin
import org.junit.Test
import org.junit.Before
import org.mockito.kotlin.*
import kotlinx.coroutines.test.runTest

class GetOrderUseCaseTest {
    private lateinit var useCase: GetOrderUseCase
    private lateinit var mockRepository: OrderRepository

    @Before
    fun setUp() {
        mockRepository = mock()
        useCase = GetOrderUseCase(mockRepository)
    }

    @Test
    fun `正常系 - 注文が存在する場合、注文を返す`() = runTest {
        // Arrange
        val expected = Order(id = "order-1", status = OrderStatus.PENDING)
        whenever(mockRepository.findById("order-1")).thenReturn(expected)

        // Act
        val result = useCase("order-1")

        // Assert
        assertEquals(expected, result)
        verify(mockRepository).findById("order-1")
    }

    @Test(expected = OrderNotFoundException::class)
    fun `異常系 - 注文が存在しない場合、例外をスローする`() = runTest {
        // Arrange
        whenever(mockRepository.findById("order-999")).thenReturn(null)

        // Act
        useCase("order-999")
    }
}
```

### Compose Testing

```kotlin
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import org.junit.Rule
import org.junit.Test

class OrderScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun orderCard_displaysOrderInfo() {
        // Arrange
        val order = Order(id = "order-1", title = "テスト注文", status = OrderStatus.PENDING)

        composeTestRule.setContent {
            OrderCard(order = order)
        }

        // Assert
        composeTestRule.onNodeWithText("テスト注文").assertIsDisplayed()
        composeTestRule.onNodeWithText("保留中").assertIsDisplayed()
    }

    @Test
    fun orderCard_onTap_callsCallback() {
        var clicked = false
        val order = Order(id = "order-1", title = "テスト注文")

        composeTestRule.setContent {
            OrderCard(order = order, onClick = { clicked = true })
        }

        // Act
        composeTestRule.onNodeWithText("テスト注文").performClick()

        // Assert
        assertTrue(clicked)
    }
}
```

---

## 5. テストデータ管理

### Fixture / Factory パターン

```dart
// test/fixtures/order_fixtures.dart
class OrderFixtures {
  static Order pending({
    String id = 'order-1',
    String customerId = 'customer-1',
  }) {
    return Order(
      id: id,
      customerId: customerId,
      status: OrderStatus.pending,
      items: [
        OrderItem(productId: 'product-1', quantity: 1, price: 1000),
      ],
      createdAt: DateTime(2026, 1, 1),
    );
  }

  static Order shipped({String id = 'order-2'}) {
    return Order(
      id: id,
      customerId: 'customer-1',
      status: OrderStatus.shipped,
      items: [
        OrderItem(productId: 'product-1', quantity: 2, price: 1500),
      ],
      createdAt: DateTime(2026, 1, 2),
    );
  }

  static List<Order> list({int count = 10}) {
    return List.generate(count, (i) => pending(id: 'order-$i'));
  }
}

// テストでの使用
test('pending order can be submitted', () {
  final order = OrderFixtures.pending();
  // ...
});
```

### Mock / Fake の使い分け

| 種別 | 用途 | 実装コスト |
|------|------|-----------|
| **Mock** | メソッド呼び出しの検証 | 低（mockito で自動生成） |
| **Fake** | 簡易的な代替実装 | 中（手動実装） |
| **Stub** | 固定値を返す | 低 |

```dart
// Fake Repository（インメモリ実装）
class FakeOrderRepository implements OrderRepository {
  final Map<String, Order> _store = {};

  @override
  Future<Order?> findById(String id) async => _store[id];

  @override
  Future<void> save(Order order) async => _store[order.id] = order;

  @override
  Future<void> delete(String id) async => _store.remove(id);

  @override
  Future<List<Order>> findByCustomerId(String customerId) async {
    return _store.values
        .where((o) => o.customerId == customerId)
        .toList();
  }

  void seed(List<Order> orders) {
    for (final order in orders) {
      _store[order.id] = order;
    }
  }
}
```

---

## 6. Device Farm テスト

### Firebase Test Lab

```yaml
# .github/workflows/device-test.yml
- name: Run Firebase Test Lab
  run: |
    gcloud firebase test android run \
      --type instrumentation \
      --app build/app/outputs/flutter-apk/app-debug.apk \
      --test build/app/outputs/flutter-apk/app-debug-androidTest.apk \
      --device model=Pixel6,version=33,locale=ja,orientation=portrait \
      --device model=Pixel4,version=30,locale=ja,orientation=portrait \
      --timeout 10m \
      --results-dir=test-results
```

---

## 7. テストカバレッジ

```bash
# Flutter テストカバレッジの生成
flutter test --coverage

# HTML レポートの生成
genhtml coverage/lcov.info -o test-results/coverage-html

# カバレッジ閾値のチェック（CI 用）
lcov --summary coverage/lcov.info | grep -oP 'lines.*: \K[0-9.]+' | \
  awk '{if ($1 < 80) exit 1}'
```

### CI での設定

```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: flutter test --coverage

- name: Check coverage threshold
  run: |
    COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -oP '[0-9.]+%')
    echo "Coverage: $COVERAGE"

- name: Upload coverage report
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report-${{ github.sha }}
    path: test-results/coverage-html/
    retention-days: 400
  if: always()
```

---

## チェックリスト

### テスト設計時
- [ ] テストピラミッドの比率（Unit 60%, Widget 25%, Integration 10%, E2E 5%）を意識しているか
- [ ] クリティカルなビジネスロジックに Unit Test があるか
- [ ] 主要な UI コンポーネントに Widget Test があるか
- [ ] ユーザーの主要フロー（ログイン、注文等）に E2E テストがあるか
- [ ] テストデータが Fixture / Factory パターンで管理されているか

### テスト実装時
- [ ] AAA パターン（Arrange-Act-Assert）に従っているか
- [ ] Mock / Fake を適切に使い分けているか
- [ ] 非同期テストで適切に await / pumpAndSettle しているか
- [ ] Golden Test の基準画像が最新か
- [ ] テストが独立して実行可能か（他テストに依存していないか）

### CI / CD 時
- [ ] テストカバレッジが 80% 以上か
- [ ] テスト結果を JUnit XML で出力しているか
- [ ] カバレッジレポートを Artifact としてアップロードしているか
- [ ] 主要デバイスでの Device Farm テストを実行しているか
- [ ] テスト失敗時に Artifact（スクリーンショット、ログ）を保存しているか
