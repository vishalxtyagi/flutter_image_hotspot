library image_hotspot;
import 'package:flutter/material.dart';


class ImageHotspot extends StatelessWidget {
  final String imagePath;
  final List<Hotspot> hotspots;

  const ImageHotspot({super.key, required this.imagePath, required this.hotspots});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(imagePath),
        ...hotspots.map((hotspot) {
          return Positioned(
            left: hotspot.x,
            top: hotspot.y,
            child: GestureDetector(
              onTap: hotspot.onTap,
              child: Icon(
                Icons.circle,
                color: Colors.red.withOpacity(0.5),
                size: 24.0,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class Hotspot {
  final double x;
  final double y;
  final VoidCallback onTap;

  Hotspot({required this.x, required this.y, required this.onTap});
}