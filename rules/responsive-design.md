# Responsive Design Rules

モバイルアプリのレスポンシブ UI 設計に関する必須ルール。多様な画面サイズ・デバイスに適応する UI を構築する。

---

## 1. Adaptive vs Responsive の違い

| 概念 | 定義 | 使い分け |
|------|------|---------|
| **Responsive** | 同一レイアウトが画面サイズに応じて伸縮する | フォーム、リスト、カード等の連続的なサイズ変化 |
| **Adaptive** | 画面サイズに応じて異なるレイアウトに切り替える | Phone → Tablet で2ペイン化、ナビゲーション変更等 |

```
Phone (< 600dp)          Tablet (>= 600dp)
┌──────────────┐         ┌──────────┬──────────┐
│  List View   │         │  List    │  Detail  │
│  ──────────  │  ──→    │  ─────  │  ─────── │
│  ──────────  │         │  ─────  │  ─────── │
│  ──────────  │         │  ─────  │  ─────── │
└──────────────┘         └──────────┴──────────┘
   Responsive               Adaptive
```

---

## 2. 画面サイズ分類

### ブレークポイント定義

| カテゴリ | 幅 (dp/pt) | デバイス例 |
|---------|-----------|-----------|
| **Compact** | < 600 | Phone (portrait) |
| **Medium** | 600 - 839 | Tablet (portrait), Foldable (open) |
| **Expanded** | >= 840 | Tablet (landscape), Desktop |

### Flutter: 画面サイズ判定

```dart
enum ScreenSize { compact, medium, expanded }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return ScreenSize.compact;
  if (width < 840) return ScreenSize.medium;
  return ScreenSize.expanded;
}

// LayoutBuilder を使用した Adaptive レイアウト
class AdaptiveLayout extends StatelessWidget {
  final Widget compactLayout;
  final Widget mediumLayout;
  final Widget expandedLayout;

  const AdaptiveLayout({
    required this.compactLayout,
    required this.mediumLayout,
    required this.expandedLayout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) return compactLayout;
        if (constraints.maxWidth < 840) return mediumLayout;
        return expandedLayout;
      },
    );
  }
}
```

### iOS: Size Classes

```swift
// Size Classes による分岐
struct AdaptiveView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            // Phone レイアウト
            NavigationStack {
                OrderListView()
            }
        } else {
            // Tablet レイアウト（2ペイン）
            NavigationSplitView {
                OrderListView()
            } detail: {
                OrderDetailView()
            }
        }
    }
}
```

### Android: Window Size Classes

```kotlin
@Composable
fun AdaptiveScreen() {
    val windowSizeClass = calculateWindowSizeClass(LocalContext.current as Activity)

    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> {
            // Phone レイアウト
            OrderListScreen()
        }
        WindowWidthSizeClass.Medium -> {
            // Medium レイアウト
            OrderListDetailScreen(listWeight = 0.4f, detailWeight = 0.6f)
        }
        WindowWidthSizeClass.Expanded -> {
            // Tablet/Desktop レイアウト
            OrderListDetailScreen(listWeight = 0.3f, detailWeight = 0.7f)
        }
    }
}
```

---

## 3. セーフエリア対応

ノッチ、ダイナミックアイランド、ナビゲーションバー等のシステム UI 領域を考慮する。

### Flutter: SafeArea

```dart
// ❌ BAD: セーフエリア未考慮
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      HeaderWidget(),  // ノッチに被る可能性
      Expanded(child: ContentWidget()),
    ],
  );
}

// ✅ GOOD: SafeArea で保護
@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Column(
      children: [
        HeaderWidget(),
        Expanded(child: ContentWidget()),
      ],
    ),
  );
}

// ✅ GOOD: 部分的なセーフエリア（Scaffold 使用時は上部は AppBar が処理）
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Orders')),
    body: SafeArea(
      top: false, // AppBar が処理するため不要
      child: ContentWidget(),
    ),
  );
}
```

### iOS: safeAreaInsets

```swift
struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Safe Area Top: \(geometry.safeAreaInsets.top)")
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea(.container, edges: .top) // 背景画像用
    }
}
```

---

## 4. 折りたたみ端末対応（Foldable）

### Flutter: Foldable 対応

```dart
// dual_screen パッケージを使用
import 'package:dual_screen/dual_screen.dart';

class FoldableAwareLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TwoPane(
      startPane: OrderListPane(),
      endPane: OrderDetailPane(),
      paneProportion: 0.4,
      panePriority: MediaQuery.sizeOf(context).width < 600
          ? TwoPanePriority.start
          : TwoPanePriority.both,
    );
  }
}
```

### Android: Foldable API

```kotlin
@Composable
fun FoldableAwareLayout() {
    val foldingFeatures = WindowInfoTracker
        .getOrCreate(LocalContext.current as Activity)
        .windowLayoutInfo
        .collectAsState(initial = null)

    val foldState = foldingFeatures.value
        ?.displayFeatures
        ?.filterIsInstance<FoldingFeature>()
        ?.firstOrNull()

    when {
        foldState?.state == FoldingFeature.State.HALF_OPENED -> {
            // テーブルトップモード: 上下分割
            TableTopLayout()
        }
        foldState?.isSeparating == true -> {
            // ブックモード: 左右分割
            BookLayout()
        }
        else -> {
            // 通常モード
            StandardLayout()
        }
    }
}
```

---

## 5. 向き対応（Portrait / Landscape）

### Flutter: 向き検出と制御

```dart
// 向きに応じたレイアウト切り替え
class OrientationAwareLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return _buildVerticalLayout();
        }
        return _buildHorizontalLayout();
      },
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        HeaderSection(),
        Expanded(child: ContentSection()),
        FooterSection(),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        SizedBox(width: 300, child: SidePanel()),
        Expanded(child: ContentSection()),
      ],
    );
  }
}

// 向きのロック（特定画面のみ）
class VideoPlayerScreen extends StatefulWidget {
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
```

---

## 6. フォントスケーリング

ユーザーのシステム設定によるフォントサイズ変更に対応する。

### Flutter: テキストスケーリング

```dart
// ❌ BAD: 固定サイズでスケーリング無視
Text(
  'Hello',
  style: TextStyle(fontSize: 16),
  textScaler: TextScaler.noScaling, // スケーリング無効化は避ける
)

// ✅ GOOD: スケーリング対応しつつ上限を設定
@override
Widget build(BuildContext context) {
  // システムのフォントスケールを取得
  final textScaler = MediaQuery.textScalerOf(context);

  return MediaQuery(
    // 最大1.5倍までに制限（レイアウト崩れ防止）
    data: MediaQuery.of(context).copyWith(
      textScaler: textScaler.clamp(maxScaleFactor: 1.5),
    ),
    child: child,
  );
}

// ✅ GOOD: sp 相当の柔軟なサイズ指定
class AppTextStyles {
  static TextStyle heading(BuildContext context) {
    return TextStyle(
      fontSize: 20, // スケーリングに追従
      fontWeight: FontWeight.bold,
      height: 1.4,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      height: 1.5,
    );
  }
}
```

### iOS: Dynamic Type

```swift
// ✅ GOOD: Dynamic Type 対応
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Heading")
                .font(.title)        // Dynamic Type 自動対応
            Text("Body text")
                .font(.body)         // Dynamic Type 自動対応
            Text("Custom size")
                .font(.custom("Helvetica", size: 16, relativeTo: .body))
        }
    }
}

// UIKit
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
```

---

## 7. レスポンシブグリッド

### Flutter: 適応的グリッドレイアウト

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2;   // Phone: 2列
    if (width < 840) return 3;   // Tablet portrait: 3列
    return 4;                     // Tablet landscape: 4列
  }
}
```

---

## 8. 画面サイズ対応の共通パターン

### パディング・マージンの可変化

```dart
class ResponsivePadding {
  static EdgeInsets screen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return const EdgeInsets.all(16);
    if (width < 840) return const EdgeInsets.all(24);
    return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
  }

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return double.infinity;
    if (width < 840) return 720;
    return 960;
  }
}

// 使用例
class ScreenWrapper extends StatelessWidget {
  final Widget child;
  const ScreenWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsivePadding.maxContentWidth(context),
        ),
        child: Padding(
          padding: ResponsivePadding.screen(context),
          child: child,
        ),
      ),
    );
  }
}
```

---

## チェックリスト

### 新規画面作成時
- [ ] ブレークポイント（Compact / Medium / Expanded）に応じたレイアウトを検討したか
- [ ] SafeArea を適切に適用しているか
- [ ] 向きの変更（Portrait / Landscape）でレイアウトが崩れないか
- [ ] フォントスケーリング（最大1.5倍）でレイアウトが崩れないか
- [ ] タッチターゲットサイズが最小 44x44pt / 48x48dp 以上か
- [ ] 固定幅の要素に maxWidth を併記しているか

### Tablet / Foldable 対応時
- [ ] Adaptive レイアウト（2ペイン等）を実装しているか
- [ ] 折りたたみ端末のヒンジ領域にコンテンツが被らないか
- [ ] ナビゲーションパターンが画面サイズに適応しているか（BottomNav → NavigationRail → Drawer）

### レビュー時
- [ ] MediaQuery.of(context).size ではなく MediaQuery.sizeOf(context) を使用しているか（Flutter 3.10+）
- [ ] LayoutBuilder を使用して親のサイズに応じたレイアウトを実装しているか
- [ ] ハードコードされたサイズ値が最小限か
- [ ] パディング・マージンがレスポンシブに調整されているか
