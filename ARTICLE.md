# 🖼️ I Built an Interactive Image Hotspot Engine for Flutter — Here's What I Learned

> *Cross-posted to [dev.to](https://dev.to) and [LinkedIn](https://linkedin.com)*

---

## The Problem Nobody Talks About

You're building a Flutter app — maybe a virtual tour, a product catalogue, an
interactive map, or an e-learning module.  You need clickable areas on an image.

You reach for a quick solution: stack a `GestureDetector` on top of a
`Positioned` widget.  You hard-code `left: 90, top: 60`.  It looks great on
your test device.

Then QA runs it on a tablet.

```
Expected:          Actual (tablet):
 ┌──────────┐       ┌──────────────────┐
 │   [●]    │       │                  │
 │          │       │     [●]          │ ← drifted 😬
 └──────────┘       └──────────────────┘
```

The hotspot has drifted — because you're using **absolute pixel coordinates**
that don't scale with the image.

This is the problem `image_hotspot` solves.

---

## The Insight: Relative Coordinates

The fix is elegant.  Instead of saying "put the hotspot at pixel (90, 60)",
say "put the hotspot at **45% from the left, 30% from the top**":

```dart
// BEFORE — breaks on different screens
Hotspot(x: 90, y: 60)

// AFTER — works everywhere
HotspotModel(dx: 0.45, dy: 0.30)
```

A value of `0.0` means "left/top edge" and `1.0` means "right/bottom edge".
The `CoordinateEngine` translates these relative values to real screen offsets
at paint time, accounting for the image's actual rendered rectangle — even when
it's letterboxed or pillarboxed by `BoxFit.contain`.

---

## What the Package Does

`image_hotspot` is a production-grade Flutter package that turns any image into
an interactive surface.  Here's the feature set:

### 🔷 Three Shape Types

```
  ●  circle      ■  rectangle      ⬡  polygon
```

Every shape is defined in relative coordinates, so it scales correctly with
the image regardless of screen size.

### 💬 Smart Tooltips

Popovers that **automatically position themselves** to stay within the image
boundary — above, below, left, or right — depending on where the hotspot sits.
You can pass plain text or any Flutter widget.

### 🔍 Zoom & Pan

One flag enables `InteractiveViewer` zoom/pan.  Hotspots remain perfectly
aligned with image pixels at any zoom level, because the coordinate math runs
against the widget's layout geometry rather than storing absolute positions.

### 📦 JSON-Driven Loading

```json
{ "dx": 0.45, "dy": 0.30, "shape": "circle", "tooltip": "Paris" }
```

Load hotspots from an API, a database, or a local config file — no code
changes required.

### 🖊️ Built-in Editor

`HotspotEditor` is a ready-to-use UI for adding, repositioning, and deleting
hotspots at runtime.  Perfect for CMS tools or user-generated content flows.

---

## Architecture Deep Dive

```
ImageHotspot widget
       │
       ├──▶  LayoutBuilder       — knows the rendered size
       │
       ├──▶  CoordinateEngine    — maps (dx,dy) → screen Offset
       │                           handles all BoxFit modes
       │
       ├──▶  CustomPaint         — draws shapes efficiently
       │     HotspotPainter
       │
       └──▶  GestureDetector     — tap / long-press / hover
             HotspotTooltip      — smart popover
```

The layers are deliberately decoupled.  The `CoordinateEngine` is a pure Dart
class — no widgets, no `BuildContext` — which makes it independently testable.

---

## The Letterbox Problem (and How We Solved It)

`BoxFit.contain` is where most hotspot libraries fall apart.  When the image
aspect ratio doesn't match the container, Flutter adds letterboxes (horizontal
bars) or pillarboxes (vertical bars):

```
Container 400×300 · Image 16:9 (wider than container):
┌────────────────────────────────────────────┐
│                                            │  ← letterbox
│╔══════════════════════════════════════════╗│
│║               image area                 ║│
│╚══════════════════════════════════════════╝│
│                                            │  ← letterbox
└────────────────────────────────────────────┘
```

If you map `dy: 0.5` to 50% of the **container** height, the hotspot lands in
the letterbox — not on the image.  The `CoordinateEngine` computes the exact
rendered image `Rect` first, then maps coordinates within that rect:

```dart
ImageHotspot(
  imageFit: BoxFit.contain,
  imageAspectRatio: 16 / 9,   // tell the engine the image's aspect ratio
  hotspots: [...],
)
```

---

## Performance Choices

- **`RepaintBoundary`** wraps the image layer and the hotspot layer separately.
  Tapping a hotspot (which triggers a repaint of the hotspot layer) doesn't
  cause the image to repaint.

- **`CustomPainter`** renders all shapes in a single pass.  No widget tree
  overhead for each hotspot shape.

- **`InteractiveViewer`** — when zoom is enabled, the hotspot positions are
  calculated in the widget's *local* coordinate space, not the viewport's.
  This means the math is correct at any zoom level without any extra work.

---

## What I'd Do Differently

A few things I wish I'd done from the start:

1. **Make `imageAspectRatio` mandatory** when `BoxFit.contain` is used.
   Currently it's optional — but without it, letterbox compensation is
   silently skipped.

2. **Add a `HotspotController`** to allow programmatic control (clear all,
   add batch, serialise to JSON) without relying on `setState`.

3. **Provide a `HotspotLayer`** widget that renders hotspots independently
   of the image, so it can overlay a `CachedNetworkImage` or a `Hero`.

---

## Getting Started

```yaml
# pubspec.yaml
dependencies:
  image_hotspot: ^0.2.0
```

```dart
import 'package:image_hotspot/image_hotspot.dart';

ImageHotspot(
  imagePath: 'assets/map.jpg',
  hotspots: [
    HotspotModel(
      dx: 0.5,
      dy: 0.3,
      tooltip: 'You are here',
      onTap: () => Navigator.push(context, ...),
    ),
  ],
)
```

Full example app with four demo tabs lives in the
[`example/`](https://github.com/vishalxtyagi/flutter_image_hotspot/tree/main/example)
directory.

---

## Wrapping Up

The core insight is simple: **relative coordinates beat absolute pixels**,
every time.  Everything else — shapes, tooltips, zoom, JSON, editor mode —
is built on top of that foundation.

If you're building interactive image experiences in Flutter, give
[`image_hotspot`](https://pub.dev/packages/image_hotspot) a try.  Issues and
PRs are welcome on
[GitHub](https://github.com/vishalxtyagi/flutter_image_hotspot).

---

*Built with Flutter 3.x · Dart 3 · Clean Architecture*
