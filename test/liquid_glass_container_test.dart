import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_container/liquid_glass_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Widget child) => CupertinoApp(
        home: CupertinoPageScaffold(child: Center(child: child)),
      );

  group('LiquidGlassContainer (fallback path)', () {
    // Widget tests run with a non-iOS defaultTargetPlatform unless
    // overridden, so these exercise the Flutter-drawn fallback.
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(host(
        const LiquidGlassContainer(
          padding: EdgeInsets.all(16),
          child: Text('Now playing'),
        ),
      ));
      expect(find.text('Now playing'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('respects fixed dimensions', (tester) async {
      await tester.pumpWidget(host(
        const LiquidGlassContainer(width: 200, height: 80),
      ));
      final size = tester.getSize(find.byType(LiquidGlassContainer));
      expect(size, const Size(200, 80));
    });

    testWidgets('fallbackIntensity 0 removes the blur', (tester) async {
      await tester.pumpWidget(host(
        const LiquidGlassContainer(
          width: 100,
          height: 50,
          fallbackIntensity: 0,
        ),
      ));
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('high contrast renders without blur', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: host(
            const LiquidGlassContainer(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('LiquidGlassContainer (native path)', () {
    testWidgets('uses a platform view on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(host(
        const LiquidGlassContainer(width: 100, height: 50),
      ));
      expect(find.byType(UiKitView), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('LiquidGlassBottomBar', () {
    const items = [
      LiquidGlassBarItem(icon: CupertinoIcons.house, label: 'Home'),
      LiquidGlassBarItem(icon: CupertinoIcons.search, label: 'Search'),
      LiquidGlassBarItem(icon: CupertinoIcons.person, label: 'Profile'),
    ];

    testWidgets('shows every destination and reports taps', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(host(
        LiquidGlassBottomBar(
          items: items,
          currentIndex: 0,
          onTap: taps.add,
        ),
      ));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      expect(taps, [2]);
    });

    testWidgets('marks the current destination as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(
        LiquidGlassBottomBar(
          items: items,
          currentIndex: 1,
          onTap: (_) {},
        ),
      ));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Search')),
        isSemantics(isSelected: true, isButton: true, label: 'Search'),
      );
      handle.dispose();
    });

    testWidgets('hides labels when showLabels is false', (tester) async {
      await tester.pumpWidget(host(
        LiquidGlassBottomBar(
          items: items,
          currentIndex: 0,
          onTap: (_) {},
          showLabels: false,
        ),
      ));
      expect(find.text('Home'), findsNothing);
    });
  });

  group('LiquidGlass.capabilities', () {
    tearDown(() => LiquidGlass.debugOverrideCapabilities(null));

    test('resolves to none off-iOS', () async {
      LiquidGlass.debugOverrideCapabilities(null);
      final caps = await LiquidGlass.capabilities();
      expect(caps.nativeGlass, isFalse);
    });

    testWidgets('parses the native reply on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('liquid_glass_container'),
        (call) async => {
          'nativeGlass': true,
          'reduceTransparency': false,
          'osMajorVersion': 27,
        },
      );
      LiquidGlass.debugOverrideCapabilities(null);
      final caps = await LiquidGlass.capabilities();
      expect(caps.nativeGlass, isTrue);
      expect(caps.osMajorVersion, 27);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
