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
