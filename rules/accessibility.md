# Accessibility Rules

モバイルアプリのアクセシビリティ対応に関する必須ルール。WCAG 2.1 AA 準拠を目標とし、すべてのユーザーが利用可能なアプリを構築する。

---

## 1. スクリーンリーダー対応

### VoiceOver (iOS) / TalkBack (Android) 基本原則

| 原則 | 説明 | 必須度 |
|------|------|--------|
| すべてのインタラクティブ要素にラベルを付ける | ボタン、リンク、入力フィールド | CRITICAL |
| 装飾画像をスクリーンリーダーから除外する | アイコン装飾、背景画像 | CRITICAL |
| 意味のある画像に代替テキストを付ける | 商品画像、チャートの図 | CRITICAL |
| 操作のヒントを提供する | 「ダブルタップで開く」等 | HIGH |
| 状態変化をアナウンスする | ローディング完了、エラー発生 | HIGH |

### Flutter: Semantics Widget

```dart
// ❌ BAD: ラベルなしのアイコンボタン
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () => deleteItem(),
)

// ✅ GOOD: Semantics でラベルとヒントを付与
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () => deleteItem(),
  tooltip: '削除',  // Semantics のラベルとしても機能
)

// ✅ GOOD: 複雑なウィジェットの場合
Semantics(
  label: '注文番号 A-1234',
  hint: 'ダブルタップで詳細を表示',
  button: true,
  child: OrderCard(order: order),
)

// 装飾画像を除外
Semantics(
  excludeSemantics: true,
  child: Image.asset('assets/decorative_border.png'),
)

// 意味のある画像に代替テキスト
Image.network(
  product.imageUrl,
  semanticLabel: '${product.name}の商品画像',
)

// 状態変化のアナウンス
void _onDataLoaded() {
  SemanticsService.announce(
    '${items.length}件のデータを読み込みました',
    TextDirection.ltr,
  );
}
```

### Flutter: カスタム Semantics

```dart
class AccessibleStatusBadge extends StatelessWidget {
  final OrderStatus status;
  final int count;

  const AccessibleStatusBadge({
    required this.status,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${status.displayName}: $count 件',
      // スクリーンリーダーは子要素のテキストを個別に読まない
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(status.icon, color: status.color),
          const SizedBox(width: 4),
          Text(status.displayName),
          const SizedBox(width: 4),
          Badge(label: Text('$count')),
        ],
      ),
    );
  }
}
```

### iOS: accessibilityLabel / accessibilityHint

```swift
// SwiftUI
struct OrderCardView: View {
    let order: Order

    var body: some View {
        VStack {
            Text(order.title)
            Text(order.status.displayName)
        }
        .accessibilityElement(children: .combine) // 子要素を結合
        .accessibilityLabel("注文 \(order.title)、ステータス: \(order.status.displayName)")
        .accessibilityHint("ダブルタップで注文詳細を表示します")
        .accessibilityAddTraits(.isButton)
    }
}

// 装飾画像の除外
Image("decorative_icon")
    .accessibilityHidden(true)

// 意味のある画像
Image(order.productImageName)
    .accessibilityLabel("\(order.productName)の商品画像")

// 状態変化のアナウンス
UIAccessibility.post(
    notification: .announcement,
    argument: "\(items.count)件のデータを読み込みました"
)
```

### Kotlin (Android): contentDescription

```kotlin
// Jetpack Compose
@Composable
fun OrderCard(order: Order) {
    Card(
        modifier = Modifier
            .clickable { navigateToDetail(order.id) }
            .semantics {
                contentDescription = "注文 ${order.title}、ステータス: ${order.status.displayName}"
                stateDescription = order.status.displayName
            }
    ) {
        // カードの中身
    }
}

// 装飾画像の除外
Icon(
    imageVector = Icons.Default.Star,
    contentDescription = null, // 装飾のみ
    tint = Color.Yellow
)

// 意味のある画像
Image(
    painter = rememberAsyncImagePainter(order.imageUrl),
    contentDescription = "${order.productName}の商品画像"
)

// 状態変化のアナウンス
val context = LocalContext.current
LaunchedEffect(items) {
    val manager = context.getSystemService(Context.ACCESSIBILITY_SERVICE)
        as AccessibilityManager
    if (manager.isEnabled) {
        val event = AccessibilityEvent.obtain(
            AccessibilityEvent.TYPE_ANNOUNCEMENT
        ).apply {
            text.add("${items.size}件のデータを読み込みました")
        }
        manager.sendAccessibilityEvent(event)
    }
}
```

---

## 2. カラーコントラスト

### WCAG 2.1 AA 基準

| テキストサイズ | 最低コントラスト比 | 例 |
|--------------|-------------------|-----|
| 通常テキスト (< 18pt / < 14pt bold) | **4.5:1** | 本文、ラベル、ボタンテキスト |
| 大テキスト (>= 18pt / >= 14pt bold) | **3:1** | 見出し、タイトル |
| UI コンポーネント・アイコン | **3:1** | ボタン枠線、アイコン、フォーカスインジケータ |

```dart
// ❌ BAD: 低コントラスト
Text(
  'ステータス: 処理中',
  style: TextStyle(color: Color(0xFFBBBBBB)), // 灰色 on 白背景 → 2.6:1
)

// ✅ GOOD: 十分なコントラスト
Text(
  'ステータス: 処理中',
  style: TextStyle(color: Color(0xFF595959)), // 濃い灰色 on 白背景 → 7.0:1
)
```

### カラーのみに依存しない情報伝達

```dart
// ❌ BAD: 色だけでエラーを示す
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
    ),
  ),
)

// ✅ GOOD: 色 + テキスト + アイコンでエラーを示す
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: hasError ? Colors.red : Colors.grey,
        width: hasError ? 2 : 1,
      ),
    ),
    errorText: hasError ? 'メールアドレスの形式が正しくありません' : null,
    suffixIcon: hasError ? Icon(Icons.error, color: Colors.red) : null,
  ),
)
```

---

## 3. タッチターゲットサイズ

### 最小サイズ基準

| プラットフォーム | 最小サイズ | 推奨サイズ |
|----------------|-----------|-----------|
| **iOS** | 44 x 44 pt | 44 x 44 pt |
| **Android** | 48 x 48 dp | 48 x 48 dp |
| **Flutter** | 48 x 48 dp | 48 x 48 dp |

```dart
// ❌ BAD: タッチターゲットが小さすぎる
GestureDetector(
  onTap: () => onDelete(),
  child: Icon(Icons.close, size: 16), // 16x16 → 小さすぎる
)

// ✅ GOOD: 最小タッチターゲットを確保
IconButton(
  onPressed: () => onDelete(),
  icon: Icon(Icons.close, size: 16),
  // IconButton はデフォルトで 48x48 のタッチ領域を確保
  constraints: const BoxConstraints(
    minWidth: 48,
    minHeight: 48,
  ),
)

// ✅ GOOD: カスタムウィジェットの場合
GestureDetector(
  onTap: () => onDelete(),
  child: Padding(
    padding: const EdgeInsets.all(12), // 16 + 12*2 = 40 → もう少し
    child: Icon(Icons.close, size: 16),
  ),
)

// SizedBox で明示的にサイズを確保
SizedBox(
  width: 48,
  height: 48,
  child: Center(
    child: Icon(Icons.close, size: 16),
  ),
)
```

### 隣接するターゲット間のスペース

```dart
// ❌ BAD: ボタンが密接しすぎ
Row(
  children: [
    IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
    IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
    // タッチ領域が重なる可能性
  ],
)

// ✅ GOOD: 十分なスペースを確保
Row(
  children: [
    IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
    const SizedBox(width: 8), // 最低 8dp のスペース
    IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
  ],
)
```

---

## 4. フォントスケーリング対応

```dart
// ❌ BAD: 固定高さのコンテナにテキスト
Container(
  height: 40, // フォントスケーリングでテキストが溢れる
  child: Text('説明テキスト'),
)

// ✅ GOOD: 高さを固定しない、または minHeight を使用
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 40),
  child: Text('説明テキスト'),
)

// ✅ GOOD: テキストの省略ではなく折り返し
Text(
  '長いテキストの例',
  overflow: TextOverflow.visible, // 省略せず表示
  softWrap: true,
)
```

---

## 5. ナビゲーション順序の制御

### Flutter: FocusTraversalGroup

```dart
// ✅ GOOD: 論理的なフォーカス順序を指定
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: TextField(
          decoration: InputDecoration(labelText: '名前'),
        ),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2),
        child: TextField(
          decoration: InputDecoration(labelText: 'メールアドレス'),
        ),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(3),
        child: ElevatedButton(
          onPressed: _submit,
          child: Text('送信'),
        ),
      ),
    ],
  ),
)
```

### iOS: accessibilityElements

```swift
struct FormView: View {
    var body: some View {
        VStack {
            TextField("名前", text: $name)
                .accessibilityLabel("名前入力欄")
                .accessibilitySortPriority(3) // 高い数値が先に読まれる

            TextField("メールアドレス", text: $email)
                .accessibilityLabel("メールアドレス入力欄")
                .accessibilitySortPriority(2)

            Button("送信") { submit() }
                .accessibilitySortPriority(1)
        }
    }
}
```

---

## 6. アクセシビリティテスト手法

### 手動テスト

| ツール | プラットフォーム | テスト内容 |
|--------|---------------|-----------|
| **Accessibility Inspector** | iOS (Xcode) | ラベル、ヒント、トレイト確認 |
| **Accessibility Scanner** | Android | コントラスト、ターゲットサイズ |
| **VoiceOver** | iOS 実機 | 実際の読み上げ体験 |
| **TalkBack** | Android 実機 | 実際の読み上げ体験 |

### Flutter: Semantics Debugger

```dart
// デバッグ時にセマンティクス情報をオーバーレイ表示
MaterialApp(
  showSemanticsDebugger: true, // デバッグ用
  home: MyHomePage(),
)
```

### 自動テスト

```dart
// Flutter Widget Test: アクセシビリティ検証
testWidgets('OrderCard has correct semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: OrderCard(order: testOrder),
    ),
  );

  // Semantics ラベルの検証
  final semantics = tester.getSemantics(find.byType(OrderCard));
  expect(semantics.label, contains('注文番号'));
  expect(semantics.hint, contains('ダブルタップ'));

  // タッチターゲットサイズの検証
  final size = tester.getSize(find.byType(IconButton));
  expect(size.width, greaterThanOrEqualTo(48));
  expect(size.height, greaterThanOrEqualTo(48));
});

// ガイドライン準拠テスト
testWidgets('meets accessibility guidelines', (tester) async {
  final handle = tester.ensureSemantics();

  await tester.pumpWidget(MaterialApp(home: MyScreen()));

  // Android タップターゲットガイドライン
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

  // iOS タップターゲットガイドライン
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

  // テキストコントラストガイドライン
  await expectLater(tester, meetsGuideline(textContrastGuideline));

  // ラベル付きタップターゲットガイドライン
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

  handle.dispose();
});
```

---

## 7. モーション・アニメーション配慮

```dart
// ユーザーの「モーションを減らす」設定を尊重
class MotionAwareAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const MotionAwareAnimation({
    required this.child,
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // モーション軽減設定を確認
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    if (reduceMotion) {
      // アニメーションなしで即表示
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
```

---

## チェックリスト（WCAG 2.1 AA 準拠）

### 知覚可能（Perceivable）
- [ ] すべての意味のある画像に代替テキスト（semanticLabel / contentDescription）があるか
- [ ] 装飾画像がスクリーンリーダーから除外されているか
- [ ] テキストのコントラスト比が 4.5:1 以上（大テキストは 3:1 以上）か
- [ ] 色だけに依存せず、テキストやアイコンで情報を伝えているか
- [ ] フォントスケーリング（最大 200%）でコンテンツが溢れないか

### 操作可能（Operable）
- [ ] タッチターゲットが 44x44pt (iOS) / 48x48dp (Android) 以上か
- [ ] 隣接するタッチターゲット間に十分なスペースがあるか
- [ ] キーボード / 外部スイッチでの操作が可能か
- [ ] フォーカス順序が論理的か
- [ ] 「モーションを減らす」設定を尊重しているか

### 理解可能（Understandable）
- [ ] すべてのインタラクティブ要素にラベルがあるか
- [ ] エラーメッセージが具体的で修正方法を示しているか
- [ ] 入力フィールドにヒント（placeholder ではなく label）があるか
- [ ] ナビゲーション構造が一貫しているか

### 堅牢（Robust）
- [ ] Semantics / accessibilityLabel が正しく設定されているか
- [ ] 状態変化がスクリーンリーダーにアナウンスされるか
- [ ] アクセシビリティ自動テストがCIに含まれているか
- [ ] 実機で VoiceOver / TalkBack テストを実施したか
