<p align="center">
  <img src="https://shieldcn.dev/header/gradient.svg?title=image_hotspot&subtitle=Add+interactive+responsive+hotspots+to+any+Flutter+image+%E2%80%94+in+minutes&logo=flutter&theme=dark" alt="image_hotspot Flutter Package" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/image_hotspot"><img src="https://shieldcn.dev/pub/v/image_hotspot.svg" alt="pub version" /></a>
  <a href="https://github.com/vishalxtyagi/flutter_image_hotspot/stargazers"><img src="https://shieldcn.dev/github/stars/vishalxtyagi/flutter_image_hotspot.svg" alt="Stars" /></a>
  <img src="https://shieldcn.dev/github/last-commit/vishalxtyagi/flutter_image_hotspot.svg" alt="Last Commit" />
  <img src="https://shieldcn.dev/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-02569B.svg?logo=flutter" alt="Platforms" />
  <img src="https://shieldcn.dev/badge/status-working-22c55e.svg" alt="Status: Working" />
</p>

> **Showcase:** [vt-image-hotspot-flutter-package.pages.dev](https://vt-image-hotspot-flutter-package.pages.dev) · **pub.dev:** [image_hotspot](https://pub.dev/packages/image_hotspot)

---

Flutter package for adding interactive, responsive hotspots to any image. Define clickable regions with relative coordinates — they scale correctly across any screen size or `BoxFit` mode. Ships with tooltip overlays, custom shapes, and an in-app editor so non-engineers can position hotspots without redeploying.

## Why it exists

Building tappable regions on images — floor plan clickable rooms, product photo shoppable callouts, anatomy diagram labelled parts, map points of interest — usually means hand-rolling pixel math that breaks the moment screen size or `BoxFit` changes.

`image_hotspot` replaces that with:
- Relative coordinate system (0.0–1.0) that adapts to any image size
- Custom shape system (circle, rectangle, polygon)
- Smart tooltips that flip to stay on-screen
- An in-app editor so non-engineers can place hotspots without redeploy — then export the result as JSON

## Install

```yaml
# pubspec.yaml
dependencies:
  image_hotspot: ^latest
```

## Quick start

```dart
ImageHotspot(
  image: AssetImage('assets/floor_plan.png'),
  hotspots: [
    Hotspot(
      x: 0.35,        // relative X (0.0 = left, 1.0 = right)
      y: 0.60,        // relative Y (0.0 = top, 1.0 = bottom)
      label: 'Room A',
      onTap: () => showRoomDetails(),
    ),
  ],
)
```

## Use cases

- Floor plan room navigation
- Product image shoppable callouts
- Anatomy / medical diagram labels
- Interactive maps
- Photo annotation tools

## What's next

- Hotspot animations (pulse, glow)
- Accessibility — screen reader labels per hotspot
- Export hotspot JSON from in-app editor
- Drag-to-reposition in view mode

---

<p align="center">
  Built by <a href="https://vishalxtyagi.in">Vishal Tyagi</a> ·
  <a href="https://pub.dev/packages/image_hotspot">pub.dev</a> ·
  <a href="https://vt-image-hotspot-flutter-package.pages.dev">Showcase</a>
</p>
