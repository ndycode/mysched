# MySched Performance Guidelines

This document covers performance optimization strategies, profiling techniques, and best practices.

---

## Performance Philosophy

MySched prioritizes:

1. **Perceived performance**: App feels fast, even if operations take time
2. **Startup speed**: Minimal time to interactive
3. **Battery efficiency**: Minimize background work
4. **Memory efficiency**: Avoid leaks and excessive allocation

---

## Startup Optimization

### Bootstrap Sequence

```dart
// main.dart - Optimized startup order
Future<void> _runApp() async {
  // 1. Critical path (awaited)
  await Env.init();
  await ThemeController.instance.init();
  
  // 2. Remove splash after critical init
  FlutterNativeSplash.remove();
  
  // 3. Deferred init (fire and forget)
  ConnectionMonitor.instance.startMonitoring();
  OfflineQueue.instance.init();  // Don't await
  DataSync.instance.init();       // Don't await
  
  runApp(const MySchedApp());
}
```

### Startup Metrics

Track bootstrap time:

```dart
final bootstrapStopwatch = Stopwatch()..start();
// ... initialization ...
bootstrapStopwatch.stop();
AnalyticsService.instance.logEvent(
  'ui_perf_bootstrap_ms',
  params: {'elapsed_ms': bootstrapStopwatch.elapsedMilliseconds},
);
```

**Target**: < 2 seconds to first meaningful paint

---

## List Performance

### ListView Best Practices

```dart
// ✅ Good: Use builder for long lists
ListView.builder(
  itemCount: classes.length,
  cacheExtent: AppLayout.listCacheExtent, // 800px
  itemBuilder: (context, index) => ClassCard(classes[index]),
)

// ❌ Bad: Don't use ListView with children directly
ListView(
  children: classes.map((c) => ClassCard(c)).toList(), // Builds all at once
)
```

### Cache Extent

Configure appropriate cache extent:

```dart
// tokens/layout.dart
static const double listCacheExtent = 800;
```

Larger cache = smoother scrolling, higher memory usage.

### Item Keys

Always provide keys for list items:

```dart
ListView.builder(
  itemBuilder: (context, index) => ClassCard(
    key: ValueKey(classes[index].id), // Enables efficient diffing
    scheduleClass: classes[index],
  ),
)
```

---

## Image Performance

### Avatar Caching

```dart
// Use cached network images
Image.network(
  avatarUrl,
  cacheWidth: 48, // Decode at display size
  cacheHeight: 48,
)
```

### Image Sizing

Specify dimensions to avoid layout shifts:

```dart
Container(
  width: 48,
  height: 48,
  child: Image.network(url),
)
```

---

## Animation Performance

### Use `const` Where Possible

```dart
// ✅ Const animations don't rebuild
const Duration(milliseconds: 300)
const Curve(Curves.easeOut)

// Use token constants
AppTokens.motion.fast // 150ms
AppTokens.motion.medium // 250ms
```

### Avoid Expensive Builds During Animation

```dart
// ✅ Rebuild only what changes
AnimatedBuilder(
  animation: controller,
  child: const ExpensiveChildWidget(), // Const child
  builder: (context, child) {
    return Transform.scale(
      scale: animation.value,
      child: child, // Reuses child
    );
  },
)
```

### Respect Reduced Motion

```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
final duration = reduceMotion ? Duration.zero : AppTokens.motion.medium;
```

---

## State Management Performance

### ValueNotifier Pattern

```dart
// Efficient: Only rebuilds when value changes
ValueListenableBuilder<bool>(
  valueListenable: isLoadingNotifier,
  builder: (context, isLoading, child) {
    return isLoading ? Spinner() : child!;
  },
  child: const ContentWidget(), // Const child not rebuilt
)
```

### Avoid Unnecessary Rebuilds

```dart
// ✅ Split widgets to minimize rebuild scope
class ParentWidget extends StatelessWidget {
  Widget build(context) {
    return Column(
      children: [
        const HeaderWidget(), // Never rebuilds
        const BodyWidget(),   // Never rebuilds
        FooterWithState(),    // Only this rebuilds on state change
      ],
    );
  }
}
```

---

## Network Performance

### Request Batching

```dart
// ✅ Batch related queries
final results = await Future.wait([
  Env.supa.from('classes').select(),
  Env.supa.from('reminders').select(),
]);

// ❌ Sequential requests
final classes = await Env.supa.from('classes').select();
final reminders = await Env.supa.from('reminders').select();
```

### Caching Strategy

```dart
class ScheduleRepository {
  // In-memory cache
  List<ScheduleClass>? _cachedClasses;
  DateTime? _cacheTime;
  
  Future<List<ScheduleClass>> getClasses() async {
    // Check cache validity (5 min TTL)
    if (_cachedClasses != null && 
        _cacheTime?.difference(DateTime.now()).inMinutes.abs() < 5) {
      return _cachedClasses!;
    }
    
    _cachedClasses = await _fetchFromNetwork();
    _cacheTime = DateTime.now();
    return _cachedClasses!;
  }
}
```

---

## Memory Management

### Dispose Controllers

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final AnimationController _controller;
  late final TextEditingController _textController;
  
  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

### Stream Subscriptions

```dart
class MyService {
  StreamSubscription? _subscription;
  
  void start() {
    _subscription = someStream.listen(_handleEvent);
  }
  
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
```

---

## Skeleton Screens

Show loading state immediately:

```dart
Widget build(BuildContext context) {
  if (isLoading) {
    return const ScheduleCardSkeleton(); // Instant feedback
  }
  return ScheduleCard(data: scheduleData);
}
```

Skeleton specs from design system:

```dart
// Shimmer effect
Animation duration: 1200ms
Color (light): onSurface @ 8%
Color (dark): onSurface @ 12%
```

---

## Profiling

### Flutter DevTools

```bash
flutter run --profile
# Open DevTools from VS Code or browser
```

### Key Metrics

| Metric | Target |
|--------|--------|
| Frame build time | < 16ms (60fps) |
| Frame render time | < 16ms |
| Startup time | < 2s to interactive |
| Memory baseline | < 150MB |

### Identify Jank

```dart
// Enable performance overlay
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

---

## Build Size

### Analyze APK Size

```bash
flutter build apk --analyze-size
```

### Common Optimizations

1. **Tree shaking**: Enabled by default in release builds
2. **Icon subsetting**: Use only needed Material icons
3. **Asset compression**: Use WebP for images
4. **Font subsetting**: Include only used glyphs

---

## Performance Checklist

For code reviews:

- [ ] Lists use `ListView.builder` with keys
- [ ] Animations use const durations/curves
- [ ] Controllers disposed in `dispose()`
- [ ] Streams cancelled on dispose
- [ ] Images have explicit dimensions
- [ ] Heavy operations off main thread
- [ ] Skeleton screens for loading states
- [ ] No excessive rebuilds (check with DevTools)
