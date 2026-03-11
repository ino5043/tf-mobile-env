---
name: push-notification
description: Design and implement push notifications with FCM, APNs, and local notifications including permission handling.
---

# プッシュ通知スキル

FCM (Firebase Cloud Messaging)、APNs (Apple Push Notification service)、ローカル通知の設計と実装を支援するスキル。パーミッション要求の UX からバックグラウンド処理まで網羅する。

---

## 1. FCM (Firebase Cloud Messaging) セットアップ

### 1.1 Firebase プロジェクト設定

1. [Firebase Console](https://console.firebase.google.com/) でプロジェクトを作成
2. iOS / Android アプリを登録
3. 設定ファイルをダウンロード

| プラットフォーム | ファイル | 配置場所 |
|----------------|---------|---------|
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |
| Android | `google-services.json` | `android/app/` |

### 1.2 Flutter パッケージ設定

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0
```

### 1.3 初期化コード

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// バックグラウンドメッセージハンドラ（トップレベル関数）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // バックグラウンドでの処理（DB保存、ローカル通知表示等）
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}
```

---

## 2. APNs (Apple Push Notification service) セットアップ

### 2.1 証明書設定

| 方式 | 推奨 | 説明 |
|------|------|------|
| APNs Key (.p8) | 推奨 | 有効期限なし、全アプリ共通 |
| APNs Certificate (.p12) | 非推奨 | 1年ごとに更新が必要 |

### APNs Key の作成手順

1. Apple Developer > Certificates, Identifiers & Profiles > Keys
2. `+` ボタン > Key Name を入力 > Apple Push Notifications Service (APNs) にチェック
3. Key をダウンロード（`.p8` ファイル、**1回のみダウンロード可能**）
4. Key ID と Team ID を記録

### 2.2 Xcode 設定

1. Target > Signing & Capabilities > `+ Capability`
2. `Push Notifications` を追加
3. `Background Modes` を追加 > `Remote notifications` にチェック

### 2.3 Firebase への APNs Key 登録

Firebase Console > Project Settings > Cloud Messaging > iOS app > APNs Authentication Key をアップロード。

---

## 3. 通知ペイロード設計

### 3.1 Notification Message vs Data Message

| 種別 | 表示 | ハンドリング | 用途 |
|------|------|-------------|------|
| Notification Message | システムが自動表示 | フォアグラウンドのみカスタム可 | シンプルな通知 |
| Data Message | アプリが制御 | 全状態でカスタム可 | カスタム処理が必要な通知 |
| 混合 (Notification + Data) | システムが表示 + データ付与 | バックグラウンド時はシステム表示 | 一般的な用途 |

### 3.2 ペイロード例

```json
{
  "message": {
    "token": "FCM_DEVICE_TOKEN",
    "notification": {
      "title": "新しいメッセージ",
      "body": "田中さんからメッセージが届きました"
    },
    "data": {
      "type": "chat_message",
      "chatRoomId": "room_123",
      "senderId": "user_456",
      "timestamp": "2026-03-11T10:00:00Z"
    },
    "android": {
      "notification": {
        "channel_id": "chat_messages",
        "icon": "ic_notification",
        "color": "#4CAF50",
        "click_action": "OPEN_CHAT"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "badge": 5,
          "sound": "default",
          "category": "CHAT_MESSAGE",
          "mutable-content": 1
        }
      }
    }
  }
}
```

---

## 4. パーミッション要求のタイミングと UX

### 4.1 推奨パターン

```
NG: アプリ起動直後にダイアログ表示
    → 拒否率が高い（ユーザーがアプリの価値を理解していない）

OK: 以下のタイミングで表示
    1. オンボーディング完了後
    2. 通知が有益な機能を初めて使用したとき
    3. 設定画面から手動で有効化
```

### 4.2 Pre-Permission ダイアログ

OS の許可ダイアログの前にアプリ独自の説明画面を表示する。

```dart
Future<void> requestNotificationPermission(BuildContext context) async {
  // 既に許可済みか確認
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    return;
  }

  // アプリ独自の説明ダイアログを表示
  final shouldRequest = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('通知を有効にしますか？'),
      content: const Text(
        '新しいメッセージや重要なお知らせを\nリアルタイムでお届けします。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('あとで'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('有効にする'),
        ),
      ],
    ),
  );

  if (shouldRequest == true) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }
}
```

---

## 5. ローカル通知 (flutter_local_notifications)

### 5.1 初期化

```dart
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      // 通知タップ時の処理
      handleNotificationTap(response.payload);
    },
  );
}
```

### 5.2 通知表示

```dart
Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'default_channel',
    'デフォルト',
    channelDescription: '一般的な通知',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  await flutterLocalNotificationsPlugin.show(id, title, body, details, payload: payload);
}
```

---

## 6. 通知チャネル設計 (Android)

Android 8.0 (API 26) 以降、通知チャネルが必須。

```dart
const channels = [
  AndroidNotificationChannel(
    'chat_messages',       // ID
    'チャットメッセージ',    // Name
    description: '新着チャットメッセージの通知',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('chat_sound'),
  ),
  AndroidNotificationChannel(
    'order_updates',
    '注文状況',
    description: '注文の配送状況に関する通知',
    importance: Importance.high,
  ),
  AndroidNotificationChannel(
    'promotions',
    'お知らせ・キャンペーン',
    description: 'セールやキャンペーンのお知らせ',
    importance: Importance.low,
  ),
];
```

### チャネル設計の原則

| 原則 | 説明 |
|------|------|
| ユーザーが個別に制御可能 | チャネルごとに通知 ON/OFF が可能 |
| Importance は適切に設定 | `high` は重要な通知のみ、`low` はマーケティング系 |
| チャネル数は最小限 | 3〜5 チャネルが推奨、多すぎると設定が煩雑 |
| チャネル ID は変更不可 | 一度作成した ID は変更できない（新規作成が必要） |

---

## 7. Rich Notification

### 画像付き通知 (Android)

```dart
Future<void> showImageNotification(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  final bigPicture = ByteArrayAndroidBitmap(response.bodyBytes);
  final details = AndroidNotificationDetails(
    'promotions',
    'お知らせ',
    styleInformation: BigPictureStyleInformation(bigPicture),
  );
  // ...
}
```

### アクションボタン付き通知

```dart
const androidDetails = AndroidNotificationDetails(
  'chat_messages',
  'チャット',
  actions: [
    AndroidNotificationAction('reply', '返信', inputs: [AndroidNotificationActionInput(label: 'メッセージを入力')]),
    AndroidNotificationAction('mark_read', '既読にする'),
  ],
);
```

---

## 8. バックグラウンド / Terminated 時の処理

| アプリ状態 | Notification Message | Data Message |
|-----------|---------------------|--------------|
| Foreground | `onMessage` で受信 | `onMessage` で受信 |
| Background | システム表示 → タップで `onMessageOpenedApp` | `onBackgroundMessage` で受信 |
| Terminated | システム表示 → タップで `getInitialMessage` | `onBackgroundMessage` で受信 |

```dart
class NotificationService {
  Future<void> setupInteractedMessage() async {
    // Terminated 状態からの起動
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Background → Foreground
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Foreground
    FirebaseMessaging.onMessage.listen((message) {
      // ローカル通知として表示
      showLocalNotification(
        id: message.hashCode,
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    });
  }

  void _handleMessage(RemoteMessage message) {
    final type = message.data['type'];
    switch (type) {
      case 'chat_message':
        navigateTo('/chat/${message.data['chatRoomId']}');
      case 'order_update':
        navigateTo('/orders/${message.data['orderId']}');
    }
  }
}
```
