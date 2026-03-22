import 'package:flutter/widgets.dart';

/// Computes layout geometry for the [ImageHotspot] rendering engine.
///
/// The engine maps **relative hotspot coordinates** (`0.0` – `1.0`) to
/// absolute screen [Offset]s, taking into account the [BoxFit] applied to
/// the image and the container dimensions.
class CoordinateEngine {
  /// The [BoxFit] used to render the image inside its container.
  final BoxFit fit;

  /// The aspect ratio (width ÷ height) of the source image.
  ///
  /// When provided, the engine can accurately compute the rendered image rect
  /// for [BoxFit.contain] and [BoxFit.cover].  If `null`, the engine falls
  /// back to treating the full container as the image area (correct for
  /// [BoxFit.fill] and [BoxFit.fitWidth] / [BoxFit.fitHeight] when the image
  /// fills the container).
  final double? imageAspectRatio;

  /// Creates a [CoordinateEngine].
  const CoordinateEngine({
    this.fit = BoxFit.cover,
    this.imageAspectRatio,
  });

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [Rect] that the rendered image occupies within [containerSize].
  ///
  /// When [imageAspectRatio] is `null`, the full container rect is returned
  /// (a safe default for [BoxFit.cover] and [BoxFit.fill]).
  Rect imageRect(Size containerSize) {
    if (imageAspectRatio == null) {
      return Offset.zero & containerSize;
    }
    return _computeImageRect(containerSize, imageAspectRatio!);
  }

  /// Maps a relative coordinate pair ([dx], [dy]) to an absolute screen
  /// [Offset] inside [containerSize].
  Offset toScreenOffset({
    required double dx,
    required double dy,
    required Size containerSize,
  }) {
    final rect = imageRect(containerSize);
    return Offset(
      rect.left + dx * rect.width,
      rect.top + dy * rect.height,
    );
  }

  /// Maps an absolute screen [Offset] back to relative coordinates `(dx, dy)`
  /// inside [containerSize].
  ///
  /// The returned [Offset] values are clamped to `[0.0, 1.0]`.
  Offset toRelativeOffset({
    required Offset screenOffset,
    required Size containerSize,
  }) {
    final rect = imageRect(containerSize);
    if (rect.isEmpty) return Offset.zero;
    return Offset(
      ((screenOffset.dx - rect.left) / rect.width).clamp(0.0, 1.0),
      ((screenOffset.dy - rect.top) / rect.height).clamp(0.0, 1.0),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Rect _computeImageRect(Size container, double aspectRatio) {
    final containerAspect = container.width / container.height;

    switch (fit) {
      case BoxFit.contain:
      case BoxFit.scaleDown:
        // Letterbox: image fits entirely within the container.
        if (containerAspect > aspectRatio) {
          // Container is wider → pillarbox (bars on left / right).
          final imageHeight = container.height;
          final imageWidth = imageHeight * aspectRatio;
          final left = (container.width - imageWidth) / 2;
          return Rect.fromLTWH(left, 0, imageWidth, imageHeight);
        } else {
          // Container is taller → letterbox (bars on top / bottom).
          final imageWidth = container.width;
          final imageHeight = imageWidth / aspectRatio;
          final top = (container.height - imageHeight) / 2;
          return Rect.fromLTWH(0, top, imageWidth, imageHeight);
        }

      case BoxFit.cover:
        // Image fills container; excess is clipped.
        if (containerAspect > aspectRatio) {
          // Container is wider → image overflows top/bottom.
          final imageWidth = container.width;
          final imageHeight = imageWidth / aspectRatio;
          final top = (container.height - imageHeight) / 2;
          return Rect.fromLTWH(0, top, imageWidth, imageHeight);
        } else {
          // Container is taller → image overflows left/right.
          final imageHeight = container.height;
          final imageWidth = imageHeight * aspectRatio;
          final left = (container.width - imageWidth) / 2;
          return Rect.fromLTWH(left, 0, imageWidth, imageHeight);
        }

      case BoxFit.fitWidth:
        final imageWidth = container.width;
        final imageHeight = imageWidth / aspectRatio;
        final top = (container.height - imageHeight) / 2;
        return Rect.fromLTWH(0, top, imageWidth, imageHeight);

      case BoxFit.fitHeight:
        final imageHeight = container.height;
        final imageWidth = imageHeight * aspectRatio;
        final left = (container.width - imageWidth) / 2;
        return Rect.fromLTWH(left, 0, imageWidth, imageHeight);

      case BoxFit.fill:
      case BoxFit.none:
        // Full container.
        return Offset.zero & container;
    }
  }
}
