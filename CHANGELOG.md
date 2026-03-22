# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- github actions to automatically publish the latest version -->

## [0.2.0] - 2026-03-22

### Added

- **Responsive coordinate system** — hotspot positions are now relative
  values (`0.0` – `1.0`) via `HotspotModel.dx` / `dy`, replacing absolute
  pixel coordinates so hotspots scale correctly across any screen size.
- **`HotspotModel`** — new primary data class with full null-safety, Dart 3
  compatibility, `copyWith`, and JSON serialisation (`fromJson` / `toJson`).
- **`HotspotShape` enum** — `circle`, `rectangle`, and `polygon` shapes.
- **`CoordinateEngine`** — layout engine that maps relative coordinates to
  screen positions, correctly accounting for all `BoxFit` modes and optional
  `imageAspectRatio`.
- **`HotspotPainter`** — `CustomPainter` that renders circle, rectangle, and
  polygon hotspot shapes with active-state highlighting.
- **`HotspotTooltip`** — animated, smart-positioning popover that accepts both
  plain-text (`tooltip`) and arbitrary custom widgets (`tooltipWidget`), and
  stays within the image boundary.
- **`ImageHotspot`** widget rebuilt with:
  - `LayoutBuilder` for fully responsive layout.
  - `RepaintBoundary` wrapping image and hotspot layers for performance.
  - Optional `InteractiveViewer` integration (`enableZoom`, `minScale`,
    `maxScale`) — hotspots remain perfectly aligned while zooming and panning.
  - Tap, long-press, and hover (web / desktop) interaction support per hotspot.
  - `imageProvider` parameter for network / file images.
- **`HotspotEditor`** — editor mode widget that lets users add hotspots by
  tapping, drag to reposition, select and delete, with an optional custom
  properties panel via `propertiesPanelBuilder`.
- Legacy `Hotspot` class retained with a `@Deprecated` annotation and a
  migration guide in its doc comment.

### Changed

- Library exports reorganised into `models/`, `engine/`, `widgets/`, and
  `editor/` sub-directories following clean-architecture conventions.
- `ImageHotspot` now accepts `List<HotspotModel>` (was `List<Hotspot>`).
- Default `imageFit` remains `BoxFit.cover`; all other defaults are unchanged.

### Deprecated

- `Hotspot` — use `HotspotModel` with relative coordinates instead.

## [0.1.1] - 2024-07-11

### Added

- GitHub workflow to automate the publishing of packages on pub.dev

## [0.1.0] - 2024-07-11

### Added
- Tooltip functionality for hotspots
- Custom icon support for hotspots
- Comprehensive unit tests for the ImageHotspot widget
- New customization options for image fitting (imageFit, imageWidth, imageHeight)

### Changed
- Refactored ImageHotspot widget for improved customization and flexibility
- Updated example app to showcase new features and customization options

### Improved
- Enhanced documentation in README with detailed usage instructions and customization options

## [0.0.1] - 2024-07-10

### Added
- Basic functionality for creating image hotspots
- Customizable hotspot positions
- Actions triggered on hotspot taps
- Initial documentation including README and LICENSE
- Example project demonstrating how to use the `ImageHotspot` widget
