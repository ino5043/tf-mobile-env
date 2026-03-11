# Battery & Performance Rules

モバイルアプリのバッテリー消費とパフォーマンス最適化に関する必須ルール。ユーザー体験を損なわずにリソースを効率的に使用する。

---

## 1. パフォーマンスバジェット

### 起動時間

| 種別 | 目標 | 許容上限 | 計測ポイント |
|------|------|---------|-------------|
| **Cold Start** | < 1.5s | < 2s | プロセス起動 → 最初の画面表示 |
| **Warm Start** | < 0.5s | < 1s | バックグラウンド復帰 → 画面表示 |
| **Hot Start** | < 0.3s | < 0.5s | アクティビティ再生成 → 画面表示 |

### メモリ使用量

| プラットフォーム | 通常時目安 | ピーク許容 | 超過時のリスク |
|----------------|-----------|-----------|---------------|
| **iOS** | < 150MB | < 200MB | OS によるプロセス Kill |
| **Android** | < 100MB | < 150MB | OOM Killer によるプロセス Kill |
| **Flutter** | < 120MB | < 180MB | Skia + Dart VM のオーバーヘッド含む |

### フレームレート

| メトリクス | 目標 | 許容 |
|-----------|------|------|
| UI フレームレート | 60fps (16.6ms/frame) | 最低 30fps |
| Jank（フレーム落ち）率 | < 1% | < 5% |
| 画面遷移アニメーション | 60fps 維持 | Jank なし |

---

## 2. バッテリー消費の主要因と対策

| 要因 | 消費度 | 対策 |
|------|--------|------|
| **GPS (高精度)** | 非常に高い | 必要時のみ有効化、精度を下げる |
| **ネットワーク (モバイル通信)** | 高い | バッチリクエスト、キャッシュ活用 |
| **CPU 集中処理** | 高い | Isolate / バックグラウンドスレッド |
| **画面描画 (高リフレッシュレート)** | 中程度 | 不要なリビルド削減 |
| **Bluetooth / NFC** | 中程度 | 使用完了後に切断 |
| **バイブレーション** | 低い | 適度に使用 |

### 位置情報の最適化

```dart
// ❌ BAD: 常時高精度 GPS
Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best, // GPS + Wi-Fi + セルラー全部
    distanceFilter: 0, // 移動なしでも通知
  ),
);

// ✅ GOOD: 用途に応じた精度設定
class LocationService {
  /// 地図表示用: 中精度、100m 移動ごと
  Stream<Position> getMapLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100,
      ),
    );
  }

  /// チェックイン用: 高精度だが1回のみ
  Future<Position> getCheckInLocation() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }
}
```

### ネットワークリクエストの最適化

```dart
// ❌ BAD: 個別にリクエスト
await api.getUser(userId);
await api.getOrders(userId);
await api.getNotifications(userId);
// → 3回のネットワークラウンドトリップ

// ✅ GOOD: バッチリクエスト or 並列実行
final results = await Future.wait([
  api.getUser(userId),
  api.getOrders(userId),
  api.getNotifications(userId),
]);
// → 並列実行で待ち時間を削減

// ✅ BETTER: 専用のバッチ API エンドポイント
final dashboard = await api.getDashboard(userId);
// → 1回のリクエストで必要なデータをすべて取得
```

---

## 3. Flutter パフォーマンス最適化

### Widget リビルド最小化

```dart
// ❌ BAD: const を使わない → 毎回新しいインスタンス生成
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16), // 毎回生成
      child: Text(
        'Hello',
        style: TextStyle(fontSize: 16), // 毎回生成
      ),
    );
  }
}

// ✅ GOOD: const でインスタンスを再利用
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Hello',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

// ❌ BAD: 親の再ビルドで不要な子もリビルド
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterNotifier>().count;
    return Column(
      children: [
        Text('Count: $counter'),
        HeavyChildWidget(), // counter 変更のたびにリビルド
      ],
    );
  }
}

// ✅ GOOD: リビルド範囲を限定
class ParentWidget extends StatelessWidget {
  const ParentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // counter を監視する部分だけを分離
        const CounterDisplay(),
        const HeavyChildWidget(), // const でリビルド回避
      ],
    );
  }
}

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterNotifier>().count;
    return Text('Count: $counter');
  }
}
```

### 大量リストの最適化

```dart
// ❌ BAD: 全アイテムを一度に生成
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
  // 1000件 → 1000個の Widget を一度に生成
)

// ✅ GOOD: 画面に見える分だけ遅延生成
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
  // 画面に見える分 + キャッシュ分のみ生成
)

// ✅ BETTER: itemExtent で高速化（固定高さの場合）
ListView.builder(
  itemCount: items.length,
  itemExtent: 72, // 各アイテムの高さが固定なら指定
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)

// ✅ GOOD: Sliver でヘッダー + リストを効率的に結合
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Orders')),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemWidget(item: items[index]),
    ),
  ],
)
```

### 画像最適化

```dart
// ❌ BAD: 毎回ネットワークからダウンロード
Image.network(imageUrl)

// ✅ GOOD: キャッシュ付き画像読み込み
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 300, // メモリキャッシュのリサイズ
  maxWidthDiskCache: 600, // ディスクキャッシュのリサイズ
)

// ✅ GOOD: 適切なサイズで読み込み
Image.network(
  imageUrl,
  cacheWidth: 300, // デコード時のリサイズ（メモリ節約）
  cacheHeight: 300,
)
```

### Isolate によるバックグラウンド処理

```dart
// ❌ BAD: メインスレッドで重い処理
void processData() {
  final result = heavyComputation(largeDataSet); // UI がフリーズ
  setState(() => _data = result);
}

// ✅ GOOD: Isolate で別スレッド実行
Future<void> processData() async {
  // compute() は簡易的な Isolate 実行
  final result = await compute(heavyComputation, largeDataSet);
  setState(() => _data = result);
}

// ✅ GOOD: 長時間の Isolate（複数回通信が必要な場合）
Future<void> processLargeData() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_isolateEntry, receivePort.sendPort);

  await for (final message in receivePort) {
    if (message is ProgressUpdate) {
      setState(() => _progress = message.progress);
    } else if (message is ComputeResult) {
      setState(() => _data = message.data);
      break;
    }
  }
}

static void _isolateEntry(SendPort sendPort) {
  // 重い処理を実行
  for (var i = 0; i < chunks.length; i++) {
    processChunk(chunks[i]);
    sendPort.send(ProgressUpdate(progress: (i + 1) / chunks.length));
  }
  sendPort.send(ComputeResult(data: finalResult));
}
```

---

## 4. メモリリーク検出パターン

### 一般的なメモリリーク原因

| パターン | 原因 | 対策 |
|---------|------|------|
| Stream の未解除 | dispose() で cancel していない | dispose() で必ず cancel |
| Timer の未停止 | 画面破棄後も Timer が動作 | dispose() で cancel |
| Listener の未解除 | ChangeNotifier の removeListener 忘れ | dispose() で removeListener |
| GlobalKey の誤用 | Widget ツリー外からの参照保持 | 必要最小限の使用 |
| クロージャの参照保持 | コールバック内で Widget を参照 | WeakReference / mounted チェック |

### Flutter: メモリリーク防止

```dart
class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  StreamSubscription<Order>? _orderSubscription;
  Timer? _refreshTimer;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Stream の購読
    _orderSubscription = orderStream.listen((order) {
      if (mounted) { // mounted チェック
        setState(() => _order = order);
      }
    });

    // 定期リフレッシュ
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _refreshData(),
    );
  }

  @override
  void dispose() {
    // 全リソースを解放（CRITICAL）
    _orderSubscription?.cancel();
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 5. バックグラウンド処理の制限

### iOS: BackgroundTasks

```swift
// iOS: BGTaskScheduler を使用
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // バックグラウンドタスクの登録
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.example.app.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        // 次回のスケジュール
        scheduleAppRefresh()

        let operation = RefreshOperation()
        task.expirationHandler = { operation.cancel() }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        OperationQueue().addOperation(operation)
    }
}
```

### Android: WorkManager

```kotlin
// Android: WorkManager で定期タスク
class SyncWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        return try {
            val syncService = SyncService.getInstance(applicationContext)
            syncService.syncPendingChanges()
            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }
}

// スケジュール設定
fun schedulePeriodSync(context: Context) {
    val constraints = Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .setRequiresBatteryNotLow(true) // バッテリー残量が低い時はスキップ
        .build()

    val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
        15, TimeUnit.MINUTES // 最低間隔は15分
    )
        .setConstraints(constraints)
        .setBackoffCriteria(
            BackoffPolicy.EXPONENTIAL,
            WorkRequest.MIN_BACKOFF_MILLIS,
            TimeUnit.MILLISECONDS
        )
        .build()

    WorkManager.getInstance(context)
        .enqueueUniquePeriodicWork(
            "periodic_sync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )
}
```

### Flutter: workmanager パッケージ

```dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'syncData':
        await SyncService().syncPendingChanges();
        return true;
      default:
        return false;
    }
  });
}

void initializeBackgroundTasks() {
  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    'periodicSync',
    'syncData',
    frequency: const Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}
```

---

## 6. プロファイリングツール

### Flutter DevTools

```bash
# パフォーマンスプロファイリング
flutter run --profile

# DevTools の起動
flutter pub global run devtools
```

| ツール | 確認内容 |
|--------|---------|
| **Performance Overlay** | UI / Raster スレッドのフレーム時間 |
| **Widget Inspector** | リビルド回数、Widget ツリー |
| **Memory** | ヒープサイズ、GC 頻度、リーク検出 |
| **CPU Profiler** | 関数ごとの実行時間 |
| **Network** | API リクエストの回数・サイズ・時間 |

### iOS: Instruments

| テンプレート | 確認内容 |
|-------------|---------|
| **Time Profiler** | CPU 使用率、ホットスポット |
| **Allocations** | メモリ割り当て、リーク |
| **Energy Log** | バッテリー消費の要因 |
| **Network** | 通信量、タイミング |

### Android: Android Profiler

| セクション | 確認内容 |
|-----------|---------|
| **CPU** | スレッド使用率、メソッドトレース |
| **Memory** | ヒープダンプ、リーク検出 |
| **Energy** | バッテリー消費イベント |
| **Network** | リクエスト / レスポンスの詳細 |

---

## チェックリスト

### パフォーマンス設計時
- [ ] 起動時間バジェット（Cold < 2s, Warm < 1s）を意識しているか
- [ ] メモリ使用量の上限（iOS < 200MB, Android < 150MB）を把握しているか
- [ ] 大量リストに ListView.builder を使用しているか
- [ ] 画像にキャッシュ（CachedNetworkImage）と適切なリサイズを適用しているか
- [ ] 重い処理を Isolate / バックグラウンドスレッドに移しているか

### バッテリー最適化時
- [ ] 位置情報の精度と更新頻度を用途に応じて設定しているか
- [ ] ネットワークリクエストをバッチ化 or 並列化しているか
- [ ] バックグラウンド処理に WorkManager / BGTaskScheduler を使用しているか
- [ ] バッテリー残量が低い時の動作を考慮しているか

### コードレビュー時
- [ ] const を適切に使用して Widget リビルドを最小化しているか
- [ ] dispose() ですべてのリソース（Stream, Timer, Controller）を解放しているか
- [ ] mounted チェックを非同期コールバック内で行っているか
- [ ] 不要な setState() で Widget ツリー全体がリビルドされていないか
- [ ] プロファイリングで Jank（フレーム落ち）が発生していないか
