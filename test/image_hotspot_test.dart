import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_hotspot/image_hotspot.dart';

void main() {
  group('ImageHotspot Widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(x: 100, y: 100, onTap: () {}),
            ],
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('renders multiple hotspots', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(x: 100, y: 100, onTap: () {}),
              Hotspot(x: 200, y: 200, onTap: () {}),
              Hotspot(x: 300, y: 300, onTap: () {}),
            ],
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(3));
    });

    testWidgets('applies image fit correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            imageFit: BoxFit.cover,
            hotspots: [
              Hotspot(x: 100, y: 100, onTap: () {}),
            ],
          ),
        ),
      );

      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, equals(BoxFit.cover));
    });
  });

  group('Hotspot Functionality', () {
    testWidgets('onTap callback is called', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(x: 100, y: 100, onTap: () => tapped = true),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('tooltip is shown when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(x: 100, y: 100, onTap: () {}, tooltip: 'Test Tooltip'),
            ],
          ),
        ),
      );

      expect(find.text('Test Tooltip'), findsNothing);
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('Test Tooltip'), findsOneWidget);
    });
  });

  group('Hotspot Customization', () {
    testWidgets('custom icon is rendered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(
                x: 100,
                y: 100,
                onTap: () {},
                icon: const Icon(Icons.star),
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('color and size are applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageHotspot(
            imagePath: 'assets/test_image.jpg',
            hotspots: [
              Hotspot(
                x: 100,
                y: 100,
                onTap: () {},
                color: Colors.blue,
                size: 40,
              ),
            ],
          ),
        ),
      );

      final Container hotspotContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      );

      expect(hotspotContainer.decoration, isA<BoxDecoration>());
      final BoxDecoration decoration =
          hotspotContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue.withOpacity(0.5)));
      expect(hotspotContainer.constraints!.minWidth, equals(40));
      expect(hotspotContainer.constraints!.minHeight, equals(40));
    });
  });
}
