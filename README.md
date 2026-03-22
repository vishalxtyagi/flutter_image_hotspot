# Image Hotspot

`image_hotspot` is a production-grade, highly extensible **interactive image
engine** for Flutter.  It lets you place responsive hotspots on any image with
support for multiple shapes, zoom & pan, custom tooltips, JSON-driven loading,
and a built-in editor mode.

---

## Features

| Feature | Details |
|---|---|
| **Responsive coordinates** | Positions are relative values (`0.0` – `1.0`) — hotspots scale correctly on every screen size |
| **Multiple shapes** | Circle, rectangle, and polygon (custom shape) |
| **Rich interactions** | Tap, long-press, and hover (web / desktop) per hotspot |
| **Smart tooltip / popover** | Plain text *or* any custom widget; auto-positioned to stay within bounds |
| **Zoom & pan** | Opt-in `InteractiveViewer` wrapper — hotspots stay aligned while zooming |
| **JSON-driven** | Load hotspots from JSON with `HotspotModel.fromJson` |
| **Editor mode** | `HotspotEditor` lets users add, drag, and delete hotspots at runtime |
| **Performance** | `RepaintBoundary` isolation, `CustomPaint` for shape rendering |
| **Clean architecture** | `models` / `engine` / `widgets` / `editor` layers |

---

## Installation

```yaml
dependencies:
  image_hotspot: ^0.2.0
```

---

## Quick start

```dart
import 'package:image_hotspot/image_hotspot.dart';

ImageHotspot(
  imagePath: 'assets/map.jpg',
  hotspots: [
    HotspotModel(
      dx: 0.5,   // 50 % from the left
      dy: 0.3,   // 30 % from the top
      tooltip: 'Centre-top',
      onTap: () => print('tapped'),
    ),
  ],
)
```

---

## Hotspot shapes

```dart
// Circle (default)
HotspotModel(dx: 0.2, dy: 0.3, shape: HotspotShape.circle, radius: 0.05)

// Rectangle
HotspotModel(
  dx: 0.5, dy: 0.5,
  shape: HotspotShape.rectangle,
  width: 0.15, height: 0.10,
)

// Polygon
HotspotModel(
  dx: 0.7, dy: 0.7,
  shape: HotspotShape.polygon,
  points: const [
    Offset(0.60, 0.60), Offset(0.80, 0.60),
    Offset(0.85, 0.80), Offset(0.55, 0.80),
  ],
)
```

---

## Custom icon

```dart
HotspotModel(
  dx: 0.8, dy: 0.2,
  icon: const Icon(Icons.star, color: Colors.yellow, size: 32),
  tooltip: 'Icon hotspot',
  onTap: () {},
)
```

---

## Custom tooltip widget

```dart
HotspotModel(
  dx: 0.5, dy: 0.5,
  tooltipWidget: Padding(
    padding: const EdgeInsets.all(12),
    child: Text('Rich content here',
        style: const TextStyle(color: Colors.white)),
  ),
  onTap: () {},
)
```

---

## Interactions

```dart
HotspotModel(
  dx: 0.4, dy: 0.6,
  onTap: () => print('tapped'),
  onLongPress: () => print('long-pressed'),
  onHover: (entering) => print(entering ? 'entered' : 'exited'),
)
```

---

## Zoom & pan

```dart
ImageHotspot(
  imagePath: 'assets/map.jpg',
  enableZoom: true,
  minScale: 0.5,
  maxScale: 5.0,
  hotspots: [ ... ],
)
```

---

## JSON-driven hotspots

```dart
final List<Map<String, dynamic>> json = await fetchFromApi();
final hotspots = json.map(HotspotModel.fromJson).toList();

ImageHotspot(imagePath: 'assets/map.jpg', hotspots: hotspots)
```

JSON schema:

```json
{
  "dx": 0.5,
  "dy": 0.3,
  "shape": "circle",
  "radius": 0.05,
  "color": 4294901760,
  "tooltip": "Hello",
  "id": "spot1"
}
```

---

## Editor mode

```dart
HotspotEditor(
  imagePath: 'assets/map.jpg',
  initialHotspots: const [],
  onHotspotsChanged: (list) {
    // Persist or use the updated list.
    setState(() => _hotspots = list);
  },
)
```

Interactions in editor mode:
* **Tap on empty area** → add a new hotspot
* **Drag a hotspot** → reposition it
* **Tap a hotspot** → select it (shows delete button)
* **✕ button** → delete the selected hotspot

---

## Accurate positioning for `BoxFit.contain`

When your image uses `BoxFit.contain` and may be letterboxed / pillarboxed,
provide `imageAspectRatio` so the engine can compute the exact rendered rect:

```dart
ImageHotspot(
  imagePath: 'assets/map.jpg',
  imageFit: BoxFit.contain,
  imageAspectRatio: 16 / 9,  // width ÷ height of your image
  hotspots: [ ... ],
)
```

---

## Network images

```dart
ImageHotspot(
  imageProvider: const NetworkImage('https://example.com/map.jpg'),
  hotspots: [ ... ],
)
```

---

## Migrating from 0.1.x

| Old (0.1.x) | New (0.2.x) |
|---|---|
| `Hotspot(x: 90, y: 60, ...)` | `HotspotModel(dx: 0.3, dy: 0.3, ...)` |
| `imagePath: 'path'` | unchanged |
| `size: 30` (pixels) | `radius: 0.05` (fraction of image width) |

---

## Example

See the [example](https://github.com/vishalxtyagi/image_hotspot/tree/main/example)
directory for a full sample app demonstrating all features.

---

## License

MIT — see the [LICENSE](LICENSE) file for details.

