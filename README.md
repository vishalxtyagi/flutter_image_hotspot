# Image Hotspot

`image_hotspot` is a Flutter package that allows you to create interactive hotspots on images. It provides a simple way to define clickable areas on images that trigger custom actions when tapped.

## Features

- Define multiple hotspots on an image.
- Customizable hotspot positions.
- Trigger actions when hotspots are tapped.

## Getting Started

### Installation

Add `image_hotspot` to your `pubspec.yaml`:

```yaml
dependencies:
  image_hotspot: ^0.1.0

```

### Usage

```dart
import 'package:flutter/material.dart';
import 'package:image_hotspot/image_hotspot.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Image Hotspot Example')),
        body: Center(
          child: ImageHotspot(
            imagePath: 'assets/sample_image.jpg',
            imageWidth: 300,
            imageHeight: 200,
            imageFit: BoxFit.cover,
            showTooltip: true,
            hotspots: [
              Hotspot(
                x: 10,
                y: 20,
                onTap: () => print('Hotspot 1 tapped'),
                tooltip: 'This is hotspot 1',
                color: Colors.blue,
                size: 30,
              ),
              Hotspot(
                x: 200,
                y: 150,
                onTap: () => print('Hotspot 2 tapped'),
                // tooltip: 'This is hotspot 2',
                icon: Icon(Icons.star, color: Colors.yellow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Example

Check out the [example](https://github.com/vishalxtyagi/image_hotspot/tree/main/example) directory for a complete sample app.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
