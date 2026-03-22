import 'package:flutter/material.dart';

import '../engine/coordinate_engine.dart';
import '../models/hotspot_model.dart';
import 'hotspot_painter.dart';
import 'hotspot_tooltip.dart';

// ---------------------------------------------------------------------------
// ImageHotspot – main public widget
// ---------------------------------------------------------------------------

/// A widget that renders an image with interactive hotspots.
///
/// Hotspot positions are defined using **relative coordinates** (`0.0` – `1.0`)
/// via [HotspotModel.dx] and [HotspotModel.dy], making them responsive across
/// any screen size or image dimension.
///
/// ## Basic usage
///
/// ```dart
/// ImageHotspot(
///   imagePath: 'assets/map.jpg',
///   hotspots: [
///     HotspotModel(
///       dx: 0.5,
///       dy: 0.3,
///       tooltip: 'Centre',
///       onTap: () => print('tapped'),
///     ),
///   ],
/// )
/// ```
///
/// ## Zoom & pan
///
/// Set [enableZoom] to `true` to wrap the widget in an [InteractiveViewer].
/// Hotspots automatically stay aligned with the image while zooming and
/// panning.
///
/// ## Editor mode
///
/// Use [HotspotEditor] for an interactive editor that lets users add, drag,
/// and delete hotspots at runtime.
class ImageHotspot extends StatefulWidget {
  /// Path to the image asset (e.g. `'assets/map.jpg'`).
  ///
  /// Mutually exclusive with [imageProvider]; provide exactly one.
  final String? imagePath;

  /// Custom [ImageProvider] (e.g. [NetworkImage], [FileImage]).
  ///
  /// When set, [imagePath] is ignored.
  final ImageProvider? imageProvider;

  /// The hotspots to render on the image.
  final List<HotspotModel> hotspots;

  /// How the image should be inscribed into the available space.
  ///
  /// Defaults to [BoxFit.cover].
  final BoxFit imageFit;

  /// Width constraint for the image container.
  ///
  /// Defaults to [double.infinity] (fills available width).
  final double imageWidth;

  /// Height constraint for the image container.
  ///
  /// Defaults to [double.infinity] (fills available height).
  final double imageHeight;

  /// Whether to show a tooltip / popover when a hotspot is activated.
  ///
  /// Defaults to `true`.
  final bool showTooltip;

  /// Aspect ratio (width ÷ height) of the source image.
  ///
  /// Providing this enables accurate hotspot placement for [BoxFit.contain]
  /// and [BoxFit.cover] (letterbox / pillarbox compensation).  Leave `null`
  /// to treat the full container as the image area (correct for
  /// [BoxFit.fill]).
  final double? imageAspectRatio;

  /// Whether to wrap the widget in an [InteractiveViewer] for zoom & pan.
  ///
  /// Hotspots scale and translate with the image.  Defaults to `false`.
  final bool enableZoom;

  /// Minimum scale factor when [enableZoom] is `true`. Defaults to `0.5`.
  final double minScale;

  /// Maximum scale factor when [enableZoom] is `true`. Defaults to `4.0`.
  final double maxScale;

  /// Creates an [ImageHotspot] widget.
  ///
  /// Either [imagePath] or [imageProvider] must be provided.
  const ImageHotspot({
    super.key,
    this.imagePath,
    this.imageProvider,
    required this.hotspots,
    this.imageFit = BoxFit.cover,
    this.imageWidth = double.infinity,
    this.imageHeight = double.infinity,
    this.showTooltip = true,
    this.imageAspectRatio,
    this.enableZoom = false,
    this.minScale = 0.5,
    this.maxScale = 4.0,
  }) : assert(
          imagePath != null || imageProvider != null,
          'Provide either imagePath or imageProvider.',
        );

  @override
  State<ImageHotspot> createState() => _ImageHotspotState();
}

class _ImageHotspotState extends State<ImageHotspot> {
  HotspotModel? _activeHotspot;

  void _onHotspotTap(HotspotModel hotspot) {
    hotspot.onTap?.call();
    if (widget.showTooltip &&
        (hotspot.tooltip != null || hotspot.tooltipWidget != null)) {
      setState(() {
        _activeHotspot = _activeHotspot == hotspot ? null : hotspot;
      });
    }
  }

  void _dismissTooltip() {
    if (_activeHotspot != null) setState(() => _activeHotspot = null);
  }

  @override
  Widget build(BuildContext context) {
    final core = LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(
          widget.imageWidth.isInfinite
              ? constraints.maxWidth
              : widget.imageWidth,
          widget.imageHeight.isInfinite
              ? constraints.maxHeight
              : widget.imageHeight,
        );

        final engine = CoordinateEngine(
          fit: widget.imageFit,
          imageAspectRatio: widget.imageAspectRatio,
        );
        final imageRect = engine.imageRect(containerSize);

        return GestureDetector(
          onTap: _dismissTooltip,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            width: containerSize.width,
            height: containerSize.height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── Image ──────────────────────────────────────────────────
                RepaintBoundary(
                  child: SizedBox.expand(
                    child: _buildImage(),
                  ),
                ),

                // ── Shape hotspots (CustomPaint) ───────────────────────────
                RepaintBoundary(
                  child: CustomPaint(
                    size: containerSize,
                    painter: _MultiHotspotPainter(
                      hotspots: widget.hotspots
                          .where((h) => h.icon == null)
                          .toList(),
                      imageRect: imageRect,
                      activeHotspot: _activeHotspot,
                    ),
                  ),
                ),

                // ── Icon / interactive hotspot overlays ────────────────────
                ...widget.hotspots
                    .where((h) => h.icon != null)
                    .map((h) => _buildIconHotspot(h, engine, containerSize)),

                // ── Tap targets for shape hotspots ─────────────────────────
                ...widget.hotspots
                    .where((h) => h.icon == null)
                    .map((h) => _buildShapeHotspotTarget(h, engine, containerSize)),

                // ── Active tooltip ─────────────────────────────────────────
                if (widget.showTooltip && _activeHotspot != null)
                  _buildTooltip(_activeHotspot!, engine, containerSize),
              ],
            ),
          ),
        );
      },
    );

    if (widget.enableZoom) {
      return InteractiveViewer(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        child: core,
      );
    }
    return core;
  }

  // ---------------------------------------------------------------------------
  // Image builder
  // ---------------------------------------------------------------------------

  Widget _buildImage() {
    final provider =
        widget.imageProvider ?? AssetImage(widget.imagePath!) as ImageProvider;
    return Image(
      image: provider,
      fit: widget.imageFit,
      width: widget.imageWidth,
      height: widget.imageHeight,
    );
  }

  // ---------------------------------------------------------------------------
  // Shape hotspot tap target
  // ---------------------------------------------------------------------------

  Widget _buildShapeHotspotTarget(
    HotspotModel hotspot,
    CoordinateEngine engine,
    Size containerSize,
  ) {
    final center = engine.toScreenOffset(
      dx: hotspot.dx,
      dy: hotspot.dy,
      containerSize: containerSize,
    );

    // Determine the tap-target bounds for the shape.
    final imageRect = engine.imageRect(containerSize);
    double tapW, tapH;
    switch (hotspot.shape) {
      case HotspotShape.circle:
        final r = hotspot.radius * imageRect.width;
        tapW = tapH = r * 2;
      case HotspotShape.rectangle:
        tapW = hotspot.width * imageRect.width;
        tapH = hotspot.height * imageRect.height;
      case HotspotShape.polygon:
        // For polygons, cover the bounding box.
        if (hotspot.points.isEmpty) return const SizedBox.shrink();
        final xs = hotspot.points.map((p) => p.dx * imageRect.width);
        final ys = hotspot.points.map((p) => p.dy * imageRect.height);
        tapW = xs.reduce((a, b) => a > b ? a : b) -
            xs.reduce((a, b) => a < b ? a : b);
        tapH = ys.reduce((a, b) => a > b ? a : b) -
            ys.reduce((a, b) => a < b ? a : b);
    }

    return Positioned(
      left: center.dx - tapW / 2,
      top: center.dy - tapH / 2,
      width: tapW,
      height: tapH,
      child: RepaintBoundary(
        child: _HotspotInteraction(
          hotspot: hotspot,
          onTap: () => _onHotspotTap(hotspot),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Icon hotspot overlay
  // ---------------------------------------------------------------------------

  Widget _buildIconHotspot(
    HotspotModel hotspot,
    CoordinateEngine engine,
    Size containerSize,
  ) {
    final center = engine.toScreenOffset(
      dx: hotspot.dx,
      dy: hotspot.dy,
      containerSize: containerSize,
    );

    return Positioned(
      left: center.dx,
      top: center.dy,
      child: RepaintBoundary(
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: _HotspotInteraction(
            hotspot: hotspot,
            onTap: () => _onHotspotTap(hotspot),
            child: hotspot.icon!,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tooltip
  // ---------------------------------------------------------------------------

  Widget _buildTooltip(
    HotspotModel hotspot,
    CoordinateEngine engine,
    Size containerSize,
  ) {
    final center = engine.toScreenOffset(
      dx: hotspot.dx,
      dy: hotspot.dy,
      containerSize: containerSize,
    );
    final imageRect = engine.imageRect(containerSize);
    final radius = hotspot.radius * imageRect.width;

    return HotspotTooltip(
      hotspot: hotspot,
      hotspotCenter: center,
      hotspotRadius: radius,
      boundary: Offset.zero & containerSize,
      onDismiss: _dismissTooltip,
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-hotspot CustomPainter
// ---------------------------------------------------------------------------

class _MultiHotspotPainter extends CustomPainter {
  final List<HotspotModel> hotspots;
  final Rect imageRect;
  final HotspotModel? activeHotspot;

  const _MultiHotspotPainter({
    required this.hotspots,
    required this.imageRect,
    this.activeHotspot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final hotspot in hotspots) {
      HotspotPainter(
        hotspot: hotspot,
        imageRect: imageRect,
        isActive: hotspot == activeHotspot,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_MultiHotspotPainter old) =>
      old.hotspots != hotspots ||
      old.imageRect != imageRect ||
      old.activeHotspot != activeHotspot;
}

// ---------------------------------------------------------------------------
// Interaction wrapper (tap + long-press + hover)
// ---------------------------------------------------------------------------

class _HotspotInteraction extends StatefulWidget {
  final HotspotModel hotspot;
  final VoidCallback onTap;
  final Widget child;

  const _HotspotInteraction({
    required this.hotspot,
    required this.onTap,
    required this.child,
  });

  @override
  State<_HotspotInteraction> createState() => _HotspotInteractionState();
}

class _HotspotInteractionState extends State<_HotspotInteraction> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Widget result = GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.hotspot.onLongPress,
      child: widget.child,
    );

    result = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovering = true);
        widget.hotspot.onHover?.call(true);
      },
      onExit: (_) {
        setState(() => _hovering = false);
        widget.hotspot.onHover?.call(false);
      },
      child: result,
    );

    return AnimatedScale(
      scale: _hovering ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: result,
    );
  }
}
