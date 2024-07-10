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
