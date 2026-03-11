# Offline-First Rules

モバイルアプリのオフライン対応戦略に関する必須ルール。ネットワーク接続が不安定な環境でも安定動作するアプリを構築する。

---

## 1. オフラインファースト設計原則

ネットワーク接続を **前提としない** 設計。オフライン動作をデフォルトとし、ネットワーク接続時に同期する。

```
┌─────────────────────────────────────────────────────────┐
│                   Offline-First Architecture            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   ┌─────────┐      ┌──────────────┐      ┌──────────┐ │
│   │   UI    │ ──→  │  Local Store │ ←──  │  Remote  │ │
│   │         │ ←──  │  (常に参照)   │ ──→  │  Server  │ │
│   └─────────┘      └──────────────┘      └──────────┘ │
│                            │                     ↑      │
│                     ┌──────┴──────┐              │      │
│                     │  Sync Queue │ ─────────────┘      │
│                     │  (オフライン時蓄積)                 │
│                     └─────────────┘                      │
└─────────────────────────────────────────────────────────┘

原則:
1. UI は常に Local Store からデータを取得する
2. ネットワーク経由のデータは Local Store に保存してから UI に反映
3. 書き込み操作は Sync Queue に蓄積し、接続復帰時に同期
```

---

## 2. キャッシュ戦略

### 戦略比較表

| 戦略 | 動作 | 適用ケース | トレードオフ |
|------|------|-----------|-------------|
| **Cache First** | キャッシュを優先、なければネットワーク | マスターデータ、設定値 | データの鮮度が低い |
| **Network First** | ネットワークを優先、失敗時キャッシュ | ユーザープロフィール、注文状況 | オフライン時のレイテンシ |
| **Stale While Revalidate** | キャッシュを即返却 + バックグラウンド更新 | フィード、商品一覧 | 一瞬古いデータが見える |
| **Network Only** | 常にネットワーク | 決済、認証 | オフライン不可 |
| **Cache Only** | 常にキャッシュ | オフラインで作成したデータ | 更新されない |

### Dart: キャッシュ戦略実装

```dart
enum CacheStrategy {
  cacheFirst,
  networkFirst,
  staleWhileRevalidate,
  networkOnly,
}

class CachedRepository<T> {
  final RemoteDataSource<T> _remote;
  final LocalDataSource<T> _local;
  final NetworkInfo _networkInfo;
  final Duration _cacheDuration;

  CachedRepository(
    this._remote,
    this._local,
    this._networkInfo, {
    Duration cacheDuration = const Duration(hours: 1),
  }) : _cacheDuration = cacheDuration;

  /// Cache First: キャッシュ優先
  Future<T?> cacheFirst(String key) async {
    // 1. キャッシュを確認
    final cached = await _local.get(key);
    if (cached != null && !_isExpired(cached)) {
      return cached.data;
    }

    // 2. キャッシュなし or 期限切れ → ネットワーク
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remote.fetch(key);
        await _local.save(key, remote);
        return remote;
      } on Exception {
        // ネットワークエラー時は期限切れキャッシュを返す
        return cached?.data;
      }
    }

    // 3. オフライン → 期限切れでもキャッシュを返す
    return cached?.data;
  }

  /// Network First: ネットワーク優先
  Future<T?> networkFirst(String key) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remote.fetch(key);
        await _local.save(key, remote);
        return remote;
      } on Exception {
        return (await _local.get(key))?.data;
      }
    }
    return (await _local.get(key))?.data;
  }

  /// Stale While Revalidate: キャッシュ即返却 + バックグラウンド更新
  Stream<T?> staleWhileRevalidate(String key) async* {
    // 1. キャッシュを即返却
    final cached = await _local.get(key);
    if (cached != null) {
      yield cached.data;
    }

    // 2. バックグラウンドで更新
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remote.fetch(key);
        await _local.save(key, remote);
        // 3. 更新データを返却（キャッシュと異なる場合）
        yield remote;
      } on Exception {
        // ネットワークエラーは無視（キャッシュで継続）
      }
    }
  }

  bool _isExpired(CachedItem<T> item) {
    return DateTime.now().difference(item.cachedAt) > _cacheDuration;
  }
}

class CachedItem<T> {
  final T data;
  final DateTime cachedAt;

  CachedItem({required this.data, required this.cachedAt});
}
```

---

## 3. ローカルストレージ選択

### 比較表

| ストレージ | データ型 | 容量 | クエリ | 適用ケース |
|-----------|---------|------|--------|-----------|
| **SharedPreferences** | Key-Value (primitive) | 小 | なし | 設定値、フラグ、トークン |
| **Hive** | Key-Value (object) | 中 | Box 単位 | ユーザープロフィール、キャッシュ |
| **SQLite / drift** | リレーショナル | 大 | SQL | マスターデータ、トランザクション |
| **Isar** | NoSQL (object) | 大 | Index + Query | 大量データ、全文検索 |
| **Realm** | NoSQL (object) | 大 | Query + Sync | リアルタイム同期が必要 |

### 選定フローチャート

```
データの種類は？
├─ 設定値・フラグ → SharedPreferences
├─ 単純なオブジェクト（数百件以下）→ Hive
├─ リレーショナルデータ → SQLite / drift
├─ 大量オブジェクト + 検索 → Isar
└─ リアルタイム同期必須 → Realm
```

### Dart: drift (SQLite) の例

```dart
// テーブル定義
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerId => text()();
  TextColumn get status => textEnum<OrderStatus>()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
}

// DAO
@DaoMixin()
class OrderDao extends DatabaseAccessor<AppDatabase> {
  OrderDao(AppDatabase db) : super(db);

  Future<List<Order>> getUnsyncedOrders() {
    return (select(orders)
      ..where((o) => o.pendingSync.equals(true))
      ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
    ).get();
  }

  Future<void> markSynced(int orderId) {
    return (update(orders)..where((o) => o.id.equals(orderId))).write(
      OrdersCompanion(
        pendingSync: const Value(false),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }
}
```

---

## 4. 同期キュー設計

オフライン時の書き込み操作をキューに蓄積し、接続復帰時に順次実行する。

```dart
// 同期キューのエントリ
class SyncQueueEntry {
  final String id;
  final String entityType;  // 'order', 'comment', etc.
  final String entityId;
  final SyncOperation operation;  // create, update, delete
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;

  SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.maxRetries = 3,
  });

  bool get canRetry => retryCount < maxRetries;
}

enum SyncOperation { create, update, delete }

// 同期キューマネージャ
class SyncQueueManager {
  final SyncQueueRepository _queueRepository;
  final Map<String, SyncHandler> _handlers;
  final NetworkInfo _networkInfo;

  SyncQueueManager(this._queueRepository, this._handlers, this._networkInfo);

  /// キューにエントリを追加
  Future<void> enqueue(SyncQueueEntry entry) async {
    await _queueRepository.save(entry);

    // オンラインなら即座に同期を試行
    if (await _networkInfo.isConnected) {
      await processQueue();
    }
  }

  /// キューを順次処理
  Future<SyncResult> processQueue() async {
    final entries = await _queueRepository.getPending();
    int successCount = 0;
    int failCount = 0;

    for (final entry in entries) {
      try {
        final handler = _handlers[entry.entityType];
        if (handler == null) {
          throw SyncError('No handler for ${entry.entityType}');
        }

        await handler.sync(entry);
        await _queueRepository.markCompleted(entry.id);
        successCount++;
      } on ConflictException catch (e) {
        // コンフリクト解決
        await _resolveConflict(entry, e);
        failCount++;
      } on Exception catch (e) {
        if (entry.canRetry) {
          await _queueRepository.incrementRetry(entry.id);
        } else {
          await _queueRepository.markFailed(entry.id, e.toString());
        }
        failCount++;
      }
    }

    return SyncResult(success: successCount, failed: failCount);
  }

  Future<void> _resolveConflict(
    SyncQueueEntry entry,
    ConflictException conflict,
  ) async {
    // Last Write Wins がデフォルト
    // 必要に応じてエンティティごとにカスタマイズ
    final handler = _handlers[entry.entityType];
    await handler?.resolveConflict(entry, conflict);
  }
}
```

---

## 5. コンフリクト解決パターン

| パターン | 動作 | 適用ケース | リスク |
|---------|------|-----------|--------|
| **Last Write Wins** | タイムスタンプが新しい方を採用 | 設定値、プロフィール | 先の変更が失われる |
| **Client Wins** | クライアントの変更を優先 | オフライン作成データ | サーバーデータ消失 |
| **Server Wins** | サーバーの変更を優先 | マスターデータ | クライアント変更消失 |
| **Manual Merge** | ユーザーに選択させる | 重要なデータ | UX 負荷 |
| **Field-Level Merge** | フィールド単位で最新を採用 | 複合オブジェクト | 実装複雑 |

```dart
abstract class ConflictResolver<T> {
  Future<T> resolve(T local, T remote);
}

// Last Write Wins
class LastWriteWinsResolver<T extends Timestamped> implements ConflictResolver<T> {
  @override
  Future<T> resolve(T local, T remote) async {
    return local.updatedAt.isAfter(remote.updatedAt) ? local : remote;
  }
}

// Manual Merge（ユーザーに選択させる）
class ManualMergeResolver<T> implements ConflictResolver<T> {
  final Future<T> Function(T local, T remote) _showConflictDialog;

  ManualMergeResolver(this._showConflictDialog);

  @override
  Future<T> resolve(T local, T remote) async {
    return _showConflictDialog(local, remote);
  }
}
```

---

## 6. 楽観的 UI 更新

ネットワークリクエストの完了を待たずに UI を更新する。失敗時はロールバックする。

```dart
class OptimisticUpdateManager<T> {
  final LocalDataSource<T> _localDataSource;
  final RemoteDataSource<T> _remoteDataSource;
  final SyncQueueManager _syncQueue;

  OptimisticUpdateManager(
    this._localDataSource,
    this._remoteDataSource,
    this._syncQueue,
  );

  /// 楽観的更新: ローカルを即更新し、バックグラウンドで同期
  Future<void> update(String id, T newData, T previousData) async {
    // 1. ローカルを即座に更新（UI に即反映）
    await _localDataSource.save(id, newData);

    // 2. 同期キューに追加
    try {
      await _remoteDataSource.update(id, newData);
    } on Exception {
      // 3. ネットワークエラー → キューに蓄積
      await _syncQueue.enqueue(SyncQueueEntry(
        id: const Uuid().v4(),
        entityType: T.toString(),
        entityId: id,
        operation: SyncOperation.update,
        payload: _serialize(newData),
        createdAt: DateTime.now(),
      ));
    }
  }

  /// 同期失敗時のロールバック
  Future<void> rollback(String id, T previousData) async {
    await _localDataSource.save(id, previousData);
  }

  Map<String, dynamic> _serialize(T data) {
    // シリアライズ実装
    throw UnimplementedError();
  }
}
```

---

## 7. ネットワーク状態監視

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkMonitor(this._connectivity);

  /// ネットワーク状態を監視し、接続復帰時にコールバックを実行
  void startMonitoring({
    required VoidCallback onConnected,
    required VoidCallback onDisconnected,
  }) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (isConnected) {
        onConnected();
      } else {
        onDisconnected();
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

// 使用例: 接続復帰時に同期キューを処理
class AppSyncService {
  final NetworkMonitor _networkMonitor;
  final SyncQueueManager _syncQueue;

  AppSyncService(this._networkMonitor, this._syncQueue);

  void initialize() {
    _networkMonitor.startMonitoring(
      onConnected: () async {
        final result = await _syncQueue.processQueue();
        debugPrint('Sync completed: ${result.success} success, ${result.failed} failed');
      },
      onDisconnected: () {
        debugPrint('Network disconnected. Changes will be queued.');
      },
    );
  }
}
```

---

## チェックリスト

### オフライン対応設計時
- [ ] キャッシュ戦略（Cache First / Network First / SWR）を各データ種別ごとに定義したか
- [ ] ローカルストレージの選択理由を明確にしたか
- [ ] 同期キューの設計（操作順序、リトライ回数、失敗時の挙動）を定義したか
- [ ] コンフリクト解決パターンをエンティティごとに決定したか
- [ ] 楽観的 UI 更新のロールバック処理を実装したか

### 実装時
- [ ] UI は常にローカルストレージからデータを取得しているか
- [ ] ネットワーク状態の監視を実装しているか
- [ ] 接続復帰時に同期キューが自動処理されるか
- [ ] キャッシュの有効期限を適切に設定しているか
- [ ] 同期失敗時のリトライ回数に上限があるか（無限リトライ禁止）

### テスト時
- [ ] オフライン状態での CRUD 操作が正常に動作するか
- [ ] オンライン復帰後にデータが正しく同期されるか
- [ ] コンフリクト発生時に正しく解決されるか
- [ ] 同期キューの順序が保持されているか
- [ ] リトライ上限超過時にエラーが適切に処理されるか
