import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_hotspot/image_hotspot.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // HotspotModel unit tests
  // ─────────────────────────────────────────────────────────────────────────
  group('HotspotModel', () {
    test('creates with relative coordinates', () {
      const h = HotspotModel(dx: 0.5, dy: 0.3);
      expect(h.dx, 0.5);
      expect(h.dy, 0.3);
      expect(h.shape, HotspotShape.circle);
      expect(h.color, Colors.red);
    });

    test('copyWith replaces supplied fields', () {
      const h = HotspotModel(dx: 0.2, dy: 0.4, color: Colors.blue);
      final updated = h.copyWith(dx: 0.9, color: Colors.green);
      expect(updated.dx, 0.9);
      expect(updated.dy, 0.4); // unchanged
      expect(updated.color, Colors.green);
    });

    test('JSON round-trip preserves values', () {
      const h = HotspotModel(
        dx: 0.25,
        dy: 0.75,
        shape: HotspotShape.rectangle,
        width: 0.15,
        height: 0.08,
        tooltip: 'Hello',
        color: Colors.blue,
        id: 'spot1',
      );
      final json = h.toJson();
      final restored = HotspotModel.fromJson(json);

      expect(restored.dx, h.dx);
      expect(restored.dy, h.dy);
      expect(restored.shape, HotspotShape.rectangle);
      expect(restored.width, h.width);
      expect(restored.height, h.height);
      expect(restored.tooltip, 'Hello');
      expect(restored.id, 'spot1');
    });

    test('fromJson defaults shape to circle when key absent', () {
      final h = HotspotModel.fromJson({'dx': 0.1, 'dy': 0.2});
      expect(h.shape, HotspotShape.circle);
    });

    test('fromJson parses polygon points', () {
      final h = HotspotModel.fromJson({
        'dx': 0.5,
        'dy': 0.5,
        'shape': 'polygon',
        'points': [
          {'x': 0.1, 'y': 0.2},
          {'x': 0.4, 'y': 0.1},
          {'x': 0.4, 'y': 0.5},
        ],
      });
      expect(h.shape, HotspotShape.polygon);
      expect(h.points.length, 3);
    });

    // ── Hit-testing ──────────────────────────────────────────────────────────

    test('hitTest circle – inside returns true', () {
      const h = HotspotModel(dx: 0.5, dy: 0.5, radius: 0.1);
      const imageRect = Rect.fromLTWH(0, 0, 400, 300);
      // Centre of the circle in screen coords is (200, 150).
      // Radius in pixels = 0.1 * 400 = 40.
      expect(h.hitTest(const Offset(200, 150), imageRect), isTrue);
      expect(h.hitTest(const Offset(200 + 39, 150), imageRect), isTrue);
    });

    test('hitTest circle – outside returns false', () {
      const h = HotspotModel(dx: 0.5, dy: 0.5, radius: 0.1);
      const imageRect = Rect.fromLTWH(0, 0, 400, 300);
      expect(h.hitTest(const Offset(200 + 41, 150), imageRect), isFalse);
    });

    test('hitTest rectangle – inside returns true', () {
      const h = HotspotModel(
        dx: 0.5,
        dy: 0.5,
        shape: HotspotShape.rectangle,
        width: 0.2,
        height: 0.2,
      );
      const imageRect = Rect.fromLTWH(0, 0, 400, 300);
      // Centre (200, 150); width=80, height=60 → spans [160,240]×[120,180].
      expect(h.hitTest(const Offset(200, 150), imageRect), isTrue);
      expect(h.hitTest(const Offset(161, 121), imageRect), isTrue);
      expect(h.hitTest(const Offset(159, 150), imageRect), isFalse);
    });

    test('hitTest polygon – inside returns true', () {
      final h = HotspotModel(
        dx: 0.5,
        dy: 0.5,
        shape: HotspotShape.polygon,
        points: const [
          Offset(0.25, 0.25),
          Offset(0.75, 0.25),
          Offset(0.75, 0.75),
          Offset(0.25, 0.75),
        ],
      );
      const imageRect = Rect.fromLTWH(0, 0, 400, 300);
      // Centre of polygon in screen coords ≈ (200, 150).
      expect(h.hitTest(const Offset(200, 150), imageRect), isTrue);
      expect(h.hitTest(const Offset(10, 10), imageRect), isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // CoordinateEngine unit tests
  // ─────────────────────────────────────────────────────────────────────────
  group('CoordinateEngine', () {
    test('fill – imageRect equals container', () {
      const engine = CoordinateEngine(fit: BoxFit.fill, imageAspectRatio: 2.0);
      const container = Size(400, 300);
      expect(engine.imageRect(container), Offset.zero & container);
    });

    test('no aspectRatio – imageRect equals container regardless of fit', () {
      const engine = CoordinateEngine(fit: BoxFit.contain);
      const container = Size(400, 300);
      expect(engine.imageRect(container), Offset.zero & container);
    });

    test('contain – wider container → pillarbox', () {
      // Image is 1:1; container is 400×300 (wider).
      const engine =
          CoordinateEngine(fit: BoxFit.contain, imageAspectRatio: 1.0);
      const container = Size(400, 300);
      final rect = engine.imageRect(container);
      // Image should be 300×300 centred horizontally.
      expect(rect.width, closeTo(300, 0.01));
      expect(rect.height, closeTo(300, 0.01));
      expect(rect.left, closeTo(50, 0.01));
      expect(rect.top, closeTo(0, 0.01));
    });

    test('contain – taller container → letterbox', () {
      // Image is 2:1; container is 200×300 (taller).
      const engine =
          CoordinateEngine(fit: BoxFit.contain, imageAspectRatio: 2.0);
      const container = Size(200, 300);
      final rect = engine.imageRect(container);
      // Image should be 200×100 centred vertically.
      expect(rect.width, closeTo(200, 0.01));
      expect(rect.height, closeTo(100, 0.01));
      expect(rect.top, closeTo(100, 0.01));
    });

    test('toScreenOffset maps (0.5, 0.5) to centre of imageRect', () {
      const engine = CoordinateEngine(fit: BoxFit.fill);
      const container = Size(400, 300);
      final offset = engine.toScreenOffset(
          dx: 0.5, dy: 0.5, containerSize: container);
      expect(offset, const Offset(200, 150));
    });

    test('toRelativeOffset is inverse of toScreenOffset', () {
      const engine = CoordinateEngine(fit: BoxFit.fill);
      const container = Size(400, 300);
      final screen = engine.toScreenOffset(
          dx: 0.3, dy: 0.7, containerSize: container);
      final rel = engine.toRelativeOffset(
          screenOffset: screen, containerSize: container);
      expect(rel.dx, closeTo(0.3, 1e-9));
      expect(rel.dy, closeTo(0.7, 1e-9));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ImageHotspot widget tests
  // ─────────────────────────────────────────────────────────────────────────
  group('ImageHotspot Widget', () {
    Widget buildApp(List<HotspotModel> hotspots,
        {bool showTooltip = true, BoxFit fit = BoxFit.cover}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: ImageHotspot(
              imagePath: 'assets/test_image.jpg',
              hotspots: hotspots,
              imageFit: fit,
              showTooltip: showTooltip,
            ),
          ),
        ),
      );
    }

    testWidgets('renders without hotspots', (tester) async {
      await tester.pumpWidget(buildApp([]));
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders with a single hotspot', (tester) async {
      await tester.pumpWidget(buildApp([
        const HotspotModel(dx: 0.5, dy: 0.5),
      ]));
      // CustomPaint is used for shape hotspots.
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders multiple hotspots', (tester) async {
      await tester.pumpWidget(buildApp([
        const HotspotModel(dx: 0.1, dy: 0.1),
        const HotspotModel(dx: 0.5, dy: 0.5),
        const HotspotModel(dx: 0.9, dy: 0.9),
      ]));
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('imageFit is applied correctly', (tester) async {
      await tester.pumpWidget(buildApp([], fit: BoxFit.contain));
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.contain);
    });

    testWidgets('onTap callback is called', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildApp([
        HotspotModel(
          dx: 0.5,
          dy: 0.5,
          onTap: () => tapped = true,
          radius: 0.15, // large enough to hit easily
        ),
      ]));

      // Find and tap the GestureDetector that wraps the shape tap target.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tooltip shown after hotspot tap', (tester) async {
      await tester.pumpWidget(buildApp([
        HotspotModel(
          dx: 0.5,
          dy: 0.5,
          tooltip: 'Test Tooltip',
          radius: 0.15,
          onTap: () {},
        ),
      ]));

      expect(find.text('Test Tooltip'), findsNothing);

      // Tap the shape hotspot tap-target GestureDetector.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.text('Test Tooltip'), findsOneWidget);
    });

    testWidgets('tooltip hidden when showTooltip is false', (tester) async {
      await tester.pumpWidget(buildApp(
        [
          HotspotModel(
            dx: 0.5,
            dy: 0.5,
            tooltip: 'Hidden Tooltip',
            radius: 0.15,
            onTap: () {},
          ),
        ],
        showTooltip: false,
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('Hidden Tooltip'), findsNothing);
    });

    testWidgets('icon hotspot renders custom icon', (tester) async {
      await tester.pumpWidget(buildApp([
        HotspotModel(
          dx: 0.5,
          dy: 0.5,
          icon: const Icon(Icons.star),
          onTap: () {},
        ),
      ]));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('InteractiveViewer present when enableZoom is true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: ImageHotspot(
              imagePath: 'assets/test_image.jpg',
              hotspots: const [],
              enableZoom: true,
            ),
          ),
        ),
      ));
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('InteractiveViewer absent when enableZoom is false',
        (tester) async {
      await tester.pumpWidget(buildApp([]));
      expect(find.byType(InteractiveViewer), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // HotspotEditor widget tests
  // ─────────────────────────────────────────────────────────────────────────
  group('HotspotEditor', () {
    testWidgets('renders with empty hotspots', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: HotspotEditor(
              imagePath: 'assets/test_image.jpg',
              initialHotspots: const [],
            ),
          ),
        ),
      ));
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('onHotspotsChanged called when hotspot added', (tester) async {
      List<HotspotModel>? updated;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: HotspotEditor(
              imagePath: 'assets/test_image.jpg',
              initialHotspots: const [],
              onHotspotsChanged: (list) => updated = list,
            ),
          ),
        ),
      ));

      // Tap on an empty area to add a hotspot.
      await tester.tapAt(const Offset(200, 150));
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.length, 1);
    });
  });
}

