import 'package:flutter_test/flutter_test.dart';

import 'package:image_hotspot/image_hotspot.dart';

void main() {
  ImageHotspot imageHotspot = ImageHotspot(
      imagePath: 'assets/images/sample.jpg',
      hotspots: [
        Hotspot(
          x: 100.0,
          y: 100.0,
          onTap: () {
            print('Hotspot tapped');
          }
        )
      ]
    );

  group('ImageHotspot', () {
    test('ImageHotspot has imagePath', () {
      expect(imageHotspot.imagePath, 'assets/images/sample.jpg');
    });

    test('ImageHotspot has hotspots', () {
      expect(imageHotspot.hotspots.length, 1);
    });
  });

  group('Hotspot', () {
    test('Hotspot has x', () {
      expect(imageHotspot.hotspots[0].x, 100.0);
    });

    test('Hotspot has y', () {
      expect(imageHotspot.hotspots[0].y, 100.0);
    });

    test('Hotspot has onTap', () {
      expect(imageHotspot.hotspots[0].onTap, isNotNull);
    });
  });

}
