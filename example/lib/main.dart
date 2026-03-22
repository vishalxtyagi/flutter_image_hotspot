import 'package:flutter/material.dart';
import 'package:image_hotspot/image_hotspot.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Hotspot Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const _DemoHome(),
    );
  }
}

class _DemoHome extends StatefulWidget {
  const _DemoHome();

  @override
  State<_DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<_DemoHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Hotspot Demo'),
        bottom: TabBar(
          onTap: (i) => setState(() => _tab = i),
          tabs: const [
            Tab(text: 'Viewer'),
            Tab(text: 'Zoom'),
            Tab(text: 'JSON'),
            Tab(text: 'Editor'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _ViewerTab(),
          _ZoomTab(),
          _JsonTab(),
          _EditorTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 – Basic viewer with mixed shapes
// ─────────────────────────────────────────────────────────────────────────────
class _ViewerTab extends StatelessWidget {
  const _ViewerTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageHotspot(
        imagePath: 'assets/sample_image.jpg',
        imageWidth: 360,
        imageHeight: 240,
        imageFit: BoxFit.cover,
        hotspots: [
          HotspotModel(
            dx: 0.15,
            dy: 0.25,
            shape: HotspotShape.circle,
            radius: 0.06,
            color: Colors.blue,
            tooltip: 'Circle hotspot',
            onTap: () => _msg(context, 'Circle tapped'),
          ),
          HotspotModel(
            dx: 0.5,
            dy: 0.5,
            shape: HotspotShape.rectangle,
            width: 0.18,
            height: 0.18,
            color: Colors.green,
            tooltipWidget: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Custom widget\ntooltip!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            onTap: () => _msg(context, 'Rectangle tapped'),
          ),
          HotspotModel(
            dx: 0.82,
            dy: 0.3,
            icon: const Icon(Icons.star, color: Colors.yellow, size: 32),
            tooltip: 'Icon hotspot',
            onTap: () => _msg(context, 'Star tapped'),
            onHover: (entering) =>
                debugPrint('Star hover: ${entering ? "enter" : "exit"}'),
          ),
          HotspotModel(
            dx: 0.5,
            dy: 0.82,
            shape: HotspotShape.polygon,
            points: const [
              Offset(0.38, 0.72),
              Offset(0.62, 0.72),
              Offset(0.68, 0.90),
              Offset(0.32, 0.90),
            ],
            color: Colors.orange,
            tooltip: 'Polygon hotspot',
            onTap: () => _msg(context, 'Polygon tapped'),
            onLongPress: () => _msg(context, 'Polygon long-pressed'),
          ),
        ],
      ),
    );
  }

  static void _msg(BuildContext context, String text) =>
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(text)));
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 – Zoom & pan
// ─────────────────────────────────────────────────────────────────────────────
class _ZoomTab extends StatelessWidget {
  const _ZoomTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ImageHotspot(
        imagePath: 'assets/sample_image.jpg',
        imageWidth: 360,
        imageHeight: 240,
        imageFit: BoxFit.cover,
        enableZoom: true,
        minScale: 0.5,
        maxScale: 5.0,
        hotspots: [
          HotspotModel(
            dx: 0.3,
            dy: 0.4,
            radius: 0.05,
            color: Colors.purple,
            tooltip: 'Zoom & pan: hotspots track the image',
            onTap: () {},
          ),
          HotspotModel(
            dx: 0.7,
            dy: 0.6,
            radius: 0.05,
            color: Colors.teal,
            tooltip: 'Pinch to zoom!',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 – JSON-driven hotspots
// ─────────────────────────────────────────────────────────────────────────────
class _JsonTab extends StatelessWidget {
  const _JsonTab();

  // Simulated JSON payload (in a real app this would come from an API).
  static final List<Map<String, dynamic>> _json = [
    {
      'dx': 0.2,
      'dy': 0.3,
      'shape': 'circle',
      'radius': 0.06,
      'color': 0xFF2196F3,
      'tooltip': 'Loaded from JSON #1',
      'id': 'json_1',
    },
    {
      'dx': 0.65,
      'dy': 0.55,
      'shape': 'rectangle',
      'width': 0.15,
      'height': 0.12,
      'color': 0xFF4CAF50,
      'tooltip': 'Loaded from JSON #2',
      'id': 'json_2',
    },
    {
      'dx': 0.85,
      'dy': 0.2,
      'shape': 'circle',
      'radius': 0.04,
      'color': 0xFFF44336,
      'tooltip': 'Loaded from JSON #3',
      'id': 'json_3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hotspots = _json.map(HotspotModel.fromJson).toList();

    return Center(
      child: ImageHotspot(
        imagePath: 'assets/sample_image.jpg',
        imageWidth: 360,
        imageHeight: 240,
        imageFit: BoxFit.cover,
        hotspots: hotspots,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 – Editor mode
// ─────────────────────────────────────────────────────────────────────────────
class _EditorTab extends StatefulWidget {
  const _EditorTab();

  @override
  State<_EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends State<_EditorTab> {
  List<HotspotModel> _hotspots = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: HotspotEditor(
            imagePath: 'assets/sample_image.jpg',
            imageFit: BoxFit.cover,
            defaultColor: Colors.deepPurple,
            defaultRadius: 0.05,
            initialHotspots: _hotspots,
            onHotspotsChanged: (list) => setState(() => _hotspots = list),
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_hotspots.length} hotspot(s) placed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                onPressed: _hotspots.isEmpty
                    ? null
                    : () => setState(() => _hotspots = []),
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Clear all'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

