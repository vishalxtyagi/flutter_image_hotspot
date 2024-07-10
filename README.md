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
  image_hotspot: ^0.0.1

```

### Usage

```dart
import 'package:flutter/material.dart';
import 'package:image_hotspot/image_hotspot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Image Hotspot Example')),
        body: Center(
          child: ImageHotspot(
            imagePath: 'assets/sample_image.jpg',
            hotspots: [
              Hotspot(
                x: 50.0,
                y: 100.0,
                onTap: () {
                  print('Hotspot 1 tapped!');
                },
              ),
              Hotspot(
                x: 150.0,
                y: 200.0,
                onTap: () {
                  print('Hotspot 2 tapped!');
                },
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
